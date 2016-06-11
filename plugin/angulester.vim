" quit if already loaded
if exists('g:loaded_angulester_plugin')
  finish
endif
let g:loaded_angulester_plugin = 1

let s:default_runners = {'javascript': 'karma'}

if !exists('g:angulester_is_spec')
  let g:angulester_is_spec = 0
endif
if !exists('g:angulester_is_not_spec')
  let g:angulester_is_not_spec = 0
endif

" user commands
command! -nargs=* AngulesterTest call AngulesterTest(<f-args>)
" command! -nargs=? AngulesterInfo call AngulesterInfo(<f-args>)

" public functions, callable by other scripts or Ex commands

" do the test
function! AngulesterTest(...) abort
  if a:0 >= 1
    let filename = a:1
  else
    let filename = @%
  endif
  let runner = s:GetRunners()
  let regular_file = s:GetRegularFile()
  let spec_file = s:GetSpecFile()
endfunction

function! s:GetSpecFile(...)
  let runner = s:GetRunners()

  if a:0 >= 1
    let filename = a:1
  else
    let filename = @%
  endif

  if !s:FileIsSpec(filename)
    return filename
  endif

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

  return substitute(filename, spec_regex, spec_replace, '')
endfunction

function s:GetRegularFile(...)
  let runner = s:GetRunners()

  if a:0 >= 1
    let filename = a:1
  else
    let filename = @%
  endif

  if s:FileIsSpec(filename)
    return filename
  endif

  if !exists('g:angulester_{&filetype}_{runner}_regular_sub')
    let g:angulester_{&filetype}_{runner}_regular_sub = ''
  endif

  let regular_sub = split(g:angulester_{&filetype}_{runner}_regular_sub, '/')
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

  return substitute(filename, regular_regex, regular_replace, '')
endfunction

function! s:FileIsSpec(...)
  let runner = s:GetRunners()

  if a:0
    let filename = a:1
  else
    let filename = @%

    " force file to be a spec, should only be set by users & other plugins
    if g:angulester_is_spec
      return 1
    endif
    " force file to not be a spec, see disclaimer above
    if g:angulester_is_not_spec
      return
    endif
  endif

  if !exists('g:angulester_{&filetype}_{runner}_spec_regex')
    let g:angulester_{&filetype}_{runner}_spec_regex = '/\.spec/'
  endif

  if match(filename, g:angulester_{&filetype}_{runner}_spec_regex) != -1
    return 1
  endif
endfunction

" get all 'valid' messages from an expression, according to the location list
function! s:GetValid(errors) abort
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
function! s:SetLocList(errors) abort
  let errors = AngulesterGetValid(a:errors)

  call setloclist(0, errors, 'r')

  " allow for chaining
  return errors
endfunction

function! s:GetTestPrgs()
  if !exists('g:angulester_tester_types')
    let g:angulester_tester_types = []
  endif

  for tester in g:angulester_tester_types
    execute 'runtime! plugin/test_runners/' . &filetype . '/' . tester . '.vim'
  endfor
endfunction

function! s:GetRunners()
  " sometimes vim does not detect the filetype or detects it wrong
  " or plugin managers like vundle require turning it off first,
  " so detect it manually just in case
  filetype detect

  " TODO: Investigate caching default_runners
  if exists('s:default_runners[&filetype]')
    let runners = s:default_runners[&filetype]
  else
    let runners = []
  endif

  return runners
endfunction
