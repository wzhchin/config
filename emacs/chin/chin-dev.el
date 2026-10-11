;;; chin-dev.el --- Development configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Development tooling is loaded explicitly by `eee' or on demand through
;; `dev-mode'.

;;; Code:

(defun chin/enable-corfu-in-file-buffer ()
  "Enable Corfu in programming buffers that visit a file."
  (when buffer-file-name
    (corfu-mode 1)))

(defvar corfu-auto)
(defvar corfu-auto-delay)
(defvar corfu-cycle)
(defvar corfu-preview-current)
(defvar corfu-quit-no-match)
(defvar eldoc-idle-delay)
(defvar eldoc-mode)
(declare-function corfu-mode "corfu")
(declare-function corfu-popupinfo-mode "corfu-popupinfo")
(declare-function eldoc-pre-command-refresh-echo-area "eldoc")
(declare-function consult-xref "consult-xref")
(declare-function eglot "eglot")
(declare-function eglot-ensure "eglot")
(declare-function eglot-managed-p "eglot")
(declare-function eglot-code-actions "eglot")
(declare-function eglot-rename "eglot")
(declare-function xref-find-definitions "xref")
(declare-function xref--read-identifier "xref")
(defvar eglot-autoshutdown)
(defvar eglot-sync-connect)
(defvar eglot-events-buffer-config)
(defvar eglot-report-progress)
(defvar eglot-code-action-indications)
(defvar eglot-max-file-watches)
(defvar eglot-ignored-server-capabilities)
(defvar eglot-server-programs)
(defvar chin/evil-leader-map)
(defvar xref-show-xrefs-function)
(declare-function evil-define-key "evil")
(declare-function evil-define-key* "evil")

(defun chin/enable-eglot-in-file-buffer ()
  "Start Eglot in programming buffers that visit a file."
  (when buffer-file-name
    (eglot-ensure)))

(defun chin/eglot-server-configured-p ()
  "Return non-nil when `major-mode' has an Eglot server entry."
  (catch 'configured
    (dolist (entry eglot-server-programs)
      (let ((modes (car entry)))
        (unless (listp modes)
          (setq modes (list modes)))
        (dolist (mode modes)
          (when (eq major-mode (if (consp mode) (car mode) mode))
            (throw 'configured t)))))))

(defvar-keymap chin/evil-code-map
  :doc "Leader bindings for code actions."
  "a" #'eglot-code-actions
  "r" #'eglot-rename)

(with-eval-after-load 'chin-start
  (keymap-set chin/evil-leader-map "c" chin/evil-code-map))

(defvar xref--xref-buffer-mode-map)
(declare-function xref-goto-xref "xref")
(declare-function xref-next-line "xref")
(declare-function xref-prev-line "xref")
(declare-function xref-quit-and-pop-marker-stack "xref")

(setq corfu-auto t
      corfu-auto-delay 0.2
      corfu-cycle t
      corfu-preview-current nil
      corfu-quit-no-match 'separator)
(autoload #'corfu-mode "corfu" nil t)

;; Emacs 31 can render Corfu's popup info in TTY child frames.
(with-eval-after-load 'corfu
  (when (and (not (display-graphic-p))
             (featurep 'tty-child-frames)
             (require 'corfu-popupinfo nil t))
    (corfu-popupinfo-mode 1)))

(add-hook 'prog-mode-hook #'chin/enable-corfu-in-file-buffer)
(add-hook 'prog-mode-hook #'chin/enable-eglot-in-file-buffer)

;; ElDoc already waits half a second before fetching new documentation, but
;; reprints the previous message immediately before every motion command.
;; Let the echo area stay quiet while moving and show the new text on idle.
(setq eldoc-idle-delay 0.5)
(defun chin/eldoc-disable-pre-command-refresh ()
  "Avoid refreshing the previous ElDoc message during cursor motion."
  (when (and eldoc-mode (derived-mode-p 'prog-mode))
    (remove-hook 'pre-command-hook #'eldoc-pre-command-refresh-echo-area t)))
(add-hook 'eldoc-mode-hook #'chin/eldoc-disable-pre-command-refresh)

(with-eval-after-load 'xref
  ;; Keep xref navigation predictable in both Evil and regular states.
  ;; Bind both return events because terminal and GUI frames can produce
  ;; different events for the same physical key.
  (keymap-set xref--xref-buffer-mode-map "RET" #'xref-goto-xref)
  (keymap-set xref--xref-buffer-mode-map "<return>" #'xref-goto-xref)
  (keymap-set xref--xref-buffer-mode-map "n" #'xref-next-line)
  (keymap-set xref--xref-buffer-mode-map "p" #'xref-prev-line)
  (keymap-set xref--xref-buffer-mode-map "q"
              #'xref-quit-and-pop-marker-stack)
  (with-eval-after-load 'evil
    (evil-define-key 'normal xref--xref-buffer-mode-map
      (kbd "RET") #'xref-goto-xref
      (kbd "<return>") #'xref-goto-xref
      "n" #'xref-next-line
      "p" #'xref-prev-line
      "q" #'xref-quit-and-pop-marker-stack)))

(with-eval-after-load 'evil
  (evil-define-key* 'normal 'global
    (kbd "g d") #'xref-find-definitions
    (kbd "M-.") #'xref-find-definitions))

(with-eval-after-load 'eglot
  ;; Covers both `chin/dev-mode' and `SPC c a/r' autoload.
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
     . ("gopls"))))

(autoload #'consult-xref "consult-xref" nil t)
(setq xref-show-xrefs-function #'consult-xref)

(defun chin/dev-mode ()
  "Enable development tools in the current programming buffer."
  (interactive)
  (unless (derived-mode-p 'prog-mode)
    (user-error "Dev mode is only available in programming buffers"))
  (corfu-mode 1)
  (require 'eglot)
  (eglot-ensure)
  (chin/eldoc-disable-pre-command-refresh)
  (message "Development mode enabled"))

;; Keep the requested M-x name while retaining the configuration's `chin/'
;; namespace for the implementation.
(defalias 'dev-mode #'chin/dev-mode)

(provide 'chin-dev)
;;; chin-dev.el ends here
