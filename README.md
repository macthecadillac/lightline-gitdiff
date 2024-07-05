# Lightline-gitdiff

A minimalistic addon to the great lightline plugin to show a concise summary of
changes since the last commit.

## TODO
- [ ] Make compatible with vim8 async features

## Requirements

#### Git

Lightline-gitdiff is known to work with git 2.11 or above. This plugin was
tested on Debian 9 and testing. Older versions of git should work but that is
not guaranteed.

This plugin uses Neovim's job-control API if neovim is detected. Calls to `git`
are otherwise synchronous. Note that the plugin might lag on write/load if your
shell is set to `fish` and that `has('nvim')` is `0`. Work with vim8's async
features is planned.

#### [Lightline](https://github.com/itchyny/lightline.vim)

## Installation

[vim-plug](https://github.com/junegunn/vim-plug)

Add the following line to your `init.vim`/`.vimrc`

```vim
Plug 'macthecadillac/lightline-gitdiff'
```

## Configuration

### Available configuration options

```vim
" mostly cosmetic settings
let g:lightline_gitdiff#indicator_added = '+'
let g:lightline_gitdiff#indicator_modified = '!'
let g:lightline_gitdiff#indicator_deleted = '-'
" disable diff stats if the window width is less than this number
let g:lightline_gitdiff#min_winwidth = 70
" add a space between the indicator and the diff count
let g:lightline_gitdiff#indicator_pad = v:true
" hide indicators that read zero
let g:lightline_gitdiff#indicator_hide_zero = v:false
" in case vim did not finish writing the file before we call git-diff
let g:lightline_gitdiff#cmd_general_delay = 0.01
" vim often takes longer on first write
let g:lightline_gitdiff#cmd_first_write_delay = 0.5
```

These defaults could be overridden in your configurations.

To integrate with lightline, use `lightline_gitdiff#get_status()` as the hook.

### Example configuration

```vim

let g:lightline = {
  \   'active': {
  \     'left': [['mode', 'paste'],
  \              ['gitbranch', 'gitstatus', 'filename']],
  \   },
  \   'component': {
  \     'gitstatus': '%<%{lightline_gitdiff#get_status()}',
  \   },
  \   'component_visible_condition': {
  \     'gitstatus': 'lightline_gitdiff#get_status() !=# ""',
  \   },
  \ }

```

## License

MIT
