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

Options (add a `-` just after the `:` to negate those characters in the match):

* `g:angulester_match`, `g:angulester_<runner_type>_match`: Modified version of a `substitute`-compatible string for finding the spec file from the tested file, and vice-versa. These are in the form `/<file_path>/<spec_path>/`, where `<file_path>` is how to get to the tested file from the spec file, and `<spec_path>` is how to get to the spec file from the tested file. Either can be omitted, in which case Angulester will try to apply the oppsite operation to the other's path. Slashes, braces (`{}`), and characters special to `vim` must be escaped with a backslash. If both are omitted, Angulester will try to find a file in the same folder as the edited file. Angulester will use `g:angulester_ext`: if the currently-edited file has that extension, the matched file will not, and vice versa. If this variable is empty and the match points to a file in the same directory with the same name, Angulester will not test with the test runner unless `g:angulester_always_run` is true.
Each matcher can have 2 types of tokens:
  * `{file}`: Current filename without extension
  * `{path}`: File path, relative to the CWD.
Examples:
`///` (default): Editing either `app.js` or `app.spec.js` will test both of these files.
`//spec\/{path}`: Editing either `app/index.js` or `spec/index.spec.js` will include both files in the test run.
`//spec\/{path}/{file}/spec`: Editing either `app/tested.js` or `spec/app/tested/spec.js` will pull the other file into the test.
`//spec\/{path}/{path}/{path}.../{file}/spec`: Editing either `app/tested.js` or `spec/app/app/app/.../tested/spec.js` will use both files in the test.

* `g:angulester_glob`, `g:angulester_<runner_type>_glob`: Glob for more files. This can be used to get files that contain depended-upon modules: even though it is possible to mock these, this is a slow, error-prone process. There are plugins to make this easier.

* `g:angulester_always_run`, `g:angulester_<runner_type>_always_run`: Run the test, even if Angulester can not find another file with `g:angulester_match`, or if the other file found is the same file.
