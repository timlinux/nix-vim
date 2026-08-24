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
  };
}
