;; -*- lexical-binding: t; -*-

;; Avoid blocking on terminal capability probes when an SSH terminal does not
;; answer xterm queries.  Without this, Emacs may redisplay *scratch* while it
;; waits before opening a command-line file.
(when (and (null window-system)
           (getenv "SSH_CONNECTION"))
  (setq xterm-extra-capabilities nil
        xterm-mouse-mode-called t))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(add-to-list 'default-frame-alist '(font . "Sarasa Mono SC-12"))
(add-to-list 'default-frame-alist '(internal-border-width . 12))

(setq-default truncate-lines nil)
(setq truncate-partial-width-windows nil
      scroll-step 1
      scroll-conservatively 10000)

(setq package-enable-at-startup nil
      package-quickstart nil)

;; Emacs 31 can filter `load-path' before trying each directory while loading
;; a library.  Set this in early-init so the main init file benefits too.
(when (and (boundp 'load-path-filter-function)
           (fboundp 'load-path-filter-cache-directory-files))
  (setopt load-path-filter-function
          #'load-path-filter-cache-directory-files))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1))
          t)

(setq message-log-max 16384
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      initial-major-mode 'fundamental-mode
      auto-window-vscroll nil)
