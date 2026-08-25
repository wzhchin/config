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
          (car (sort directories
                     (lambda (left right)
                       (version<
                        (substring (file-name-nondirectory right)
                                   (length package-prefix))
                        (substring (file-name-nondirectory left)
                                   (length package-prefix))))))))
    (unless newest
      (error "Required package is not installed: %s" package))
    (add-to-list 'load-path newest)))

;; Avoid package.el's descriptor and quickstart scans during startup.
(let ((installed-directories
       (seq-filter
        #'file-directory-p
        (directory-files package-user-dir t "\\`[^.]" t))))
  (dolist (package '(goto-chg evil vertico comment-dwim-2
                     evil-collection expand-region corfu consult))
    (chin/add-package-to-load-path package installed-directories)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "chin" user-emacs-directory))

;; Emacs 31 caches directory contents while resolving `load-path`.
(setq load-path-filter-function
      #'load-path-filter-cache-directory-files)

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
;; `setopt` invokes Emacs 31's setter and updates
;; `major-mode-remap-alist`; a plain `setq` would not do that.
(setopt treesit-auto-install-grammar 'never
        treesit-enabled-modes
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

;;; Deferred interactive features
(defvar chin/deferred-startup-delay 0.05
  "Idle seconds before loading interactive editing features.")

(defvar chin/deferred-startup-timer nil)

(defun chin/load-interactive-features ()
  "Load editing features after the initial frame has been displayed."
  (setq chin/deferred-startup-timer nil)
  (let* ((source (expand-file-name "chin/chin-basic.el" user-emacs-directory))
         ;; Byte compilation writes the .elc beside the source file.
         (compiled (concat (file-name-sans-extension source) ".elc")))
    (load (if (and (file-exists-p compiled)
                   (not (file-newer-than-file-p source compiled)))
              compiled
            source)
          nil t t)))

(defun chin/schedule-interactive-features ()
  "Schedule nonessential interactive features after initial display."
  (unless chin/deferred-startup-timer
    (setq chin/deferred-startup-timer
          (run-with-idle-timer chin/deferred-startup-delay nil
                               #'chin/load-interactive-features))))

(add-hook 'emacs-startup-hook #'chin/schedule-interactive-features)
