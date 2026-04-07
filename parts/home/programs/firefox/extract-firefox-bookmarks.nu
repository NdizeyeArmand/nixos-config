#!/usr/bin/env nu

def main [jsonlz4_file: path, --out: path = "bookmarks.json"] {
  # Decompress the jsonlz4 backup
  let raw = (dejsonlz4 $jsonlz4_file | from json)

  # Find the three root folder GUIDs
  let toolbar_node  = (find_by_guid "toolbar_____" $raw)
  let menu_node     = (find_by_guid "menu________"  $raw)
  let unfiled_node  = (find_by_guid "unfiled_____"  $raw)

  let result = {
    force: true,
    settings: [
      {
        toolbar: true,
        bookmarks: (collect_children $toolbar_node)
      },
      {
        name: "Other Bookmarks",
        toolbar: false,
        bookmarks: ((collect_children $menu_node) ++ (collect_children $unfiled_node))
      }
    ]
  }

  $result | to json --indent 2 | save --force $out
  print $"Bookmarks written to ($out)"
}

def find_by_guid [target_guid: string, node: record] {
  if ($node.guid? == $target_guid) {
    $node
  } else if ("children" in $node) {
      let found = ($node.children
        | each { |child| find_by_guid $target_guid $child }
        | where { |r| $r != null }
        | get 0?)
      $found
  } else {
    null
  }
}

def collect_children [node] {
  if ($node == null) {
    return []
  }
  if not ("children" in $node) {
    return []
  }
  $node.children
    | each { |child| collect_item $child }
    | flatten
}

def collect_item [node] {
  match ($node.type?) {
    "text/x-moz-place" => {
      [{ name: ($node.title? | default ""), url: ($node.uri? | default "") }]
    }
    "text/x-moz-place-container" => {
      [{ name: ($node.title? | default ""), bookmarks: (collect_children $node) }]
    }
    _ => { [] }
  }
}
