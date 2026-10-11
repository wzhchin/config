;;; init.el --- Fast base editor configuration  -*- lexical-binding: t; -*-

;;; Custom file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

;;; File persistence
(setq make-backup-files nil)

;;; Packages
(defvar package-archives)
(setq package-archives
      '(("gnu" . "https://mirrors.bfsu.edu.cn/elpa/gnu/")
        ("melpa" . "https://mirrors.bfsu.edu.cn/elpa/melpa/")))

(defun chin/add-package-to-load-path (package installed-directories)
  "Add the newest installed version of PACKAGE to `load-path'."
  (let* ((package-prefix (concat (symbol-name package) "-"))
         (prefix (concat "\\`" (regexp-quote package-prefix) "[0-9]"))
         (directories
          (seq-filter
           (lambda (directory)
             (string-match-p prefix (file-name-nondirectory directory)))
           installed-directories))
         (newest
          (car (if (cdr directories)
                   (sort directories
                         (lambda (left right)
                           (version<
                            (substring (file-name-nondirectory right)
                                       (length package-prefix))
                            (substring (file-name-nondirectory left)
                                       (length package-prefix)))))
                 directories))))
    (unless newest
      (error "Required package is not installed: %s" package))
    (add-to-list 'load-path newest)))

;; Avoid package.el's descriptor and quickstart scans during startup.
(let ((installed-directories
       (seq-filter
        #'file-directory-p
        (directory-files package-user-dir t "\\`[^.]" t))))
  (dolist (package '(goto-chg evil vertico comment-dwim-2
                     expand-region corfu consult git-gutter))
    (chin/add-package-to-load-path package installed-directories)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "chin" user-emacs-directory))

;;; Mode line
;; Emacs 31 folds minor-mode lighters natively.
;; Use `setq' here: `setopt' loads Custom during startup, and this variable
;; has no setter side effect that needs to be invoked.
(setq mode-line-collapse-minor-modes t)

;;; Basic editor
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
      ;; Keep Evil from loading evil-keybindings.el.  Dired and Wdired
      ;; bindings are installed locally after those libraries load.
      evil-want-keybinding nil
      evil-undo-system 'undo-redo
      evil-disable-insert-state-bindings t)

(defvar chin/evil-initialized nil)

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
  "i" #'consult-imenu
  "f" #'find-file
  "g" #'consult-ripgrep
  "l" #'consult-line)

(defvar-keymap chin/evil-buffer-map
  :doc "Leader bindings for buffers."
  "b" #'consult-buffer
  "d" #'kill-current-buffer)

(defvar-keymap chin/evil-leader-map
  :doc "Leader keymap used from Evil normal state."
  "?" #'describe-prefix-bindings
  "b" chin/evil-buffer-map
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
    ;; Call the function behind `evil-define-key' so this file can be loaded
    ;; before Evil itself is available.
    (evil-define-key* 'normal 'global
      (kbd "SPC") chin/evil-leader-map
      (kbd "C-e") #'end-of-line
      (kbd "C-r") #'isearch-backward
      (kbd "g d") (if (fboundp 'chin/eglot-find-definitions)
                       #'chin/eglot-find-definitions
                     #'xref-find-definitions)
      (kbd "g r") #'xref-find-references
      (kbd "K") #'eldoc-doc-buffer
      (kbd "U") #'evil-redo
      (kbd "M-.") (if (fboundp 'chin/eglot-find-definitions)
                       #'chin/eglot-find-definitions
                     #'xref-find-definitions))
    (evil-define-key* 'visual 'global
      (kbd "DEL") #'delete-region)
    (setq chin/evil-initialized t))
  (remove-hook 'pre-command-hook #'chin/initialize-evil))

;;; Startup stages
;; Let the first idle cycle pay for Evil instead of the startup path.  The
;; first-command hook below is a synchronous fallback for an immediate input.
(run-with-idle-timer 0 nil #'chin/initialize-evil)
(add-hook 'pre-command-hook #'chin/initialize-evil)

;; The idle stage only registers each feature's own idle timer.
(require 'chin-idle)
;; Read interaction bindings now; their packages load when invoked.
(require 'chin-first-call)

;; Keep the lightweight editor path free of semantic packages while making
;; the explicit enable command available on demand.
(autoload #'chin-sense "chin-sense"
          "Enable semantic tools in the current programming buffer." t)

(defun chin/command-line-sense (_switch)
  "Load semantic configuration for the `--chin-sense' switch."
  (require 'chin-sense))

(add-to-list 'command-switch-alist
             '("--chin-sense" . chin/command-line-sense))

;;; Confirmation prompts and symbolic links
;; These variables are consumed directly at runtime; `setopt' only adds an
;; unnecessary Custom load to startup.
(setq use-short-answers t
      vc-follow-symlinks 'ask)

;;; Encoding
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system 'utf-8)
(setq system-time-locale "C")

;;; File highlighting
(declare-function markdown-ts-mode "markdown-ts-mode")
(autoload #'markdown-ts-mode "markdown-ts-mode" nil t)
(dolist (pattern '("\\.md\\'"
                   "\\.markdown\\'"
                   "\\.mdown\\'"
                   "\\.mkd\\'"
                   "\\(?:^\\|/\\)README\\.[Mm][Dd]\\'"))
  (add-to-list 'auto-mode-alist (cons pattern #'markdown-ts-mode)))

;;; Tree-sitter
;; `treesit-enabled-modes' needs its setter to update
;; `major-mode-remap-alist', but `setopt' would load all of Custom just to
;; invoke it.  Call the built-in setter directly after loading `treesit'.
(require 'treesit)
(setq treesit-auto-install-grammar 'never)
(funcall (get 'treesit-enabled-modes 'custom-set)
         'treesit-enabled-modes
         '(bash-ts-mode
           c-ts-mode
           c++-ts-mode
           css-ts-mode
           go-ts-mode
           mhtml-ts-mode
           java-ts-mode
           js-ts-mode
           json-ts-mode
           python-ts-mode
           rust-ts-mode
           toml-ts-mode
           typescript-ts-mode
           tsx-ts-mode
           yaml-ts-mode))
