# angular-tester.vim #
A more flexible Angular tester plugin for vim

## Rationale ##
I couldn't find any good Angular plugins for vim related to testing, so I made my own. It is still very much a work in progress, so please keep in mind that things may break or act strangely at any time.

## Test Runner Support ##
This plugin currently supports karma and protractor, only with regards to Angular. If anyone wants to contribute and add in support for other frameworks, please feel free. Otherwise, I will do this when I can.

## Karma ##
Runs karma with the configuration file given by `g:angulester_karma_conf`, which defaults to karma.conf.js, in the cwd or above.

## Protractor ##
Runs protractor with the configuration file given by `g:angulester_protractor_conf`, which defaults to protractor.conf.js, in the cwd or above.
