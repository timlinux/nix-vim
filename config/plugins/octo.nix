{
  octo-plugin,
  pkgs,
  ...
}:
{
  vim = {
    extraPlugins = {
      octo = {
        package = octo-plugin;
        # Guarded: octo's setup() raises if `gh` is not on PATH, and nvf emits
        # these setup calls into the main chunk of init.lua -- so an uncaught
        # error here silently aborts every module configured after it. `gh` is
        # in runtimeDeps now; this keeps a future missing external tool from
        # taking the whole editor down with it.
        setup = ''
          local octo_ok, octo_err = pcall(function()
            require('octo').setup({
              default_remote = {"upstream", "origin"},
              picker = "telescope",
              picker_config = {
                use_emojis = true,
              },
              suppress_missing_scope = {
                projects_v2 = true,
              },
            })
          end)
          if not octo_ok then
            vim.schedule(function()
              vim.notify(
                "octo.nvim disabled: " .. tostring(octo_err),
                vim.log.levels.WARN
              )
            end)
          end
        '';
      };
    };

    keymaps = [
      # Issues
      {
        key = "<leader>oi";
        action = "<cmd>Octo issue list<cr>";
        mode = "n";
        silent = true;
        desc = " List Issues";
      }
      {
        key = "<leader>oI";
        action = "<cmd>Octo issue search<cr>";
        mode = "n";
        silent = true;
        desc = " Search Issues";
      }
      {
        key = "<leader>on";
        action = "<cmd>Octo issue create<cr>";
        mode = "n";
        silent = true;
        desc = " New Issue";
      }
      {
        key = "<leader>oO";
        action = "<cmd>Octo issue browser<cr>";
        mode = "n";
        silent = true;
        desc = " Open in Browser";
      }

      # Pull Requests
      {
        key = "<leader>op";
        action = "<cmd>Octo pr list<cr>";
        mode = "n";
        silent = true;
        desc = " List PRs";
      }
      {
        key = "<leader>oP";
        action = "<cmd>Octo pr search<cr>";
        mode = "n";
        silent = true;
        desc = " Search PRs";
      }
      {
        key = "<leader>oc";
        action = "<cmd>Octo pr create<cr>";
        mode = "n";
        silent = true;
        desc = " Create PR";
      }
      {
        key = "<leader>od";
        action = "<cmd>Octo pr diff<cr>";
        mode = "n";
        silent = true;
        desc = " View Diff";
      }
      {
        key = "<leader>of";
        action = "<cmd>Octo pr changes<cr>";
        mode = "n";
        silent = true;
        desc = " Changed Files";
      }
      {
        key = "<leader>om";
        action = "<cmd>Octo pr merge<cr>";
        mode = "n";
        silent = true;
        desc = " Merge PR";
      }
      {
        key = "<leader>ok";
        action = "<cmd>Octo pr checkout<cr>";
        mode = "n";
        silent = true;
        desc = " Checkout PR";
      }
      {
        key = "<leader>ob";
        action = "<cmd>Octo pr browser<cr>";
        mode = "n";
        silent = true;
        desc = " Open PR in Browser";
      }

      # Review
      {
        key = "<leader>os";
        action = "<cmd>Octo review start<cr>";
        mode = "n";
        silent = true;
        desc = " Start Review";
      }
      {
        key = "<leader>or";
        action = "<cmd>Octo review resume<cr>";
        mode = "n";
        silent = true;
        desc = " Resume Review";
      }
      {
        key = "<leader>oa";
        action = "<cmd>Octo review submit approve<cr>";
        mode = "n";
        silent = true;
        desc = " Approve";
      }
      {
        key = "<leader>ox";
        action = "<cmd>Octo review submit request_changes<cr>";
        mode = "n";
        silent = true;
        desc = " Request Changes";
      }
      {
        key = "<leader>ou";
        action = "<cmd>Octo review submit comment<cr>";
        mode = "n";
        silent = true;
        desc = " Submit Comment";
      }
      {
        key = "<leader>oX";
        action = "<cmd>Octo review discard<cr>";
        mode = "n";
        silent = true;
        desc = " Discard Review";
      }

      # Comments
      {
        key = "<leader>oA";
        action = "<cmd>Octo comment add<cr>";
        mode = "n";
        silent = true;
        desc = " Add Comment";
      }
      {
        key = "<leader>oD";
        action = "<cmd>Octo comment delete<cr>";
        mode = "n";
        silent = true;
        desc = " Delete Comment";
      }

      # Repo & Gist
      {
        key = "<leader>ol";
        action = "<cmd>Octo repo list<cr>";
        mode = "n";
        silent = true;
        desc = " List Repos";
      }
      {
        key = "<leader>oe";
        action = "<cmd>Octo repo browser<cr>";
        mode = "n";
        silent = true;
        desc = " Open Repo in Browser";
      }
      {
        key = "<leader>og";
        action = "<cmd>Octo gist list<cr>";
        mode = "n";
        silent = true;
        desc = " List Gists";
      }
    ];
  };
}
