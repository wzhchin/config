;;; chin-first-second.el --- One-second idle configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Load visual feedback after startup has been idle for one second.

;;; Code:

;; Emacs 31 ships which-key, so it does not belong in the ELPA-only package
;; path list in `init.el`.
(require 'which-key)
(which-key-mode 1)

(require 'git-gutter)
(global-git-gutter-mode 1)

(provide 'chin-first-second)
;;; chin-first-second.el ends here
