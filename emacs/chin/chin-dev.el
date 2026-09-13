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
(declare-function corfu-mode "corfu")
(declare-function corfu-popupinfo-mode "corfu-popupinfo")
(declare-function consult-xref "consult-xref")
(declare-function eglot-ensure "eglot")
(declare-function eglot-code-actions "eglot")
(declare-function eglot-rename "eglot")
(defvar eglot-autoshutdown)
(defvar eglot-sync-connect)
(defvar eglot-events-buffer-config)
(defvar eglot-report-progress)
(defvar eglot-code-action-indications)
(defvar eglot-max-file-watches)
(defvar eglot-ignored-server-capabilities)
(defvar chin/evil-leader-map)
(defvar xref-show-xrefs-function)
(declare-function evil-define-key "evil")

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
  (evil-define-key 'normal xref--xref-buffer-mode-map
    (kbd "RET") #'xref-goto-xref
    (kbd "<return>") #'xref-goto-xref
    "n" #'xref-next-line
    "p" #'xref-prev-line
    "q" #'xref-quit-and-pop-marker-stack))

(with-eval-after-load 'eglot
  ;; Covers both `chin/dev-mode' and `SPC c a/r' autoload.
  (setq eglot-autoshutdown t
        eglot-sync-connect nil
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
          :semanticTokensProvider)))

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
  (message "Development mode enabled"))

;; Keep the requested M-x name while retaining the configuration's `chin/'
;; namespace for the implementation.
(defalias 'dev-mode #'chin/dev-mode)

(provide 'chin-dev)
;;; chin-dev.el ends here
