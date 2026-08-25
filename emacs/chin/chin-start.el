;;; chin-start.el --- Startup configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Keep only the configuration needed before the first command here.

;;; Code:

(setq ring-bell-function #'ignore)
(show-paren-mode 1)

;; Match the fringe background to the default face.
(defun chin/sync-fringe-background (&optional frame)
  "Match the fringe background to the default face.

Keep the selected faces transparent on TTY frames."
  (with-selected-frame (or frame (selected-frame))
    (when (facep 'fringe)
      (set-face-attribute 'fringe frame
                          :background (face-background 'default frame)))
    (unless (display-graphic-p)
      (dolist (face '(default line-number line-number-current-line
                       hl-line secondary-selection))
        (when (facep face)
          (set-face-background face "unspecified-bg" frame))))))

(chin/sync-fringe-background)
(add-hook 'after-make-frame-functions #'chin/sync-fringe-background)
(add-hook 'tty-setup-hook #'chin/sync-fringe-background)

(defvar evil-respect-visual-line-mode)
(defvar evil-want-abbrev-expand-on-insert-exit)
(defvar evil-want-keybinding)
(defvar evil-undo-system)
(defvar evil-disable-insert-state-bindings)

(setq evil-respect-visual-line-mode t
      evil-want-abbrev-expand-on-insert-exit t
      evil-want-keybinding nil
      evil-undo-system 'undo-redo
      evil-disable-insert-state-bindings t)
(require 'evil)
(evil-mode 1)
(setq evil-mode-line-format '(before . mode-line-front-space))

(declare-function eglot-code-actions "eglot")
(declare-function eglot-rename "eglot")
(declare-function global-git-gutter-mode "git-gutter")
(declare-function global-display-line-numbers-mode "display-line-numbers")

;; Keep both indicators synchronized; an enable-only binding would leave no
;; single shortcut to turn them off together.
(defun chin/toggle-git-gutter-and-line-numbers ()
  "Toggle Git Gutter and line numbers together."
  (interactive)
  (require 'git-gutter)
  (let ((enable (not (and (bound-and-true-p global-git-gutter-mode)
                          (bound-and-true-p global-display-line-numbers-mode)))))
    (global-git-gutter-mode (if enable 1 -1))
    (global-display-line-numbers-mode (if enable 1 -1))
    (message "%s Git Gutter and line numbers"
             (if enable "Enabled" "Disabled"))))

(defvar-keymap chin/evil-find-map
  :doc "Leader bindings for finding files and text."
  "b" #'consult-buffer
  "f" #'find-file
  "g" #'consult-ripgrep
  "l" #'consult-line)

(defvar-keymap chin/evil-buffer-map
  :doc "Leader bindings for buffers."
  "b" #'consult-buffer
  "d" #'kill-current-buffer)

(defvar-keymap chin/evil-code-map
  :doc "Leader bindings for code actions."
  "a" #'eglot-code-actions
  "r" #'eglot-rename)

(defvar-keymap chin/evil-leader-map
  :doc "Leader keymap used from Evil normal state."
  "?" #'describe-prefix-bindings
  "b" chin/evil-buffer-map
  "c" chin/evil-code-map
  "f" chin/evil-find-map
  "l" #'chin/toggle-git-gutter-and-line-numbers
  "q" #'quit-window
  "w" #'save-buffer
  "x" #'kill-current-buffer)

(evil-define-key 'normal 'global
  (kbd "SPC") chin/evil-leader-map
  (kbd "C-e") #'end-of-line
  (kbd "C-r") #'isearch-backward
  (kbd "g d") #'xref-find-definitions
  (kbd "g r") #'xref-find-references
  (kbd "K") #'eldoc-doc-buffer
  (kbd "U") #'evil-redo
  (kbd "M-.") #'xref-find-definitions)
(evil-define-key 'visual 'global
  (kbd "DEL") #'delete-region)

(defun chin/load-stage-file (file)
  "Load staged configuration FILE from `user-emacs-directory'."
  (load (expand-file-name file user-emacs-directory) nil t t))

(defvar chin/first-second-startup-delay 1.0
  "Idle seconds before loading the first-second stage.")

(defvar chin/first-second-startup-timer nil)

(defun chin/load-first-second ()
  "Load configuration deferred until the first idle second."
  (setq chin/first-second-startup-timer nil)
  (chin/load-stage-file "chin/chin-first-second.el"))

(defun chin/schedule-first-second ()
  "Schedule the first-second configuration stage."
  (unless chin/first-second-startup-timer
    (setq chin/first-second-startup-timer
          (run-with-idle-timer chin/first-second-startup-delay nil
                               #'chin/load-first-second))))

(add-hook 'emacs-startup-hook #'chin/schedule-first-second)

(defvar chin/first-call-loaded nil)

(defun chin/load-first-call ()
  "Load the remaining interactive configuration before the first command."
  (unless chin/first-call-loaded
    (chin/load-stage-file "chin/chin-first-call.el")
    (setq chin/first-call-loaded t)
    (remove-hook 'pre-command-hook #'chin/load-first-call)))

(add-hook 'pre-command-hook #'chin/load-first-call)

(provide 'chin-start)
;;; chin-start.el ends here
