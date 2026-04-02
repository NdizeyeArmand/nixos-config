#!/usr/bin/env nu

# Sync Firefox bookmarks to bookmarks.json for use with NixOS home-manager.

def main [--profile: string = "profile_0"] {
  let profile_dir = ($env.HOME | path join ".mozilla/firefox" $profile)
  let sqlite_path = ($profile_dir | path join "places.sqlite")
  let script_dir  = ($env.CURRENT_FILE | path dirname)
  let nix_output  = ($script_dir | path join "bookmarks.json")
  let tmp_db      = "/tmp/places_backup.sqlite"

  sqlite3 $sqlite_path $".clone ($tmp_db)"

  let sql = "
    SELECT
      b.id,
      b.parent,
      COALESCE(b.title, '') AS title,
      b.type,
      b.position,
      COALESCE(p.url, '') AS url,
      COALESCE((SELECT title FROM moz_bookmarks WHERE id = b.parent), '') AS parent_title
    FROM moz_bookmarks b
    LEFT JOIN moz_places p ON b.fk = p.id
    WHERE (b.title IS NOT NULL AND b.title != '')
      AND (b.type = 1 OR b.type = 2)
    ORDER BY b.parent, b.position;
  "

let rows = (
  sqlite3 -separator "	" $tmp_db $sql    # tab-separated
  | lines
  | each { |line|
      let cols = ($line | split column "\t" id parent title type position url parent_title)
      $cols | first
  }
)

let root_ids = (
  sqlite3 -separator "	" $tmp_db
    "SELECT id, title FROM moz_bookmarks WHERE title IN ('toolbar','menu','unfiled','mobile') ORDER BY id;"
  | lines
  | each { |l| $l | split column "\t" id title | first }
  | reduce -f {} { |it, acc| $acc | insert $it.title $it.id }
)

let toolbar_id  = ($root_ids | get toolbar)
let menu_id     = ($root_ids | get menu)
let unfiled_id  = ($root_ids | get unfiled)

def get_folder_bookmarks [parent_id: string, all_rows: list] {
  let direct = (get_bookmarks $parent_id $all_rows)

  let sub_folders = (
    $all_rows
    | where parent == $parent_id and type == "2"
    | each { |folder|
        {
          name: $folder.title,
          toolbar: false,
          bookmarks: (get_bookmarks $folder.id $all_rows)
        }
    }
  )

  [$direct $sub_folders] | flatten
}

  # ── Build home-manager bookmarks structure ────────────────────────────────
  let output = {
    force: true,
    settings: [
      {
        toolbar: true,
        bookmarks: (get_folder_bookmarks $toolbar_id $rows)
      },
      {
        name: "Other Bookmarks",
        toolbar: false,
        bookmarks: ((get_folder_bookmarks $menu_id $rows) ++ (get_folder_bookmarks $unfiled_id $rows))
      }
    ]
  }

  $output | to json --indent 2 | save --force $nix_output
  print $"Bookmarks written to ($nix_output)"
}
