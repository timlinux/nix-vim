{ ... }:
let
  treesitterLanguages = [
    "bash"
    "clang"
    "css"
    "go"
    "html"
    "java"
    # "json" # handled separately, not a standalone NVF language
    "kotlin"
    "lua"
    "markdown"
    "nix"
    "python"
    # "rst" # needs language config in languages.nix
    "rust"
    "sql"
    # "toml"
    # "tsx" # handled by ts language config
    # "typescript" # handled by ts language config
    "yaml"
    "zig"

    # Rarely Used or Niche Today
    # "assembly"
    # "astro"
    # "clojure"
    # "elixir"
    # "elm"
    # "erlang"
    # "fennel"
    # "fish"
    # "haskell"
    # "julia"
    # "latex"
    # "ocaml"
    # "php"
    # "r"
    # "ruby"
    # "scala"
    # "svelte"
    # "swift"
    # "typst"
    # "vue"

  ];

  treeSitterEnables = builtins.listToAttrs (
    builtins.map (lang: {
      name = lang;
      value = {
        treesitter.enable = true;
      };
    }) treesitterLanguages
  );
in
{
  vim = {
    treesitter = {
      enable = true;
      fold = true;

      highlight = {
        enable = true;
      };

      indent.enable = true;

      addDefaultGrammars = true;

      autotagHtml = true;

      context = {
        enable = true; # Enable the plugin so toggle works
        setupOpts = {
          enable = false; # Start disabled by default
          line_numbers = true; # show line numbers in the sticky header
          max_lines = 3; # show at most 3 lines for the header
          min_window_height = 0; # no min limit — always on
          mode = "cursor"; # calculate context from the cursor position
          multiline_threshold = 20; # default is fine
          separator = "-"; # shows a line between header and content
          trim_scope = "outer"; # trim outer context if too long
          zindex = 20; # default, fine
        };
      };

    };
    # The enableFormat / enableTreesitter / enableExtraDiagnostics flags live in
    # languages.nix; this module only turns on the per-language grammars.
    languages = treeSitterEnables;

    # nvf wires treesitter's indentexpr with one global `FileType *`
    # autocmd (see the generated init.lua's "treesitter-autocommands"
    # section), so there is no per-language switch for it. The typing
    # benchmark (lib/bench-typing.lua) measured markdown's indentexpr at
    # roughly 50-100x the cost of Lua's -- median 0.35ms/keystroke vs
    # 0.003ms with it off, because it has to reparse across the markdown /
    # markdown_inline injection boundary on every edit -- while
    # render-markdown, blink-cmp's doc popup/ghost text, and spellcheck
    # made no measurable difference. Prose doesn't need code-aware
    # reindentation anyway; smartindent/autoindent (core/options.nix)
    # already covers it.
    #
    # This autocmd has to be registered *after* nvf's own so it overrides
    # rather than races it -- luaConfigRC entries land in a later generated
    # init.lua section than pluginRC ones (where nvf's own treesitter
    # autocmd lives), so that ordering is automatic here.
    luaConfigRC.treesitter-markdown-indent = ''
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        group = vim.api.nvim_create_augroup("MarkdownIndentOverride", { clear = true }),
        callback = function()
          vim.bo.indentexpr = ""
        end,
      })
    '';
  };
}
