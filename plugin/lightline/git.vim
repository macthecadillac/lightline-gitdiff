" TODO: implement job-kill to prevent racing in rare situations

" initialize global variables
let s:indicator_added = get(g:, 'lightline#git#indicator_added','+')
let s:indicator_modified = get(g:, 'lightline#git#indicator_modified', '!')
let s:indicator_deleted = get(g:, 'lightline#git#indicator_deleted', '-')
let s:min_winwidth = get(g:, 'lightline#git#min_winwidth', 70)
let s:file_whitelist = {}

augroup lightline#git
  autocmd!
  autocmd BufEnter * call s:query_git()
  autocmd BufWrite * call s:query_git()
augroup END

function! s:job_stdout(job_id, data, event) dict
  " Couldn't get 'join' to insert linebreaks so '\n' is my token
  " for line breaks. The chance of it appearing in actual programs is
  " minimal
  let l:self.stdout = l:self.stdout . join(a:data, '\n')
endfunction

function! s:job_stderr(job_id, data, event) dict
  let l:self.stderr = l:self.stderr . join(a:data, '\n')
endfunction

function! s:job_exit(job_id, data, event) dict
  call s:update_status(l:self)
endfunction

function! s:query_git()
  let l:filename = expand('%:f')
  if l:filename !=# ''
    let l:cmd = 'git diff --stat --word-diff=porcelain ' .
    \           '--no-color --no-ext-diff -U0 -- ' . l:filename
    let l:callbacks = {
    \   'on_stdout': function('s:job_stdout'),
    \   'on_stderr': function('s:job_stderr'),
    \   'on_exit': function('s:job_exit')
    \ }
    let l:job_id = jobstart(l:cmd, extend({'stdout': '', 'stderr': ''},
    \                                     l:callbacks))
  endif
endfunction

function! s:modified_count(hunks)
  let l:modified = 0
  for l:hunk in a:hunks
    for l:line in split(l:hunk, '\~')
      let l:plus = 0
      let l:minus = 0
      for l:chunk in split(l:line, '\\n')
        let l:firstchar  = l:chunk[0]
        if l:firstchar ==# '+'
          let l:plus = l:plus + 1
        elseif l:firstchar ==# '-'
          let l:minus = l:minus + 1
        endif
      endfor
      if l:plus !=# 0 && l:minus !=# 0
        let l:modified = l:modified + 1
      endif
    endfor
  endfor
  return l:modified
endfunction

function! s:str2nr(str)
  return empty(str2nr(a:str)) ? 0 : str2nr(a:str)
endfunction

function! s:track_file(git_raw_output)
  " file not in repository
  if a:git_raw_output.stderr !=# ''
    return 0
  else
    " return 0 if file in repo but not tracked
    return a:git_raw_output.stdout !=# '' ? 1 : 0
  endif
endfunction

function! s:update_status(git_raw_output)
  let l:curr_full_path = expand('%:p')
  let s:file_whitelist[l:curr_full_path] = s:track_file(a:git_raw_output)

  if s:file_whitelist[l:curr_full_path] ==# 1
    let l:split_diff = split(a:git_raw_output.stdout, '@@')
    let l:nhunks = (len(l:split_diff) - 1) / 2

    let l:header = l:split_diff[0]
    let l:hunks = []
    for l:idx in range(1, l:nhunks)
      call add(l:hunks, l:split_diff[2 * l:idx])
    endfor

    let l:modified = s:modified_count(l:hunks)
    let l:change_summary = split(l:header, '\\n')[1]
    let l:regex = '\v[^,]+, ((\d+) [a-z]+\(\+\)[, ]*)?((\d+) [a-z]+\(-\))?'
    let l:matched =  matchlist(l:change_summary, l:regex)
    let l:insertions = s:str2nr(l:matched[2])
    let l:deletions = s:str2nr(l:matched[4])
    let l:added = l:insertions - l:modified
    let l:deleted = l:deletions - l:modified
    let b:lightline_git_status = [l:added, l:modified, l:deleted]
  endif
  call lightline#update()
endfunction

function! lightline#git#get_status()
  if !has_key(b:, 'lightline_git_status')
    let b:lightline_git_status = [0, 0, 0]
  endif
  let [l:added, l:modified, l:deleted] = b:lightline_git_status
  let l:curr_full_path = expand('%:p')
  if get(s:file_whitelist, l:curr_full_path) && winwidth(0) > s:min_winwidth
    return s:indicator_added . ' ' . l:added . ' ' .
    \      s:indicator_modified . ' ' . l:modified . ' ' .
    \      s:indicator_deleted . ' ' . l:deleted
  else
    return ''
  endif
endfunction
