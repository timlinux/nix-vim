# Add-ons & Components

!!! info "Auto-generated"
    This page and its diagram are generated from `lib/addons.json` by
    `lib/gen-addons-docs.py`, and drift-checked against the live
    `config/` tree. Do not edit by hand — run `nix run .#handbook-addons`.

timvim bundles **47 add-ons** — 46 enabled out of the box and 1 shipped but off by default — on top of the [NVF](https://github.com/notashelf/nvf) framework. The [Overview](index.md) shows them as a visual map; the full list is grouped into 10 families below.

## AI Assistance

*Chat and inline completion, under your control.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [Claude Code](https://github.com/coder/claudecode.nvim) | AI chat and agentic coding inside a terminal split. | ✅ On |
| [GitHub Copilot](https://github.com/zbirenbaum/copilot.lua) | Inline ghost-text completion you accept as you type. | ✅ On |

## Language & LSP

*Diagnostics, formatting, completion and syntax.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [nvim-lspconfig + lspsaga](https://github.com/neovim/nvim-lspconfig) | Language servers with a polished diagnostics UI. | ✅ On |
| [Language modules](https://github.com/notashelf/nvf) | Per-language LSP, formatting, DAP and treesitter, via NVF. | ✅ On |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Fast, accurate syntax highlighting and code objects. | ✅ On |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Format-on-command with per-filetype formatters. | ✅ On |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine feeding the completion menu. | ✅ On |
| [Trouble](https://github.com/folke/trouble.nvim) | A pretty, navigable list of diagnostics and references. | ✅ On |
| [harper-ls](https://github.com/elijah-potter/harper) | Grammar and spelling language server for prose. | ✅ On |
| [esbonio (RST/Sphinx)](https://github.com/swyddfa/esbonio) | reStructuredText and Sphinx language server. | ✅ On |

## Navigation & Search

*Jump to files, symbols and text fast.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [Telescope](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder for files, grep, symbols and media. | ✅ On |
| [flash.nvim](https://github.com/folke/flash.nvim) | Label-based jump-to-anywhere motions. | ✅ On |
| [goto-preview](https://github.com/rmagatti/goto-preview) | Peek definitions and references in a floating window. | ✅ On |
| [outline.nvim](https://github.com/hedyhli/outline.nvim) | A symbol outline sidebar for the current file. | ✅ On |
| [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) | Seamless split navigation and resizing. | ✅ On |

## Git & GitHub

*Hunks, diffs, blame and pull requests.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Inline hunk signs, staging, blame and hunk motions. | ✅ On |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Side-by-side diffs and merge-conflict resolution. | ✅ On |
| [octo.nvim](https://github.com/pwntester/octo.nvim) | Review and manage GitHub issues and pull requests. | ✅ On |

## Editing & Motion

*Surround, yank, multi-cursor and refactor.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Add, change and delete surrounding pairs. | ✅ On |
| [yanky.nvim](https://github.com/gbprod/yanky.nvim) | A yank ring with history and put-with-formatting. | ✅ On |
| [multicursors.nvim](https://github.com/smoka7/multicursors.nvim) | Multiple cursors for simultaneous edits. | ✅ On |
| [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) | Extract, inline and other language-aware refactors. | ✅ On |
| [hardtime.nvim](https://github.com/m4xshen/hardtime.nvim) | Coaches better motions by nudging away from bad habits. | ✅ On |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | A suite of small editing utilities (pairs, colours). | ✅ On |

## Debug & Test

*Breakpoints, stepping and test runners.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol client with a debug UI. | ✅ On |
| [persistent-breakpoints.nvim](https://github.com/Weissle/persistent-breakpoints.nvim) | Keeps your breakpoints across sessions. | ✅ On |
| [neotest](https://github.com/nvim-neotest/neotest) | Run and review tests without leaving the editor. | ✅ On |

## UI & Appearance

*Dashboard, statusline, folds and visuals.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [alpha-nvim](https://github.com/goolord/alpha-nvim) | The Kartoza-branded startup dashboard. | ✅ On |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | The powerline-bubble statusline. | ✅ On |
| [noice.nvim](https://github.com/folke/noice.nvim) | Reimagined cmdline, messages and popupmenu UI. | ✅ On |
| [nvim-notify](https://github.com/rcarriga/nvim-notify) | Animated, dismissible notification toasts. | ✅ On |
| [barbecue.nvim](https://github.com/utilyre/barbecue.nvim) | A VS Code-style breadcrumb winbar. | ✅ On |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Indent guides (toggle with a keymap). | ✅ On |
| [nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua) | Highlights colour codes with their actual colour. | ✅ On |
| [precognition.nvim](https://github.com/tris203/precognition.nvim) | Shows the motions available from your cursor. | ✅ On |
| [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | A smooth animated cursor trail. | ✅ On |
| [bufferline (nvim)](https://github.com/akinsho/bufferline.nvim) | A bubbled tabline of open buffers. | ⚪ Off |

## Files & Terminal

*File manager, terminals and undo history.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [yazi.nvim](https://github.com/mikavilpas/yazi.nvim) | The primary file manager (Yazi TUI in a float). | ✅ On |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Managed floating and split terminals. | ✅ On |
| [undotree](https://github.com/mbbill/undotree) | Visualise and traverse the undo history. | ✅ On |
| [image.nvim](https://github.com/3rd/image.nvim) | Render images inline via the Kitty graphics protocol. | ✅ On |

## Writing & Docs

*Markdown, grammar and note-taking.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [Markdown tools](https://github.com/iamcco/markdown-preview.nvim) | Live browser preview and Markdown filetype tweaks. | ✅ On |

## Workflow & Extras

*Sessions, projects and practice tools.*

| Add-on | Purpose | Default |
|--------|---------|---------|
| [nvim-session-manager](https://github.com/Shatur/neovim-session-manager) | Save and restore editing sessions per project. | ✅ On |
| [project.nvim](https://github.com/ahmedkhalf/project.nvim) | Automatic project-root detection and switching. | ✅ On |
| [leetcode.nvim](https://github.com/kawre/leetcode.nvim) | Solve LeetCode problems inside Neovim. | ✅ On |
| [typr (nvzone)](https://github.com/nvzone/typr) | A built-in typing-speed practice game. | ✅ On |
| [direnv.vim](https://github.com/direnv/direnv.vim) | Loads per-project environments via direnv. | ✅ On |

!!! tip "See also"
    The [Overview](index.md) explains how these fit together, and the
    [Developer Guide → Architecture](../developer-guide/architecture.md)
    shows how the flake wires them into the editor.
