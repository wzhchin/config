;; -*- lexical-binding: t; -*-

;; Avoid blocking on terminal capability probes when an SSH terminal does not
;; answer xterm queries.  Without this, Emacs may redisplay *scratch* while it
;; waits before opening a command-line file.
(when (and (null window-system)
           (getenv "SSH_CONNECTION"))
  (setq xterm-extra-capabilities nil
        xterm-mouse-mode-called t))

(menu-bar-mode -1)
;; These functions are not defined during terminal-only startup on Emacs 31.
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(add-to-list 'default-frame-alist '(font . "Sarasa Mono SC-12"))
(add-to-list 'default-frame-alist '(internal-border-width . 12))

(setq-default truncate-lines nil)
(setq truncate-partial-width-windows nil
      scroll-step 1
      scroll-conservatively 10000)

;; 1 MiB subprocess read cap for LSP JSON bursts.  Does not reserve
;; memory; must not exceed /proc/sys/fs/pipe-max-size.
(setq read-process-output-max (* 1024 1024))

(setq package-enable-at-startup nil
      package-quickstart nil)

;; Emacs 31 can filter `load-path' before trying each directory while loading
;; a library.  Set this in early-init so the main init file benefits too.
(when (and (boundp 'load-path-filter-function)
           (fboundp 'load-path-filter-cache-directory-files))
  ;; Load this dependency before installing the filter: the filter calls
  ;; `regexp-opt', whose autoload would otherwise re-enter the filter.
  (require 'regexp-opt)
  ;; `load' reads this function directly; `setopt' needlessly loads Custom
  ;; and its widget libraries during early init.
  (setq load-path-filter-function
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

;; Record the full startup duration after initial frame setup.
;; https://www.jamescherti.com/measuring-emacs-startup-time/
(defvar my-recorded-startup-time-message nil
  "Stores the formatted string of the Emacs startup metrics.")

(defun my-record-startup-time ()
  "Calculate and record the elapsed startup time."
  (setq my-recorded-startup-time-message
        (format "Emacs loaded in %.3f seconds (Init time: %.3fs) with %d garbage collections."
                (float-time (time-since before-init-time))
                (float-time (time-subtract after-init-time before-init-time))
                gcs-done))
  (message "%s" my-recorded-startup-time-message))

(defun my-display-startup-time ()
  "Display the previously recorded Emacs startup time."
  (interactive)
  (if my-recorded-startup-time-message
      (message "%s" my-recorded-startup-time-message)
    (message "Startup time was not recorded.")))

(add-hook 'emacs-startup-hook #'my-record-startup-time 99)
