;;; chin-dev.el --- Development configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Development tooling is loaded explicitly by `eee' or on demand through
;; `dev-mode'.

;;; Code:

(require 'use-package)

;;; Documentation

(use-package eldoc
  :demand t
  :preface
  (defun chin/eldoc-disable-pre-command-refresh ()
    "Avoid refreshing the previous ElDoc message during cursor motion."
    (when (and eldoc-mode (derived-mode-p 'prog-mode))
      (remove-hook 'pre-command-hook #'eldoc-pre-command-refresh-echo-area t)))
  :hook (eldoc-mode . chin/eldoc-disable-pre-command-refresh)
  :config
  ;; ElDoc waits half a second for new documentation, but otherwise reprints
  ;; the previous message immediately before every motion command.
  (setq eldoc-idle-delay 0.5))

;;; Completion

(use-package corfu
  :demand t
  :preface
  (defun chin/enable-corfu-in-file-buffer ()
    "Enable Corfu in programming buffers that visit a file."
    (when buffer-file-name
      (corfu-mode 1)))
  :hook (prog-mode . chin/enable-corfu-in-file-buffer)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.2
        corfu-cycle t
        corfu-preview-current nil
        corfu-quit-no-match 'separator)
  ;; Emacs 31 can render Corfu's popup info in TTY child frames.
  (use-package corfu-popupinfo
    :if (and (not (display-graphic-p)) (featurep 'tty-child-frames))
    :demand t
    :config (corfu-popupinfo-mode 1)))

;;; Language server

(use-package eglot
  :demand t
  :preface
  (defun chin/enable-eglot-in-file-buffer ()
    "Start Eglot in programming buffers that visit a file."
    (when buffer-file-name
      (eglot-ensure)))
  :hook (prog-mode . chin/enable-eglot-in-file-buffer)
  :config
  (setq eglot-autoshutdown t
        eglot-sync-connect 3
        eglot-events-buffer-config '(:size 0 :format short)
        eglot-report-progress nil
        eglot-code-action-indications nil
        eglot-max-file-watches 5000)
  ;; On-type format is per-keystroke RPC.  Tree-sitter already fontifies.
  ;; Emacs 31 auto-enables inlay hints and semantic tokens on manage.
  (setq eglot-ignored-server-capabilities
        '(:documentOnTypeFormattingProvider
          :inlayHintProvider
          :documentHighlightProvider
          :semanticTokensProvider))
  (add-to-list
   'eglot-server-programs
   '((c-mode c-ts-mode c++-mode c++-ts-mode objc-mode)
     . ("clangd" "--background-index" "--clang-tidy")))
  (add-to-list
   'eglot-server-programs
   '((python-mode python-ts-mode)
     . ("uvx" "--from" "python-lsp-server" "pylsp")))
  (add-to-list
   'eglot-server-programs
   '((go-mode go-dot-mod-mode go-dot-work-mode
      go-ts-mode go-mod-ts-mode go-work-ts-mode)
     . ("gopls")))
  (defun chin/eglot-server-configured-p ()
    "Return non-nil when `major-mode' has an Eglot server entry."
    (catch 'configured
      (dolist (entry eglot-server-programs)
        (let ((modes (car entry)))
          (unless (listp modes)
            (setq modes (list modes)))
          (dolist (mode modes)
            (when (eq major-mode (if (consp mode) (car mode) mode))
              (throw 'configured t))))))))

;;; Navigation and keys

(use-package xref
  :demand t
  :config
  (use-package consult-xref
    :demand t
    :config (setq xref-show-xrefs-function #'consult-xref))
  ;; Bind both return events because terminal and GUI frames can produce
  ;; different events for the same physical key.
  (keymap-set xref--xref-buffer-mode-map "RET" #'xref-goto-xref)
  (keymap-set xref--xref-buffer-mode-map "<return>" #'xref-goto-xref)
  (keymap-set xref--xref-buffer-mode-map "n" #'xref-next-line)
  (keymap-set xref--xref-buffer-mode-map "p" #'xref-prev-line)
  (keymap-set xref--xref-buffer-mode-map "q"
              #'xref-quit-and-pop-marker-stack))

(use-package evil
  :demand t
  :config
  (defvar-keymap chin/evil-code-map
    :doc "Leader bindings for code actions."
    "a" #'eglot-code-actions
    "r" #'eglot-rename)
  (keymap-set chin/evil-leader-map "c" chin/evil-code-map)
  (evil-define-key 'normal xref--xref-buffer-mode-map
    (kbd "RET") #'xref-goto-xref
    (kbd "<return>") #'xref-goto-xref
    "n" #'xref-next-line
    "p" #'xref-prev-line
    "q" #'xref-quit-and-pop-marker-stack)
  (evil-define-key* 'normal 'global
    (kbd "g d") #'xref-find-definitions
    (kbd "M-.") #'xref-find-definitions))

(defun chin/dev-mode ()
  "Enable development tools in the current programming buffer."
  (interactive)
  (unless (derived-mode-p 'prog-mode)
    (user-error "Dev mode is only available in programming buffers"))
  (corfu-mode 1)
  (eglot-ensure)
  (chin/eldoc-disable-pre-command-refresh)
  (message "Development mode enabled"))

;; Keep the requested M-x name while retaining the configuration's `chin/'
;; namespace for the implementation.
(defalias 'dev-mode #'chin/dev-mode)

(provide 'chin-dev)
;;; chin-dev.el ends here
