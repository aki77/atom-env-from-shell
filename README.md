# env-from-shell package

Make Atom use the $PATH set up by the user's shell.
[![Build Status](https://travis-ci.org/aki77/atom-env-from-shell.svg)](https://travis-ci.org/aki77/atom-env-from-shell)

Inspired by [exec-path-from-shell.el](https://github.com/purcell/exec-path-from-shell)

## Settings

* `variables`: List of environment variables which are copied from the shell.(default: `['PATH']`)
* `autoRun`: [auto-run](https://atom.io/packages/auto-run) package is required.(default: `false`)

[![Gyazo](http://i.gyazo.com/d8fcc7c6e830e55735dc9f8fa5aa30a8.png)](http://gyazo.com/d8fcc7c6e830e55735dc9f8fa5aa30a8)

## Commands

* `env-from-shell:copy`
* `env-from-shell:reset`

## Similar packages

* [atomenv](https://atom.io/packages/atomenv)
