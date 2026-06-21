;;; -*- lexical-binding: t; -*-

(require 'subr-x)

(load-theme 'adwaita)


;; Set tab width
(setq-default tab-width 4)
;; use space to indent by default
(setq-default indent-tabs-mode nil)

;; Frame settings
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

(setq use-dialog-box nil
      use-short-answers t)

;; Scrolling Settings
(setq scroll-step           1
      scroll-conservatively 10000)
(pixel-scroll-precision-mode 1)
(setq pixel-scroll-precision-interpolate-page t)
(defalias 'scroll-up-command 'pixel-scroll-interpolate-down)
(defalias 'scroll-down-command 'pixel-scroll-interpolate-up)

;; Disable the annoying bell.
(setq ring-bell-function 'ignore)

;; Toolbar Settings
(setq backup-directory-alist `(("." . "~/.emacs-saves")))

;; Paren Settings
(show-paren-mode)
(setq show-paren-style 'mixed
      show-paren-content-when-offscreen 'overlay)

(setq word-wrap-by-category t)

(use-package git-gutter
  :ensure t
  :config
  (global-git-gutter-mode +1))

(setq-default chin/home (getenv "HOME"))

;;; Packages
(defun abbreviate-file-path (file-path)
  "Abbreviate the directory part of a file path, showing only the first letter of each directory."
  (let* ((trimmed (string-replace chin/home "~" file-path))
         (path-segments (split-string trimmed "/")))
    (mapconcat
     (lambda (segment)
       (if (length> segment 1)
           (if (string-prefix-p "." segment)
               (substring segment 0 2)
             (substring segment 0 1))
         segment))
     path-segments "/")))

;; 注: 这两个 mode 必须无条件开启 —— pdump 启动时 load-time 代码不重跑,
;; 只有 dump 构建时开启过、状态烤进镜像, 启动后才生效。若包在某个 dump
;; 时才绑定的变量 guard 里, require 时 guard 恒为 nil, 永远不会开启。
(global-font-lock-mode +1)
(transient-mark-mode +1)

;; mode-line settings
(use-package minions
  :ensure t
  :config
  (minions-mode))

(global-display-line-numbers-mode)

(setq column-number-mode t) ; Show column number in the mode-line

(setq-default frame-title-format "%b [ %f ]")
(use-package term-title
  :config
  (term-title-mode))

(provide 'chin-ui)
