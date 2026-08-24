# Full Keymap

!!! info "Auto-generated"
    This page is generated at build time from timvim's **live keymaps**
    (the built Neovim is queried headless). It is always in step with the
    configuration — do not edit it by hand.

timvim sets **373** keymaps. The leader is ++space++. Tables below group them the way which-key does.

## Leader groups

### Assistant — `<leader>a`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ac` | n | Toggle Claude Code |
| `<leader>ad` | n | Disable Copilot |
| `<leader>ae` | n | Enable Copilot |
| `<leader>af` | n | Focus Claude Code |
| `<leader>ai` | n | Copilot Info/Status |
| `<leader>am` | n | Select Claude Model |
| `<leader>ap` | n | Copilot Panel |
| `<leader>as` | v | Send Selection to Claude |

### Buffers — `<leader>b`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>bb` | n | Find Buffers |
| `<leader>bd` | n | Swap Buffer Right |
| `<leader>bj` | n | Swap Buffer Down |
| `<leader>bk` | n | Swap Buffer Up |
| `<leader>bs` | n | Swap Buffer Left |

### Code — `<leader>c`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>c0` | n | Choose None |
| `<leader>cb` | n | Choose Both |
| `<leader>cc` | n | Check Available Formatters |
| `<leader>cf` | n | Format Buffer |
| `<leader>co` | n | Choose Ours |
| `<leader>cp` | n | Pick Color |
| `<leader>cr` | n | Rename Symbol |
| `<leader>ct` | n | Choose Theirs |

### Debug — `<leader>d`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>d.` | n | Re-run Last Debug Session |
| `<leader>dB` | n | Set Conditional Breakpoint |
| `<leader>dL` | n | Set Log Point |
| `<leader>dR` | n | Restart |
| `<leader>da` | n | Attach to Python Debugger |
| `<leader>db` | n | Toggle Breakpoint |
| `<leader>dc` | n | Continue |
| `<leader>dgo` | n | Step out of function |
| `<leader>dh` | n | Hover |
| `<leader>di` | n | Check debugpy installation |
| `<leader>dj` | n | Go down stacktrace |
| `<leader>dk` | n | Go up stacktrace |
| `<leader>dl` | n | Start/Continue local debugging |
| `<leader>dn` | n | Step into function |
| `<leader>do` | n | Step back |
| `<leader>dq` | n | Terminate |
| `<leader>dr` | n | Toggle Repl |
| `<leader>ds` | n | Show debug status |
| `<leader>dt` | n | Continue to the current cursor |
| `<leader>du` | n | Toggle DAP UI (S-F9) |
| `<leader>dv` | n | Next step |

### Files — `<leader>f`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>fG` | n | Live Grep Files (Regex) |
| `<leader>fO` | n | Open Yazi in Working Directory |
| `<leader>fb` | n | Buffers |
| `<leader>ff` | n | Find Files (FZF) |
| `<leader>fg` | n | Live Grep Files (Fixed Strings) |
| `<leader>fh` | n | Help tags |
| `<leader>flD` | n | LSP Definitions |
| `<leader>fld` | n | Diagnostics |
| `<leader>fli` | n | LSP Implementations |
| `<leader>flr` | n | LSP References |
| `<leader>flsb` | n | LSP Document Symbols |
| `<leader>flsw` | n | LSP Workspace Symbols |
| `<leader>flt` | n | LSP Type Definitions |
| `<leader>fm` | n | Find Media Files with Preview |
| `<leader>fn` | n | Find Nix Files |
| `<leader>fo` | n | Open Yazi at Current File |
| `<leader>fp` | n | Find Python Files |
| `<leader>fr` | n | Find Recent Files |
| `<leader>fs` | n | Search Word Under Cursor |
| `<leader>ft` | n | Open |
| `<leader>fvb` | n | Git branches |
| `<leader>fvcb` | n | Git buffer commits |
| `<leader>fvcw` | n | Git commits |
| `<leader>fvf` | n | Git files |
| `<leader>fvs` | n | Git status |
| `<leader>fvx` | n | Git stash |
| `<leader>fy` | n | Toggle/Resume Last Yazi Session |

### Git — `<leader>g`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gF` | n | Project Git History |
| `<leader>gV` | n | Close Diff View |
| `<leader>gb` | n | Blame line |
| `<leader>gf` | n | File Git History |
| `<leader>gg` | n | Open lazygit |
| `<leader>gl` | n | Git Log |
| `<leader>gv` | n | Open Diff View |
| `<leader>gx` | n | Toggle blame |

### Gitsigns — `<leader>h`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>hD` | n | Diff project |
| `<leader>hP` | n | Preview hunk |
| `<leader>hR` | n | Reset buffer |
| `<leader>hS` | n | Stage buffer |
| `<leader>hd` | n | Diff this |
| `<leader>hr` | n, v | Reset hunk |
| `<leader>hs` | n, v | Stage hunk |
| `<leader>hu` | n | Undo stage hunk |

### Image — `<leader>i`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ic` | n | Clear Images in Buffer |

### LSP — `<leader>l`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ld` | n | Document diagnostics |
| `<leader>ln` | n | Next Diagnostic |
| `<leader>lp` | n | Previous Diagnostic |
| `<leader>lr` | n | LSP References |
| `<leader>lw` | n | Workspace diagnostics |

### Markdown — `<leader>m`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>mcp` | n, v | Create a selection for pattern entered |
| `<leader>mcs` | n, v | Create a selection for selected text or word under the cursor |

### Navigate — `<leader>n`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>nD` | n | Go to Declaration |
| `<leader>nd` | n | Go to Definition |
| `<leader>nh` | n | Hover Documentation |
| `<leader>ni` | n | Find Implementations |
| `<leader>nr` | n | Find References |
| `<leader>ns` | n | Find Document Symbols |
| `<leader>nt` | n | Find Type Definitions |

### Notifications — `<leader>N`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Nd` | n | Dismiss All Notifications |
| `<leader>Nh` | n | Notification History |

### GitHub — `<leader>o`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>oA` | n | Add Comment |
| `<leader>oD` | n | Delete Comment |
| `<leader>oI` | n | Search Issues |
| `<leader>oO` | n | Open in Browser |
| `<leader>oP` | n | Search PRs |
| `<leader>oX` | n | Discard Review |
| `<leader>oa` | n | Approve |
| `<leader>ob` | n | Open PR in Browser |
| `<leader>oc` | n | Create PR |
| `<leader>od` | n | View Diff |
| `<leader>oe` | n | Open Repo in Browser |
| `<leader>of` | n | Changed Files |
| `<leader>og` | n | List Gists |
| `<leader>oi` | n | List Issues |
| `<leader>ok` | n | Checkout PR |
| `<leader>ol` | n | List Repos |
| `<leader>om` | n | Merge PR |
| `<leader>on` | n | New Issue |
| `<leader>op` | n | List PRs |
| `<leader>or` | n | Resume Review |
| `<leader>os` | n | Start Review |
| `<leader>ou` | n | Submit Comment |
| `<leader>ox` | n | Request Changes |

### Refactor — `<leader>r`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>rB` | n | Extract Block to File |
| `<leader>rI` | n | Inline Function |
| `<leader>rb` | n | Extract Block |
| `<leader>re` | v | Extract Function |
| `<leader>rf` | v | Extract to File |
| `<leader>ri` | n, v | Inline Variable |
| `<leader>rr` | n, v | Select Refactor |
| `<leader>rv` | v | Extract Variable |

### Session — `<leader>s`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>sd` | n | Delete session |
| `<leader>sl` | n | Load last session |
| `<leader>sm` | n | Open Session Manager |
| `<leader>so` | n | Load session |
| `<leader>ss` | n | Save current session |

### Toggles — `<leader>t`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tI` | n | Toggle Image Preview |
| `<leader>tT` | n | Typing Tutor |
| `<leader>tc` | n | Toggle Treesitter Context |
| `<leader>td` | n | Toggle deleted |
| `<leader>tg` | n | Toggle Harper Grammar Checker |
| `<leader>th` | n | Toggle HardTime |
| `<leader>ti` | n | Toggle Indent Guides |
| `<leader>tn` | n | Toggle Inlay Hints |
| `<leader>to` | n | Toggle Code Outline Panel |
| `<leader>tp` | n | Toggle Precognition |
| `<leader>tt` | n | Toggle Floating Terminal |
| `<leader>tu` | n | Toggle Undo Tree |
| `<leader>tv` | n | Toggle Virtual Text Diagnostics |
| `<leader>tw` | n | Toggle CursorHold Error Tooltips |
| `<leader>tz` | n | Toggle Spell Suggestion Autopopup |

### Test — `<leader>T`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Td` | n | Debug Nearest Test |
| `<leader>Tf` | n | Run Tests in File |
| `<leader>To` | n | Show Test Output |
| `<leader>Tp` | n | Toggle Test Output Panel |
| `<leader>Tr` | n | Run Nearest Test |
| `<leader>Ts` | n | Toggle Test Summary |
| `<leader>Tx` | n | Stop Test Run |

### Lists — `<leader>x`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>xl` | n | LOCList |
| `<leader>xq` | n | QuickFix |
| `<leader>xs` | n | Symbols |

### Spell — `<leader>z`

| Key | Mode | Action |
|-----|------|--------|
| `<leader>z=` | n | Show Spell Suggestions |
| `<leader>za` | n | Add Word to Dictionary |
| `<leader>zb` | n | Mark Word as Bad |
| `<leader>zf` | n | Quick Fix with First Suggestion |
| `<leader>zr` | n | Remove Word from Dictionary |
| `<leader>zs` | n | Toggle Global Spell Check |

## Direct keys (normal / visual)

| Key | Mode | Action |
|-----|------|--------|
| `#` | v | :help v_#-default |
| `&` | n | :help &-default |
| `*` | v | :help v_star-default |
| `-` | n | Open Yazi File Manager |
| `<C-W>d` | n | Show diagnostics under the cursor |
| `<CR>` | n | Accept suggestion |
| `<Esc>` | n | Clear Search Highlight |
| `<MiddleMouse>` | n | Paste from primary selection |
| `<Tab>` | v | vim.snippet.jump if active, otherwise <Tab> |
| `@` | v | :help v_@-default |
| `H` | n, v | Go to start of line |
| `K` | n | Hover Documentation |
| `L` | n, v | Go to end of line |
| `N` | n | Previous Search Match (centred) |
| `Q` | v | :help v_Q-default |
| `R` | v, o | Treesitter Search |
| `S` | n, v, o | Flash Treesitter |
| `Y` | n | :help Y-default |
| `[ ` | n | Add empty line above cursor |
| `[<C-L>` | n | :lpfile |
| `[<C-Q>` | n | :cpfile |
| `[<C-T>` | n | :ptprevious |
| `[A` | n | :rewind |
| `[B` | n | :brewind |
| `[D` | n | Jump to the first diagnostic in the current buffer |
| `[L` | n | :lrewind |
| `[N` | v | Select previous sibling node |
| `[Q` | n | :crewind |
| `[T` | n | :trewind |
| `[[` | n | Previous panel suggestion |
| `[a` | n | :previous |
| `[b` | n | Previous Buffer |
| `[c` | n | Previous hunk |
| `[d` | n | Previous Diagnostic |
| `[l` | n | :lprevious |
| `[n` | v | Select previous node |
| `[q` | n | :cprevious |
| `[s` | n | Previous Misspelled Word |
| `[t` | n | :tprevious |
| `[x` | n | Go to the next Conflict |
| `] ` | n | Add empty line below cursor |
| `]<C-L>` | n | :lnfile |
| `]<C-Q>` | n | :cnfile |
| `]<C-T>` | n | :ptnext |
| `]A` | n | :last |
| `]B` | n | :blast |
| `]D` | n | Jump to the last diagnostic in the current buffer |
| `]L` | n | :llast |
| `]N` | v | Select next sibling node |
| `]Q` | n | :clast |
| `]T` | n | :tlast |
| `]]` | n | Next panel suggestion |
| `]a` | n | :next |
| `]b` | n | Next Buffer |
| `]c` | n | Next hunk |
| `]d` | n | Next Diagnostic |
| `]l` | n | :lnext |
| `]n` | v | Select next node |
| `]q` | n | :cnext |
| `]s` | n | Next Misspelled Word |
| `]t` | n | :tnext |
| `]x` | n | Go to the previous Conflict |
| `an` | v, o | Select parent (outer) node |
| `gO` | n | vim.lsp.buf.document_symbol() |
| `gP` | n | Close All Previews |
| `gc` | n, v, o | Toggle comment |
| `gcc` | n | Toggle comment line |
| `gpd` | n | Preview Definition |
| `gpi` | n | Preview Implementation |
| `gpr` | n | Preview References |
| `gpt` | n | Preview Type Definition |
| `gr` | n | Refresh suggestion |
| `gra` | n, v | vim.lsp.buf.code_action() |
| `gri` | n | vim.lsp.buf.implementation() |
| `grn` | n | vim.lsp.buf.rename() |
| `grr` | n | vim.lsp.buf.references() |
| `grt` | n | vim.lsp.buf.type_definition() |
| `grx` | n | vim.lsp.codelens.run() |
| `gx` | n, v | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) |
| `in` | v, o | Select child (inner) node |
| `n` | n | Next Search Match (centred) |
| `r` | o | Remote Flash |
| `s` | n, v, o | Flash |

## Ctrl, Alt & function keys

| Key | Mode | Action |
|-----|------|--------|
| `<C-Bslash>` | n | Focus Previous Window/Pane |
| `<C-H>` | n | Focus Window/Pane on the Left |
| `<C-J>` | n | Focus Window/Pane Below |
| `<C-K>` | n | Focus Window/Pane Above |
| `<C-L>` | n | Focus Window/Pane on the Right |
| `<C-S>` | v | vim.lsp.buf.signature_help() |
| `<C-T>` | n | Toggle Terminal |
| `<C-W><C-D>` | n | Show diagnostics under the cursor |
| `<F10>` | n | Debug: Step Into (F10) |
| `<F11>` | n | Debug: Step Out (F11) |
| `<F12>` | n | Debug: Run to Cursor (F12) |
| `<F5>` | n | Debug: Continue (F5) |
| `<F8>` | n | Debug: Toggle Breakpoint |
| `<F9>` | n | Debug: Step Over (F9) |
| `<M-CR>` | n | Open Panel |
| `<M-h>` | n | Resize Window/Pane Left |
| `<M-j>` | n | Resize Window/Pane Down |
| `<M-k>` | n | Resize Window/Pane Up |
| `<M-l>` | n | Resize Window/Pane Right |
| `<S-F5>` | n | Debug: Terminate (S-F5) |
| `<S-F8>` | n | Debug: Clear All Breakpoints |
| `<S-F9>` | n | Debug: Toggle UI (S-F9) |
| `<S-Tab>` | v | vim.snippet.jump if active, otherwise <S-Tab> |

## Insert mode

| Key | Action |
|-----|--------|
| `"` | Closeopen action for '""' pair |
| `'` | Closeopen action for "''" pair |
| `(` | Open action for "()" pair |
| `)` | Close action for "()" pair |
| `<BS>` | MiniPairs <BS> |
| `<C-S-V>` | Paste from system clipboard |
| `<C-S>` | vim.lsp.buf.signature_help() |
| `<C-T>` | Toggle Terminal |
| `<C-U>` | :help i_CTRL-U-default |
| `<C-W>` | :help i_CTRL-W-default |
| `<C-Y>` | Copilot: trigger or accept suggestion |
| `<C-]>` | dismiss suggestion |
| `<CR>` | Smart Enter (confirm completion or newline) |
| `<M-CR>` | (panel) open |
| `<M-[>` | previous suggestion |
| `<M-]>` | next suggestion |
| `<M-l>` | Accept suggestion |
| `<MiddleMouse>` | Paste from primary selection |
| `<S-Tab>` | vim.snippet.jump if active, otherwise <S-Tab> |
| `<Tab>` | vim.snippet.jump if active, otherwise <Tab> |
| `[` | Open action for "[]" pair |
| `]` | Close action for "[]" pair |
| ``` | Closeopen action for "``" pair |
| `{` | Open action for "{}" pair |
| `}` | Close action for "{}" pair |

## Terminal mode

| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle Floating Terminal |
| `<C-T>` | Toggle terminal |
