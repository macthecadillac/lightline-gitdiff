" TODO: implement job-kill to prevent racing in rare situations

" initialize global variables
let g:lightline_gitdiff#indicator_added = get(g:, 'lightline_gitdiff#indicator_added', '+')
let g:lightline_gitdiff#indicator_modified = get(g:, 'lightline_gitdiff#indicator_modified', '!')
let g:lightline_gitdiff#indicator_deleted = get(g:, 'lightline_gitdiff#indicator_deleted', '-')
let g:lightline_gitdiff#indicator_pad = get(g:, 'lightline_gitdiff#indicator_pad', v:true)
let g:lightline_gitdiff#indicator_hide_zero = get(g:, 'lightline_gitdiff#indicator_hide_zero', v:false)
let g:lightline_gitdiff#min_winwidth = get(g:, 'lightline_gitdiff#min_winwidth', 70)
let g:lightline_gitdiff#cmd_general_delay = get(g:, 'lightline_gitdiff#cmd_general_delay', 0.01)
let g:lightline_gitdiff#cmd_first_write_delay = get(g:, 'lightline_gitdiff#cmd_first_write_delay', 0.5)
let g:lightline_gitdiff#file_whitelist = {}

augroup lightline#git
  autocmd!
  autocmd BufEnter * call lightline_gitdiff#query_git_bufenter()
  autocmd BufWrite * call lightline_gitdiff#query_git_bufwrite()
augroup END
