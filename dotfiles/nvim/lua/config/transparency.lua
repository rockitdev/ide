-- Transparency settings for Neovim
-- This makes the background transparent to work with terminal transparency

local function set_transparency()
  -- Set transparent background for normal windows
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  
  -- Set transparent background for special windows
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
  vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
  vim.api.nvim_set_hl(0, "Folded", { bg = "none" })
  vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
  
  -- Telescope transparency
  vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
  vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
  
  -- NeoTree transparency
  vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
end

-- Set transparency on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_transparency,
})

-- Set transparency initially
set_transparency()

-- Toggle transparency command
vim.api.nvim_create_user_command("TransparencyToggle", function()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  if normal.bg == nil then
    vim.cmd("colorscheme " .. vim.g.colors_name)
  else
    set_transparency()
  end
end, {})

-- Keymap to toggle transparency
vim.keymap.set("n", "<leader>ut", "<cmd>TransparencyToggle<cr>", { desc = "Toggle transparency" })