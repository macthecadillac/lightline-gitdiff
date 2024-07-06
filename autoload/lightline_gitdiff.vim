function! s:job_stdout(job_id, data, event) dict
  let l:self.stdout = l:self.stdout + a:data
endfunction

function! s:job_stderr(job_id, data, event) dict
  let l:self.stderr = l:self.stderr + a:data
endfunction

function! s:job_exit(job_id, data, event) dict
  call s:update_status(l:self)
endfunction

function! lightline_gitdiff#query_git(delay)
  let l:filename = expand('%:f')
  if l:filename !=# ''
    " delay 0.5s before calling git since vim's first write is slow
    let l:cmd = 'sleep ' . a:delay . '; git diff --stat --word-diff=porcelain ' .
    \           '--no-color --no-ext-diff -U0 -- ' . l:filename
    if has('nvim')
      let l:callbacks = {
      \   'on_stdout': function('s:job_stdout'),
      \   'on_stderr': function('s:job_stderr'),
      \   'on_exit': function('s:job_exit')
      \ }
      let l:job_id = jobstart(l:cmd, extend({'stdout': [], 'stderr': []},
      \                                     l:callbacks))
    else
      let l:git_raw_output = {'stdout': split(system(l:cmd), "\n"), 'stderr': ['']}
      call s:update_status(l:git_raw_output)
    endif
  endif
endfunction

function! s:modified_count(stdout)
  let l:modified = 0
  let l:plus = 0
  let l:minus = 0
  let l:blank = 0
  let l:counting = 0  " true/false (are we supposed to count the current line?)

  for l:output_line in a:stdout
    let l:firstchar = l:output_line[0]

    " start counting after the first '@' mark
    if l:firstchar ==# '@' && l:counting ==# 0
      let l:counting = 1
    elseif l:firstchar ==# '+' && l:counting ==# 1
      let l:plus = l:plus + 1
    elseif l:firstchar ==# '-' && l:counting ==# 1
      let l:minus = l:minus + 1
    elseif l:firstchar ==# ' ' && l:counting ==# 1
      let l:blank = l:blank + 1
    " determine if a line was added/deleted/modified at the end of a line
    elseif l:firstchar ==# '~' && l:counting ==# 1
      if l:blank !=# 0
        let l:modified = l:modified + 1
      elseif l:plus !=# 0 && l:minus !=# 0
        let l:modified = l:modified + 1
      endif

      " reset counters at the end of each line
      let l:plus = 0
      let l:minus = 0
      let l:blank = 0
    endif
  endfor

  return l:modified
endfunction

function! s:str2nr(str)
  return empty(str2nr(a:str)) ? 0 : str2nr(a:str)
endfunction

function! s:whitelist_file(git_raw_output)
  " We need to cover both [] and [''] because, due to reasons unbeknownst to me,
  " git returns [] or [''] on different machines
  " if file in repository
  if a:git_raw_output.stderr ==# [] || a:git_raw_output.stderr ==# ['']
    " if file in repo but not tracked stdout is empty
    return !(a:git_raw_output.stdout ==# [] || a:git_raw_output.stdout ==# [''])
  else
    return v:false
  endif
endfunction

function! s:update_status(git_raw_output)
  try
    let l:curr_full_path = expand('%:p')
    let g:lightline_gitdiff#file_whitelist[l:curr_full_path] = s:whitelist_file(a:git_raw_output)

    if g:lightline_gitdiff#file_whitelist[l:curr_full_path]
      let l:modified = s:modified_count(a:git_raw_output.stdout)
      let l:change_summary = a:git_raw_output.stdout[1]
      let l:regex = '\v[^,]+, ((\d+) [a-z]+\(\+\)[, ]*)?((\d+) [a-z]+\(-\))?'
      let l:matched =  matchlist(l:change_summary, l:regex)
      let l:insertions = s:str2nr(l:matched[2])
      let l:deletions = s:str2nr(l:matched[4])
      let l:added = l:insertions - l:modified
      let l:deleted = l:deletions - l:modified

      " a partial fix for edge cases where the git internal word-diff algorithm
      " goes wrong. At least now the function will never return negative numbers
      " in any circumstances.
      if l:added <# 0 || l:deleted <# 0
        let l:negativity = min([l:added, l:deleted])
        let l:added = l:added - l:negativity
        let l:deleted = l:deleted - l:negativity
        let l:modified = l:modified + l:negativity
      endif

      let b:lightline_git_status = [l:added, l:modified, l:deleted]
    endif
  catch
    return
  endtry
  call lightline#update()
endfunction

function! s:pad_item(item)
  return g:lightline_gitdiff#indicator_pad ? ' ' . a:item : a:item
endfunction

function! lightline_gitdiff#query_git_bufenter()
  call lightline_gitdiff#query_git(g:lightline_gitdiff#cmd_general_delay)
endfunction

function! lightline_gitdiff#query_git_bufwrite()
  if get(g:, 'lightline_gitdiff#first_write', v:true)
    call lightline_gitdiff#query_git(g:lightline_gitdiff#cmd_first_write_delay)
    let g:lightline_gitdiff#first_write = v:false
  else
    call lightline_gitdiff#query_git(g:lightline_gitdiff#cmd_general_delay)
  end
endfunction

function! lightline_gitdiff#get_status()
  if !has_key(b:, 'lightline_git_status')
    let b:lightline_git_status = [0, 0, 0]
  endif
  let [l:added, l:modified, l:deleted] = b:lightline_git_status
  let l:curr_full_path = expand('%:p')
  if get(g:lightline_gitdiff#file_whitelist, l:curr_full_path) && winwidth(0) > g:lightline_gitdiff#min_winwidth
    if g:lightline_gitdiff#indicator_hide_zero
      let l:status = ''
      if l:added != 0
        let l:status = g:lightline_gitdiff#indicator_added . s:pad_item(l:added)
      endif
      if l:modified != 0
        if l:status !=# ''
          let l:status = l:status . ' '
        end
        let l:status = l:status . g:lightline_gitdiff#indicator_modified . s:pad_item(l:modified)
      endif
      if l:deleted != 0
        if l:status !=# ''
          let l:status = l:status . ' '
        end
        let l:status = l:status . g:lightline_gitdiff#indicator_deleted . s:pad_item(l:deleted)
      endif
      return l:status
    else
      return g:lightline_gitdiff#indicator_added . s:pad_item(l:added) . ' ' .
      \      g:lightline_gitdiff#indicator_modified . s:pad_item(l:modified) . ' ' .
      \      g:lightline_gitdiff#indicator_deleted . s_pad_item(l:deleted)
    endif
  else
    return ''
  endif
endfunction

function! lightline_gitdiff#init()
  call lightline_gitdiff#query_git_bufenter()
  let g:lightline#gitdiff#loaded = v:true
endfunction
