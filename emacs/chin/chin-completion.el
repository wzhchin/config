;;; -*- lexical-binding: t; -*-

(use-package vertico
  :ensure t
  :config
  (vertico-mode))

(use-package consult
  :ensure t
  :config
  (setq read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t
        completion-category-defaults nil
        completion-category-overrides nil
        completion-styles '(basic substring partial-completion flex))

  (setq completion-in-region-function #'consult-completion-in-region)
  (consult-customize consult-completion-in-region
                     :completion-styles '(basic)
                     :cycle-threshold 3)

  ;; Consult Settings
  (global-set-key (kbd "M-3") 'consult-ripgrep)
  (global-set-key (kbd "M-4") 'consult-buffer)

  (global-set-key (kbd "M-s l") 'consult-line)
  )

(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-preview-current nil)
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)
  ;; Enable auto completion, configure delay, trigger and quitting
  (setq corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-trigger "." ;; Custom trigger characters
        corfu-quit-no-match 'separator) ;; or t
  )
(use-package cape
  :ensure t
  :bind ("M-/" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'completion-at-point-functions #'cape-history)
  )
(use-package orderless
  :ensure t
  :config
  (setq completion-category-overrides '((eglot (styles orderless))
                                        (eglot-capf (styles orderless))))
  )
(advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)


(use-package affe
  :ensure t
  :config
  ;; Manual preview key for `affe-grep'
  (consult-customize affe-grep :preview-key "M-.")
  (global-set-key (kbd "M-s f") 'affe-find)
  )

(use-package consult-xref
  :defer t
  :init
  (setq xref-show-xrefs-function       #'consult-xref
        xref-show-definitions-function #'consult-xref))


(use-package embark
  :ensure t
  :bind
  (("C-," . embark-act)
   ("C-." . embark-dwim)
   ("C-h B" . embark-bindings)
   :map minibuffer-mode-map
   ("C-c C-o" . embark-export)  ;; This is the default binding of Ivy-Occur
   )
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook
  (embark-consult-mode . consult-preview-at-point-mode))

(provide 'chin-completion)
