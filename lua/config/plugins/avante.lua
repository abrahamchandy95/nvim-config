-- ~/.config/nvim/lua/config/plugins/avante.lua
return {
  {
    "yetone/avante.nvim",
    build = "make BUILD_FROM_SOURCE=true",
    event = "VeryLazy",
    version = false,

    opts = function()
      -- Ensure GEMINI_API_KEY is visible to Neovim (inherit or fallback file)
      if not vim.env.GEMINI_API_KEY or #tostring(vim.env.GEMINI_API_KEY) == 0 then
        local from_os = os.getenv("GEMINI_API_KEY")
        if from_os and #from_os > 0 then
          vim.env.GEMINI_API_KEY = from_os
        else
          local envfile = vim.fn.expand("~/.secrets/gemini.env")
          if vim.fn.filereadable(envfile) == 1 then
            for line in io.lines(envfile) do
              local val = line:match([[export%s+GEMINI_API_KEY%s*=%s*"?([^"]+)"?]])
              if val and #val > 0 then
                vim.env.GEMINI_API_KEY = val
                break
              end
            end
          end
        end
      end

      -- Resolve Gemini CLI path (your system shows /usr/bin/gemini)
      local gemini_cmd = vim.fn.exepath("gemini")
      if gemini_cmd == "" and vim.fn.filereadable("/usr/bin/gemini") == 1 then
        gemini_cmd = "/usr/bin/gemini"
      end

      -- Only supported args for ACP: the ACP flag and the model
      -- (No temperature/max tokens flags; the CLI doesn’t accept them.)
      local gemini_args = {
        "--experimental-acp",
        "-m", "gemini-2.5-flash-lite",
      }

      local opts = {
        instructions_file = "avante.md",
        provider = "gemini-cli",
        acp_providers = {
          ["gemini-cli"] = {
            command = gemini_cmd ~= "" and gemini_cmd or "gemini",
            args = gemini_args,
            -- inherit GEMINI_API_KEY/PATH from Neovim
          },
        },
      }

      -- mcphub custom tool (unchanged)
      local ok_ext, mcp_ext = pcall(require, "mcphub.extensions.avante")
      if ok_ext and mcp_ext and type(mcp_ext.mcp_tool) == "function" then
        opts.custom_tools = {
          ---@diagnostic disable-next-line: redundant-parameter
          mcp_ext.mcp_tool("planning", function()
            local ok_utils, utils = pcall(require, "avante.utils")
            if ok_utils and utils.get_project_root then
              return utils.get_project_root()
            end
            return (vim.uv and vim.uv.cwd())
                or (vim.loop and vim.loop.cwd())
                or vim.fn.getcwd()
          end),
        }
      else
        vim.schedule(function()
          vim.notify(
            "[avante] mcphub extension not found. Install ravitemer/mcphub.nvim to enable MCP tools.",
            vim.log.levels.WARN
          )
        end)
      end

      return opts
    end,

    dependencies = {
      "nvim-lua/plenary.nvim",
      { "MunifTanjim/nui.nvim",  lazy = false,                              priority = 1000 },
      "zbirenbaum/copilot.lua",
      { "ravitemer/mcphub.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
