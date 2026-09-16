--- Given: lines holding GitHub repository URLs in the shapes they arrive in.
--- When: my.lang.markdown.linkify_line rewrites each line.
--- Then: every bare or <autolink> repository URL becomes [owner/repo](url),
--- and URLs already inside a markdown link are left alone.
--- Run with: nvim --headless "+luafile <this file>"
local ok, md = pcall(require, "my.lang.markdown")
local cases = {
  { "<https://github.com/ShortArrow/dotfiles>",
    "[ShortArrow/dotfiles](https://github.com/ShortArrow/dotfiles)" },
  { "https://github.com/ShortArrow/dotfiles/",
    "[ShortArrow/dotfiles](https://github.com/ShortArrow/dotfiles/)" },
  { "see https://github.com/ShortArrow/dotfiles.",
    "see [ShortArrow/dotfiles](https://github.com/ShortArrow/dotfiles)." },
  { "https://github.com/ShortArrow/dotfiles/blob/main/README.md",
    "[ShortArrow/dotfiles](https://github.com/ShortArrow/dotfiles/blob/main/README.md)" },
  { "[dotfiles](https://github.com/ShortArrow/dotfiles) stays",
    "[dotfiles](https://github.com/ShortArrow/dotfiles) stays" },
  { "[https://github.com/ShortArrow/dotfiles](https://github.com/ShortArrow/dotfiles)",
    "[https://github.com/ShortArrow/dotfiles](https://github.com/ShortArrow/dotfiles)" },
  { "https://github.com/ShortArrow has no repo",
    "https://github.com/ShortArrow has no repo" },
  { "a https://github.com/a/b and <https://github.com/c/d>",
    "a [a/b](https://github.com/a/b) and [c/d](https://github.com/c/d)" },
  { "no url here", "no url here" },
}
local failed = false
if not ok or type(md.linkify_line) ~= "function" then
  print("FAIL: my.lang.markdown.linkify_line is not a function")
  failed = true
else
  for _, c in ipairs(cases) do
    local got = md.linkify_line(c[1])
    if got == c[2] then
      print("OK:   " .. c[1])
    else
      print("FAIL: " .. c[1] .. "\n      want " .. c[2] .. "\n      got  " .. tostring(got))
      failed = true
    end
  end
end
vim.cmd(failed and "cq!" or "qa!")
