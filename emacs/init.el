;;; -*- lexical-binding: t; -*-

;;; Custom file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

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
                     evil-collection expand-region corfu consult
                     git-gutter))
    (chin/add-package-to-load-path package installed-directories)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "chin" user-emacs-directory))

;;; Mode line
;; Emacs 31 folds minor-mode lighters natively.
;; Use `setq' here: `setopt' loads Custom during startup, and this variable
;; has no setter side effect that needs to be invoked.
(setq mode-line-collapse-minor-modes t)

;;; Staged configuration
(require 'chin-start)

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
