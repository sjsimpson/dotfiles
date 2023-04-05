local M = {
	"windwp/nvim-autopairs",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    check_ts = true
  },
  config = function(_, opts)
    require("nvim-autopairs").setup(opts)
  end
}

return M
