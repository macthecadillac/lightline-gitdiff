" TODO: implement job-kill to prevent racing in rare situations

" initialize global variables
let g:indicator_added = get(g:, 'lightline_gitdiff#indicator_added','+')
let g:indicator_modified = get(g:, 'lightline_gitdiff#indicator_modified', '!')
let g:indicator_deleted = get(g:, 'lightline_gitdiff#indicator_deleted', '-')
let g:min_winwidth = get(g:, 'lightline_gitdiff#min_winwidth', 70)
let g:file_whitelist = {}

augroup lightline#git
  autocmd!
  autocmd BufEnter * call lightline_gitdiff#query_git()
  autocmd BufWrite * call lightline_gitdiff#query_git()
augroup END
