;;; -*- lexical-binding: t; -*-

;;; Custom file Settings
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(setq evil-want-keybinding nil)

;;; Loading Tools
;;; Platform Settings
(defconst chin/is-linux   (eq system-type 'gnu/linux))
(defconst chin/is-windows (memq system-type '(cygwin windows-nt ms-dos)))
(defconst chin/is-android (string-match-p "-linux-android$" system-configuration))

(setq-default tsinghua-mirror
              '(("gnu"   . "https://mirrors.bfsu.edu.cn/elpa/gnu/")
                ("melpa" . "https://mirrors.bfsu.edu.cn/elpa/melpa/")))



(setq package-archives tsinghua-mirror)
;; (package-quickstart-refresh )

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "chin" user-emacs-directory))

;;; Portable dumper —— 从 dump 启动时, dumped 的 .el load-time 代码不会重新执行,
;;; 唯一能恢复运行时状态的地方是 after-pdump-load-hook。
;; 此 add-hook 必须在 init 求值期执行(从而被烤进 dump), hook 体在 dump 启动时才跑。
(add-hook 'after-pdump-load-hook
          (lambda ()
            (when (boundp '+saved-load-path-during-dump)
              (setq load-path +saved-load-path-during-dump))))

(when chin/is-windows
  ;; TODO remove this
  (setq package-check-signature nil))

;; Locale Settings
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(prefer-coding-system 'utf-8)
(setq system-time-locale "C")

(use-package savehist
  :config
  (savehist-mode))


;; Avoid the ask, just visit the direct file.
(setq vc-follow-symlinks nil)

(defun chin/server-shutdown ()
  "Save buffers, quit, and shutdown (kill) server."
  (interactive)
  (save-some-buffers)
  (kill-emacs))

;;; Portable dumper —— 把当前已加载的配置 dump 成 emacs.pdmp，
;;; 之后用 emacs --dump-file= 启动可跳过几乎全部 init 求值。
;;; 改完配置后 M-x chin/dump 重生成一次即可。
(defvar chin/pdump-file
  (expand-file-name "emacs.pdmp" user-emacs-directory)
  "自定义 pdump 文件路径。")

(defun chin/dump ()
  "把当前已初始化状态 dump 到 `chin/pdump-file'。
推荐用 batch 调用(见 .zshrc 里的 edump): package-initialize 必须在 load init
之前完成, 否则 use-package 的 :config 不会执行, dump 出来是空壳。
交互式 M-x chin/dump 也可(此时 package-initialize 已由启动自动完成)。"
  (interactive)
  ;; batch 模式下 package-initialize 不会自动跑, 显式兜底(交互式下是幂等 no-op)。
  (when (and noninteractive (fboundp 'package-initialize))
    (package-initialize))
  ;; 把当前 load-path 存下, 供从 dump 启动的新进程通过 after-pdump-load-hook 还原。
  (setq +saved-load-path-during-dump load-path)
  ;; 活不过 dump 的运行时状态先清掉, 避免 dump 进脏数据。
  (when (fboundp 'garbage-collect) (garbage-collect))
  (dump-emacs-portable chin/pdump-file)
  (message "Dumped to %s (%d bytes) — 启动: emacs --dump-file=%s"
           chin/pdump-file
           (file-attribute-size (file-attributes chin/pdump-file))
           chin/pdump-file))

(require 'chin-ui)
(require 'chin-completion)
(require 'chin-edit)
(require 'chin-evil)
(require 'chin-file)
(require 'chin-langs)
(require 'chin-window-and-buffer)
(require 'chin-lang-web)
(require 'chin-chinese)
(require 'chin-lsp)
;; (require 'chin-org)
(require 'chin-project)
(require 'chin-vc)
(require 'chin-lang-rust)
(require 'chin-write)
