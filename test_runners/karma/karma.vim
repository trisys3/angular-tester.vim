if exists('g:loaded_angulester_karma_runner')
  finish
endif
let g:loaded_angulester_karma_runner = 1

let g:angulester_default_karma_errorformat =
  \ '%-G,'

let g:angulester_karma_runner = system('node karma-runner')
