return {
  -- AI Code Companion (Claude/GPT integration)
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle Claude Chat" },
      { "<leader>ca", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Claude Actions" },
      { "<leader>cp", function() require("codecompanion").prompt("explain") end, mode = { "n", "v" }, desc = "Explain Code" },
      { "<leader>cr", function() require("codecompanion").prompt("refactor") end, mode = { "n", "v" }, desc = "Refactor Code" },
      { "<leader>cf", function() require("codecompanion").prompt("fix") end, mode = { "n", "v" }, desc = "Fix Code" },
      { "<leader>ct", function() require("codecompanion").prompt("tests") end, mode = { "n", "v" }, desc = "Generate Tests" },
      { "<leader>cd", function() require("codecompanion").prompt("documentation") end, mode = { "n", "v" }, desc = "Generate Docs" },
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "anthropic",
          },
          inline = {
            adapter = "anthropic",
          },
        },
        adapters = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "ANTHROPIC_API_KEY",
              },
              schema = {
                model = {
                  default = "claude-3-5-sonnet-20241022",
                },
              },
            })
          end,
        },
        display = {
          chat = {
            window = {
              layout = "float",
              relative = "editor",
              width = 0.8,
              height = 0.8,
              row = 0.1,
              col = 0.1,
              border = "rounded",
              zindex = 50,
            },
          },
        },
        opts = {
          log_level = "ERROR",
          send_code = true,
          use_default_actions = true,
          use_default_prompts = true,
        },
      })
    end,
  },

  -- GitHub Copilot (optional, if you have access)
  {
    "github/copilot.vim",
    enabled = false, -- Set to true if you have Copilot access
    event = "InsertEnter",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      
      vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.api.nvim_set_keymap("i", "<C-]>", '<Plug>(copilot-next)', {})
      vim.api.nvim_set_keymap("i", "<C-[>", '<Plug>(copilot-previous)', {})
      vim.api.nvim_set_keymap("i", "<C-\\>", '<Plug>(copilot-dismiss)', {})
    end,
  },

  -- Terminal integration for Claude CLI
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm size=15 direction=horizontal<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm size=50 direction=vertical<cr>", desc = "Vertical terminal" },
      { "<leader>tc", function()
        local Terminal = require("toggleterm.terminal").Terminal
        local claude = Terminal:new({
          cmd = "claude-code",
          direction = "float",
          float_opts = {
            border = "curved",
            width = function()
              return math.floor(vim.o.columns * 0.8)
            end,
            height = function()
              return math.floor(vim.o.lines * 0.8)
            end,
          },
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
          end,
        })
        claude:toggle()
      end, desc = "Claude Terminal" },
    },
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },

  -- Neural - Another AI integration option
  {
    "dense-analysis/neural",
    enabled = false, -- Enable if you want to use this instead
    dependencies = {
      "MunifTanjim/nui.nvim",
      "ElPiloto/significant.nvim",
    },
    cmd = { "Neural" },
    keys = {
      { "<leader>cn", "<cmd>Neural<cr>", desc = "Neural AI" },
    },
    config = function()
      require("neural").setup({
        source = {
          anthropic = {
            api_key = vim.env.ANTHROPIC_API_KEY,
          },
        },
        ui = {
          prompt_icon = "🤖 ",
        },
      })
    end,
  },
}