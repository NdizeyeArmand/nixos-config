function Link(el)
  if el.target:match("%.md$") then
    local src_dir = PANDOC_STATE.input_files[1]:match("(.*/)") or "./"
    el.target = "notes://" .. src_dir .. el.target
  end
  return el
end
