#!/usr/bin/env nu

# Extract live Firefox bookmarks from places.sqlite into the same JSON format produced by ff-bookmarks-ingest.nu
#
# Usage:
# nu ff-bookmarks-live.nu
# nu ff-bookmarks-live.nu --profile /home/armand/.mozilla/firefox/profile_0
# nu ff-bookmarks-live.nu --out ($env.FILE_PWD | path join ".." "bookmarks.json")

def detect_profile [] {
  let base = ($env.HOME | path join ".mozilla" "firefox")
  let candidates = (
    ls $base
    | where type == "dir"
    | get name
    | where { |p|
        let name = ($p | path basename)
        ($name =~ '\.default') or ($name =~ 'profile_')
      }
    | sort
  )
  if ($candidates | is-empty) {
    error make { msg: $"No Firefox profile found under ($base)" }
  }

  let release = ($candidates | where { |p| ($p | path basename) =~ 'default-release' })
  if not ($release | is-empty) { $release | first } else { $candidates | first }
}

def folder_id [bookmarks: table, guid: string] {
  let row = ($bookmarks | where guid == $guid | get 0?)
  if $row == null {
    error make { msg: $"Bookmark root GUID not found: ($guid)" }
  }
  $row.id
}

def collect_item [bookmarks: table, places: table, row: record] {
  match $row.type {
    1 => {
      let place = ($places | where id == $row.fk | get 0?)
      if $place == null { return null }
      let url = ($place.url? | default "")
      if ($url | is-empty) { return null }
      [{ name: ($row.title? | default ""), url: $url }]
    }
    2 => {
      [{
        name: ($row.title? | default ""),
        bookmarks: (collect_children $bookmarks $places $row.id)
      }]
    }
    _ => { null }
  } 
}

def collect_children [bookmarks: table, places: table, parent_id: int] {
  $bookmarks
  | where parent == $parent_id
  | sort-by position
  | each { |row| collect_item $bookmarks $places $row }
  | where { |x| $x != null }
  | flatten
}

let default_out = ($env.FILE_PWD | path join ".." "bookmarks.json")
def main [--profile: path = "", --out: path] {
  let out = if ($out | is-empty) {
    $default_out
  } else {
    $out
  }
  let profile_dir = if ($profile | is-empty) {
    detect_profile
  } else {
    $profile
  }

  print $"Using profile: ($profile_dir)"
 
  let tmp_db = $"/tmp/ff_places_(date now | format date '%s').sqlite"
  let tmp_wal = $"($tmp_db)-wal"
  let tmp_shm = $"($tmp_db)-shm"

  cp $"($profile_dir)/places.sqlite" $tmp_db
  if ($"($profile_dir)/places.sqlite-wal" | path exists) {
    cp $"($profile_dir)/places.sqlite-wal" $tmp_wal
  }
  if ($"($profile_dir)/places.sqlite-shm" | path exists) {
    cp $"($profile_dir)/places.sqlite-shm" $tmp_shm
  }

  open $tmp_db | query db "PRAGMA wal_checkpoint(FULL);" | ignore

  let bookmarks = (open $tmp_db | query db "SELECT * FROM moz_bookmarks")
  let places = (open $tmp_db | query db "SELECT id, url FROM moz_places")

  rm --force $tmp_db $tmp_wal $tmp_shm

  let toolbar_id = (folder_id $bookmarks "toolbar_____")
  let menu_id = (folder_id $bookmarks "menu________")
  let unfiled_id = (folder_id $bookmarks "unfiled_____")

  let non_toolbar_items = (
    (collect_children $bookmarks $places $menu_id) ++ (collect_children $bookmarks $places $unfiled_id)
  )

  let non_toolbar_settings = (
    $non_toolbar_items | each { |item|
      if ($item | get bookmarks?) != null {
        { toolbar: false, name: $item.name, bookmarks: $item.bookmarks }
      } else {
        { toolbar: false, name: $item.name, bookmarks: [{ name: $item.name, url: $item.url }] }
      }
    }
  )

  let result = {
    force: true,
    settings: (
      [{
        toolbar: true,
        bookmarks: (collect_children $bookmarks $places $toolbar_id)
      }]
      ++ $non_toolbar_settings
    )
  }

  $result | to json --indent 2 | save --force $out
  print $"Bookmarks written to ($out)"
} 
