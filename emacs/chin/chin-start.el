;;; chin-start.el --- Startup configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Keep only the configuration needed for the initial frame here.  Heavier
;; packages are initialized by an idle timer and before the first command.

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

(defvar chin/evil-initialized nil)

(declare-function eglot-code-actions "eglot")
(declare-function eglot-rename "eglot")
(declare-function global-git-gutter-mode "git-gutter")
(declare-function global-display-line-numbers-mode "display-line-numbers")
(declare-function evil-define-key* "evil")
(declare-function evil-mode "evil")

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

(defun chin/initialize-evil ()
  "Load Evil and install its global configuration once."
  (unless chin/evil-initialized
    (require 'evil)
    (evil-mode 1)
    (setq evil-mode-line-format '(before . mode-line-front-space))
    ;; Call the function behind `evil-define-key' so this file can be loaded
    ;; before Evil itself is available.
    (evil-define-key* 'normal 'global
      (kbd "SPC") chin/evil-leader-map
      (kbd "C-e") #'end-of-line
      (kbd "C-r") #'isearch-backward
      (kbd "g d") #'xref-find-definitions
      (kbd "g r") #'xref-find-references
      (kbd "K") #'eldoc-doc-buffer
      (kbd "U") #'evil-redo
      (kbd "M-.") #'xref-find-definitions)
    (evil-define-key* 'visual 'global
      (kbd "DEL") #'delete-region)
    (setq chin/evil-initialized t)))

;; Let the first idle cycle pay for Evil instead of the startup path.  The
;; first-command hook below is a synchronous fallback for an immediate input.
(run-with-idle-timer 0 nil #'chin/initialize-evil)

(defun chin/load-stage-file (file)
  "Load staged configuration FILE from `user-emacs-directory'."
  (load (expand-file-name file user-emacs-directory) nil t t))

(require 'chin-idle)

(defvar chin/first-call-loaded nil)

(defun chin/load-first-call ()
  "Load the remaining interactive configuration before the first command."
  (unless chin/first-call-loaded
    (chin/initialize-evil)
    (chin/load-stage-file "chin/chin-first-call.el")
    (setq chin/first-call-loaded t)
    (remove-hook 'pre-command-hook #'chin/load-first-call)))

(add-hook 'pre-command-hook #'chin/load-first-call)

(provide 'chin-start)
;;; chin-start.el ends here
