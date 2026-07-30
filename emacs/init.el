;;; -*- lexical-binding: t; -*-

;;; Custom file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;;; Packages
(defvar package-archives)
(setq package-archives
      '(("gnu" . "https://mirrors.bfsu.edu.cn/elpa/gnu/")
        ("melpa" . "https://mirrors.bfsu.edu.cn/elpa/melpa/")))

(defun chin/add-package-to-load-path (package installed-directories)
  "Add the newest installed version of PACKAGE to `load-path'."
  (let* ((prefix (concat "\\`" (regexp-quote (symbol-name package)) "-[0-9]"))
         (directories
          (seq-filter
           (lambda (directory)
             (string-match-p prefix (file-name-nondirectory directory)))
           installed-directories))
         (newest
          (car (sort directories
                     (lambda (left right)
                       (string> (file-name-nondirectory left)
                                (file-name-nondirectory right)))))))
    (unless newest
      (error "Required package is not installed: %s" package))
    (add-to-list 'load-path newest)))

;; Avoid package.el's descriptor and quickstart scans during startup.
(let ((installed-directories
       (seq-filter
        #'file-directory-p
        (directory-files package-user-dir t "\\`[^.]" t))))
  (dolist (package '(compat goto-chg evil vertico comment-dwim-2
                     expand-region corfu consult markdown-ts-mode))
    (chin/add-package-to-load-path package installed-directories)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "chin" user-emacs-directory))

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

(dolist (mapping '(("\\.sh\\'" . bash-ts-mode)
                   ("\\.c\\'" . c-ts-mode)
                   ("\\.\\(?:cc\\|cpp\\|cxx\\|hh\\|hpp\\|hxx\\)\\'" . c++-ts-mode)
                   ("\\.css\\'" . css-ts-mode)
                   ("\\.html?\\'" . html-ts-mode)
                   ("\\.java\\'" . java-ts-mode)
                   ("\\.\\(?:js\\|mjs\\|cjs\\)\\'" . js-ts-mode)
                   ("\\.json\\'" . json-ts-mode)
                   ("\\.py\\'" . python-ts-mode)
                   ("\\.rs\\'" . rust-ts-mode)
                   ("\\.toml\\'" . toml-ts-mode)
                   ("\\.ts\\'" . typescript-ts-mode)
                   ("\\.tsx\\'" . tsx-ts-mode)
                   ("\\.ya?ml\\'" . yaml-ts-mode)))
  (add-to-list 'auto-mode-alist mapping))

(defun chin/enable-common-treesit-modes ()
  "Prefer available tree-sitter modes for common file types."
  (when (and (fboundp 'treesit-available-p)
             (treesit-available-p))
    (dolist (mapping '((bash sh-mode bash-ts-mode)
                       (c c-mode c-ts-mode)
                       (cpp c++-mode c++-ts-mode)
                       (css css-mode css-ts-mode)
                       (html html-mode html-ts-mode)
                       (java java-mode java-ts-mode)
                       (javascript js-mode js-ts-mode)
                       (json js-json-mode json-ts-mode)
                       (python python-mode python-ts-mode)
                       (rust rust-mode rust-ts-mode)
                       (toml conf-toml-mode toml-ts-mode)
                       (typescript typescript-mode typescript-ts-mode)
                       (yaml yaml-mode yaml-ts-mode)))
      (pcase-let ((`(,language ,classic-mode ,treesit-mode) mapping))
        (when (and (treesit-language-available-p language)
                   (fboundp treesit-mode))
          (setf (alist-get classic-mode major-mode-remap-alist)
                treesit-mode))))))

;;; Deferred interactive features
(defvar chin/deferred-startup-delay 0.05
  "Idle seconds before loading interactive editing features.")

(defvar chin/deferred-startup-timer nil)

(defun chin/load-interactive-features ()
  "Load editing features after the initial frame has been displayed."
  (setq chin/deferred-startup-timer nil)
  (chin/enable-common-treesit-modes)
  (let ((source (expand-file-name "chin/must-have.el" user-emacs-directory))
        (compiled (expand-file-name "must-have.elc" user-emacs-directory)))
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
