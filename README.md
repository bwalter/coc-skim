
This is a fork of [coc-fzf.vim](https://github.com/antoinemadec/coc-fzf)
but for [skim](https://github.com/lotabout/skim). Everything should work out
of the box with skim.

ALL THE FOLLOWING ARE COC-FZF's DOC.

---

fzf :heart: coc.nvim
===============

Use [FZF][fzf] instead of [coc.nvim][coc.nvim] built-in fuzzy finder.

![](https://raw.githubusercontent.com/antoinemadec/gif/master/coc_fzf.gif)

Rationale
---------

This plugin uses [FZF][fzf] fuzzy finder in place of [Coc][coc.nvim]'s built-in [CocList sources][coc_sources].
It makes the interaction with Coc easier when you are used to FZF.

The main features are:
- FZF preview
- FZF bindings for splits and tabs
- FZF layout (floating windows etc)
- FZF multi-select to populate the quickfix window

It was inspired by [Robert Buhren's functions][RobertBuhren] and [coc-denite][coc_denite].

Installation
---------

Make sure to have the following plugins in your **vimrc**:
```vim
Plug 'coc.nvim',
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/coc-fzf'
```

Commands
---------

| Command                                 | List                                                                 | Preview | Multi-select | Vim support |
| ---                                     | ---                                                                  | ---     | ---          | ---         |
| `:CocFzfList        `                   | Equivalent to :CocList                                               | -       | -            | ✅          |
| `:CocFzfList actions`                   | Equivalent to :CocList actions                                       | -       | -            | ✅          |
| `:CocFzfList commands`                  | Equivalent to :CocList commands                                      | -       | -            | ✅          |
| `:CocFzfList diagnostics`               | Equivalent to :CocList diagnostics                                   | ✅      | ✅           | ✅          |
| `:CocFzfList diagnostics --current-buf` | Equivalent to :CocList diagnostics in the current buffer only        | ✅      | ✅           | ✅          |
| `:CocFzfList extensions`                | Equivalent to :CocList extensions                                    | -       | -            | ✅          |
| `:CocFzfList location`                  | Equivalent to :CocList location. Requires [fzf.vim][skimvim]          | ✅      | ✅           | ✅          |
| `:CocFzfList outline`                   | Equivalent to :CocList outline, with colors. Requires [ctags][ctags] | -       | ✅           | ✅          |
| `:CocFzfList symbols`                   | Equivalent to :CocList symbols                                       | ✅      | ✅           | ❌          |
| `:CocFzfList symbols --kind {kind}`     | Equivalent to :CocList symbols -kind {kind}                          | ✅      | ✅           | ❌          |
| `:CocFzfList services`                  | Equivalent to :CocList services                                      | -       | -            | ✅          |
| `:CocFzfList yank`                      | Equivalent to :CocList yank. Requires [coc-yank][coc-yank]           | ✅      | ✅           | ✅          |
| `:CocFzfListResume`                     | Equivalent to :CocListResume                                         | -       | -            | ✅          |

FZF bindings (default):
- **ctrl-t**: open in tab
- **ctrl-x**: open in vertical split
- **ctrl-s**: open in horizontal split
- **tab**: multi-select, populate quickfix window
- **?**: toggle preview window

Options
---------

| Option                         | Type   | Description                                                    | Default value               |
| ---                            | ---    | ---                                                            | ---                         |
| `g:coc_fzf_preview_toggle_key` | string | Change the key to toggle the preview window                    | `'?'`                       |
| `g:coc_fzf_preview`            | string | Change the preview window position                             | `'up:50%'`                  |
| `g:coc_fzf_opts`               | array  | Pass additional parameters to skim, e.g. `['--layout=reverse']` | `['--layout=reverse-list']` |

Vimrc Example
---------
```vim
nnoremap <silent> <space>a  :<C-u>CocFzfList diagnostics<CR>
nnoremap <silent> <space>b  :<C-u>CocFzfList diagnostics --current-buf<CR>
nnoremap <silent> <space>c  :<C-u>CocFzfList commands<CR>
nnoremap <silent> <space>e  :<C-u>CocFzfList extensions<CR>
nnoremap <silent> <space>l  :<C-u>CocFzfList location<CR>
nnoremap <silent> <space>o  :<C-u>CocFzfList outline<CR>
nnoremap <silent> <space>s  :<C-u>CocFzfList symbols<CR>
nnoremap <silent> <space>S  :<C-u>CocFzfList services<CR>
nnoremap <silent> <space>p  :<C-u>CocFzfListResume<CR>
```

FAQ
---------

**Q**: How to get the FZF floating window?
**A**: You can look at [FZF Vim integration][fzf_vim_integration]:
```vim
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
```
**Q**: CocFzf looks different from my other Skim commands. How to make it the same?
**A**: By default, CocFzf tries to mimic CocList. Here is how to change this:
```vim
let g:coc_fzf_preview = ''
let g:coc_fzf_opts = []
```

License
-------

MIT

[fzf]:                 https://github.com/junegunn/skim
[fzf_vim_integration]: https://github.com/junegunn/skim/blob/master/README-VIM.md
[coc.nvim]:            https://github.com/neoclide/coc.nvim
[coc_sources]:         https://github.com/neoclide/coc.nvim/wiki/Using-coc-list#builtin-list-sources
[RobertBuhren]:        https://gist.github.com/RobertBuhren/02e05506255c667c0038ce74ee1cef96
[coc_denite]:          https://github.com/neoclide/coc-denite
[ctags]:               https://github.com/universal-ctags/ctags
[fzfvim]:              https://github.com/junegunn/skim.vim
[coc-yank]:            https://github.com/neoclide/coc-yank
