local M = {}

M.setup = function()
  local npairs = require("nvim-autopairs")
  npairs.setup({
    check_ts = true,
    ts_config = {
      lua = { "string" }, -- it will not add a pair on that treesitter node
      javascript = { "template_string" },
      java = false,    -- don't check treesitter on java
    },
    -- change default fast_wrap
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = [=[[%'%"%>%]%)%}%,]]=],
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "Search",
      highlight_grey = "Comment",
    },
  })
  local ts_conds = require("nvim-autopairs.ts-conds")
  local Rule = require("nvim-autopairs.rule")
  -- press % => %% only while inside a comment or string
  npairs.add_rules({
    Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node({ "string", "comment" })),
    Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({ "function" })),
    Rule("%(.*%)%s*%=>$", " {}", { "typescript", "typescriptreact", "javascript" })
        :use_regex(true)
        :set_end_pair_length(1),
  })
end

return M
