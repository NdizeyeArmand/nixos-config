#!/usr/bin/env nu

# Convert bookmarks.json back to a Firefox-importable backup JSON
# Usage: nu ff-bookmarks-export.nu --input ($env.FILE_PWD | path join ".." "bookmarks.json") --output ($env.FILE_PWD | path join ".." "firefox-backup.json") 

def to_ff_node [item: record, pos: int] {
  if ("url" in $item) {
    {
      guid: null,
      title: ($item.name? | default ""),
      index: $pos,
      dateAdded: 0,
      lastModified: 0,
      type: "text/x-moz-place",
      uri: $item.url
    }
  } else {
    {
      guid: null,
      title: ($item.name? | default ""),
      index: $pos,
      dateAdded: 0,
      lastModified: 0,
      type: "text/x-moz-place-container",
      children: ($item.bookmarks | enumerate | each { |e| to_ff_node $e.item $e.index })
    }
  }
}

let default_input = ($env.FILE_PWD | path join ".." "bookmarks.json")
let default_output = ($env.FILE_PWD | path join ".." "firefox-backup.json")
def main [--input: path, --output: path] {
  let output = if ($output | is-empty) {
    $default_output
  } else {
    $output
  }

  let input = if ($input | is-empty) {
    $default_input
  } else {
    $input
  }

  let data = (open $input)
  let toolbar = ($data.settings | where { |s| $s.toolbar? == true } | get 0?)
  let other = ($data.settings | where { |s| $s.toolbar? != true } | each {|s| $s.bookmarks } | flatten)

  let root = {
    guid: "root________",
    title: "",
    index: 0,
    dateAdded: 0,
    lastModified: 0,
    type: "text/x-moz-place-container",
    children: [
      {
        guid: "menu________",
        title: "Bookmarks Menu",
        index: 0,
        dateAdded: 0,
        lastModified: 0,
        type: "text/x-moz-place-container",
        children: ($other | enumerate | each { |e| to_ff_node $e.item $e.index })
      },
      {
        guid: "toolbar_____",
        title: "Bookmarks Toolbar",
        index: 1,
        dateAdded: 0,
        lastModified: 0,
        type: "text/x-moz-place-container",
        children: (if $toolbar != null { $toolbar.bookmarks | enumerate | each { |e| to_ff_node $e.item $e.index } } else { [] })
      }
      {
        guid: "unfiled_____",
        title: "Other Bookmarks",
        index: 2,
        dateAdded: 0,
        lastModified: 0,
        type: "text/x-moz-place-container",
        children: []
      }      
    ]
  }

  $root | to json --indent 2 | save --force $output
  print $"Firefox backup written to ($output)"
}
