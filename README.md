# flymake-biome

Flymake plugin to run a linter for JS buffers using [biome](https://biomejs.dev)

## Installation

### Cloning the repo

Clone this repo somewhere, and add this to your config:

```elisp
(add-to-list 'load-path "path where the repo was cloned")

(require 'flymake-biome)
(add-hook 'js-mode-hook #'flymake-biome-load)
```

### Using straight.el

```emacs-lisp
(use-package flymake-biome
  :straight (flymake-biome
             :type git
             :host github
             :repo "erickgnavar/flymake-biome"))
```
