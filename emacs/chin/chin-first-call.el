;;; chin-first-call.el --- First-command configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Load the remaining interactive features immediately before the first
;; command, while keeping their heavier implementations autoloaded.

;;; Code:

(declare-function markdown-ts-outline-cycle "markdown-ts-mode")
(defvar markdown-ts-mode-map)
(defun chin/markdown-insert-timestamp ()
  "Insert an inactive Org-style timestamp in Markdown."
  (interactive)
  (insert (format-time-string "[%Y-%m-%d %a]")))

(defun chin/markdown-cycle-heading-todo ()
  "Cycle the current Markdown heading through TODO and DONE states."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (unless (looking-at
             "\\(#[#]\\{0,5\\}\\)[[:blank:]]+\\(?:\\(TODO\\|DONE\\)[[:blank:]]+\\)?")
      (user-error "Point is not on a Markdown heading"))
    (let ((heading-end (match-end 1))
          (state (match-string-no-properties 2)))
      (delete-region heading-end (match-end 0))
      (goto-char heading-end)
      (insert (pcase state
                ("TODO" " DONE ")
                ("DONE" " ")
                (_ " TODO "))))))

(with-eval-after-load 'markdown-ts-mode
  ;; Evil handles TAB as C-i in normal state, hiding Markdown's Org-like
  ;; outline cycling.  Bind both terminal and GUI Tab events mode-locally.
  (evil-define-key 'normal markdown-ts-mode-map
    (kbd "TAB") #'markdown-ts-outline-cycle
    (kbd "<tab>") #'markdown-ts-outline-cycle)
  (keymap-set markdown-ts-mode-map "C-c ."
              #'chin/markdown-insert-timestamp)
  (keymap-set markdown-ts-mode-map "C-c C-t"
              #'chin/markdown-cycle-heading-todo))

(declare-function evil-collection-init "evil-collection")
(with-eval-after-load 'dired
  ;; Load Evil Collection only for file-management modes.  This keeps the
  ;; broader configuration minimal while retaining Dired's complete Evil UI.
  (require 'evil-collection)
  (evil-collection-init '(dired wdired)))

(require 'vertico)
(vertico-mode 1)

(declare-function comment-dwim-2 "comment-dwim-2")
(autoload #'comment-dwim-2 "comment-dwim-2" nil t)
(global-set-key (kbd "M-;") #'comment-dwim-2)

(declare-function er/expand-region "expand-region")
(autoload #'er/expand-region "expand-region" nil t)
(define-advice set-mark-command (:before-while (arg))
  "Repeat C-SPC to expand the region."
  (interactive "P")
  (ignore arg)
  (if (eq last-command 'set-mark-command)
      (progn
        (er/expand-region 1)
        nil)
    t))

(require 'point-stack)
(point-stack-setup-advices)
(global-set-key (kbd "M-1") #'point-stack-pop)
(global-set-key (kbd "M-2") #'point-stack-forward-stack-pop)

(defun chin/indent-current-buffer ()
  "Indent the current buffer and normalize it to spaces."
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(defun chin/delete-blanks (&optional insert-blank-p)
  "Delete whitespace around point.
With INSERT-BLANK-P non-nil, do not insert a replacement space."
  (interactive)
  (let ((end-pos (progn
                   (back-to-indentation)
                   (point))))
    (skip-chars-backward " \t\n")
    (let ((start-pos (point)))
      (delete-region start-pos end-pos)
      (unless (or insert-blank-p
                  (= start-pos (point-min))
                  (= start-pos end-pos))
        (insert " ")))))

(defun chin/move-beginning-of-line ()
  "Move to indentation, or to the beginning of line when already there."
  (interactive)
  (let ((origin (point)))
    (back-to-indentation)
    (when (= origin (point))
      (beginning-of-line))))

(defun chin/revert-buffer ()
  "Revert the current buffer without confirmation."
  (interactive)
  (revert-buffer t t t)
  (message "Buffer reverted"))

(defun chin/match-paren (arg)
  "Move to the matching parenthesis, or insert ARG percent signs."
  (interactive "p")
  (cond
   ((looking-at "\\s(")
    (forward-list 1)
    (backward-char 1))
   ((looking-at "\\s)")
    (forward-char 1)
    (backward-list 1))
   (t
    (self-insert-command (or arg 1)))))

(global-set-key (kbd "C-c i") #'chin/indent-current-buffer)
(global-set-key (kbd "M-h") #'chin/delete-blanks)
(global-set-key (kbd "C-M-h")
                (lambda ()
                  (interactive)
                  (chin/delete-blanks t)))
(global-set-key (kbd "C-a") #'chin/move-beginning-of-line)
(global-set-key (kbd "M-r") #'chin/revert-buffer)
(global-set-key (kbd "C-c '") #'chin/match-paren)
(setq kill-whole-line t)

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
(declare-function consult-buffer "consult")
(declare-function consult-line "consult")
(declare-function consult-ripgrep "consult")
(declare-function eglot-ensure "eglot")
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

(autoload #'consult-buffer "consult" nil t)
(autoload #'consult-line "consult" nil t)
(autoload #'consult-ripgrep "consult" nil t)
(global-set-key (kbd "M-3") #'consult-ripgrep)
(global-set-key (kbd "M-4") #'consult-buffer)
(global-set-key (kbd "M-s l") #'consult-line)

(provide 'chin-first-call)
;;; chin-first-call.el ends here
