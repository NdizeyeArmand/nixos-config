#!/usr/bin/env nu

def main [jsonlz4_file: path, --out: path = "bookmarks.json"] {
  # Decompress the jsonlz4 backup
  let raw = (dejsonlz4 $jsonlz4_file | from json)

  # Flatten all bookmark nodes into a table
  let rows = ($raw.children | flatten_tree)

  # Find the three root folder GUIDs
  let toolbar_id  = ($rows | where guid == "toolbar_____" | get id | first)
  let menu_id     = ($rows | where guid == "menu________" | get id | first)
  let unfiled_id  = ($rows | where guid == "unfiled_____" | get id | first)

  let result = {
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

  $result | to json --indent 2 | save --force $out
  print $"Bookmarks written to ($out)"
}

def flatten_tree [] {
  each { |node|
    let children = if ("children" in $node) {
      $node.children | flatten_tree
    } else {
      []
    }
    [$node] ++ $children
  } | flatten
}

def get_folder_bookmarks [folder_id: int, rows: table] {
  $rows
  | where { |r| ($r.parent? == $folder_id) and ($r.type? == "text/x-moz-place") }
  | each { |b| { title: ($b.title? | default ""), url: ($b.uri? | default "") } }
}
