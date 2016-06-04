" quit if already loaded
if exists('g:loaded_angulester_plugin')
  finish
endif
let g:loaded_angulester_plugin = 1

" Default runners for each filetype
" At some point, these should maybe be put into another file
let s:default_runners = {'javascript': 'karma', 'ruby': 'rspec'}

echo &filetype

if !exists('g:angulester_runner')
  if exists('s:default_runners[&filetype]')
    let g:angulester_runner = s:default_runners[&filetype]
  else
    " if we do not have a runner type yet, finish
    " TODO: Add some more autocmds before this so we can source the file if
    " a filetype/plugin is found
    finish
  endif
endif

" user commands
command! -nargs=* AngulesterTest call AngulesterTest(<f-args>)
" command! -nargs=? AngulesterInfo call AngulesterInfo(<f-args>)

" public functions, callable by other scripts or Ex commands

" do the test
function! AngulesterTest(...) abort
  let runner = g:angulester_runner

  if AngulesterFileIsSpec
    let regular_file = @%

    if !exists('g:angulester_{&filetype}_{runner}_spec_sub')
      let g:angulester_{&filetype}_{runner}_spec_sub = ''
    endif

    let spec_sub = split(g:angulester_{&filetype}_{runner}_spec_sub, '/')
    if len(spec_sub) > 1
      let spec_regex = spec_sub[0]
      let spec_replace = spec_sub[1]
    elseif len(spec_sub)
      let spec_regex = spec_sub[0]
      let spec_replace = ''
    else
      let spec_regex = ''
      let spec_replace = ''
    endif

    let spec_file = substitute(@%, spec_regex, spec_replace, '')
  else
    let spec_file = @%

    if !exists('g:angulester_{&filetype}_{runner}_regular_sub')
      let g:angulester_{&filetype}_{runner}_regular_sub = ''
    endif

    let regular_sub = split(g:angulester_{&filetype}_{runner_}regular_sub, '/')
    if len(regular_sub) > 1
      let regular_regex = regular_sub[0]
      let regular_replace = regular_sub[1]
    elseif len(regular_sub)
      let regular_regex = regular_sub[0]
      let regular_replace = ''
    else
      let regular_regex = ''
      let regular_replace = ''
    endif

    let regular_file = substitute(regular_regex, regular_replace, '')
  endif
endfunction

function! AngulesterFileIsSpec()
  " force file to be a spec, should only be set by users & other plugins
  if g:angulester_is_spec || g:angulester_{&filetype}_{runner}_is_spec
    return 1
  endif
  " force file to not be a spec, see disclaimer above
  if g:angulester_is_not_spec || g:angulester_{&filetype}_{runner}_is_not_spec
    return
  endif

  if match(@%, g:angulester_{&filetype}_{runner}_spec_regex != -1)
    return 1
  endif
endfunction

" get all 'valid' messages from an expression, according to the location list
function! AngulesterGetValid(errors) abort
  let filterStr = 'v:val["valid"] == 1'

  lgetexpr a:errors
  let locListErrors = getloclist(0)

  let validErrors = filter(locListErrors, filterStr)

  " re-set the location list to the last version the user had
  try
    silent lolder
  catch
  endtry

  return validErrors
endfunction

" Set the location list with the errors we get
function! AngulesterSetLocList(errors) abort
  let errors = AngulesterGetValid(a:errors)

  call setloclist(0, errors, 'r')

  " allow for chaining
  return errors
endfunction

function! AngulesterGetTestPrgs()
  if !exists('g:angulester_tester_types')
    let g:angulester_tester_types = []
  endif

  for tester in g:angulester_tester_types
    execute 'runtime! plugin/test_runners/' . &filetype . '/' . tester . '.vim'
  endfor
endfunction
