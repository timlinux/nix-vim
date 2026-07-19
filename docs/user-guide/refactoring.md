# Refactoring

timvim bundles **ThePrimeagen's refactoring.nvim** for reliable, language-aware
code transformations. All operations live under `Space r`. Extract operations
generally start from a visual selection; inline operations act on the symbol
under the cursor.

## Visual-mode operations

Select the code first, then press the key.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>re` | v | Extract a function |
| `<leader>rf` | v | Extract to a new file |
| `<leader>rv` | v | Extract a variable |

## Normal & mixed-mode operations

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ri` | n, v | Inline a variable |
| `<leader>rI` | n | Inline a function |
| `<leader>rb` | n | Extract a block into a function |
| `<leader>rB` | n | Extract a block to a new file |
| `<leader>rr` | n, v | Open the refactor menu (all options) |

!!! tip "Not sure which one?"
    Press `<leader>rr` to open the interactive menu and pick from every
    available refactor in one place.

## Supported languages

Refactoring works across:

```text
Go, Python, JavaScript / TypeScript, Lua, C / C++, Java, Ruby, PHP
```

!!! info "How it works"
    refactoring.nvim uses Treesitter to understand scope, so extracted
    functions and variables carry the correct parameters and return values for
    the language you are editing.
