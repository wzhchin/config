;;; -*- lexical-binding: t; -*-

;;; Custom file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;;; Packages
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
                     expand-region corfu consult))
    (chin/add-package-to-load-path package installed-directories)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "chin" user-emacs-directory))

;;; Encoding
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system 'utf-8)
(setq system-time-locale "C")

;;; Required interactive features
(let ((source (expand-file-name "chin/must-have.el" user-emacs-directory))
      (compiled (expand-file-name "must-have.elc" user-emacs-directory)))
  (load (if (and (file-exists-p compiled)
                 (not (file-newer-than-file-p source compiled)))
            compiled
          source)
        nil t t))
