# Lightline-gitdiff

A minimalistic addon to the great lightline plugin to show a concise summary of
changes since the last commit.

## Requirements

#### Git

Lightline-gitdiff is known to work with git 2.11 or above. This plugin was
tested on Debian 9 and testing. Older versions of git should work but that is
not guaranteed.

#### Neovim

This plugin uses Neovim's job-control API but in theory it should also work with
Vim8 with some minor modifications.

#### [Lightline](https://github.com/itchyny/lightline.vim)

## Installation

[vim-plug](https://github.com/junegunn/vim-plug)

Add the following line to your `init.vim`

```vim
Plug 'macthecadillac/lightline-gitdiff'
```

## Configuration

### Available configuration options

```vim
let g:lightline_gitdiff#indicator_added = '+'
let g:lightline_gitdiff#indicator_deleted = '-'
let g:lightline_gitdiff#indicator_modified = '!'
let g:lightline_gitdiff#min_winwidth = '70'
```

These defaults could be overridden in your `init.vim`.

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
