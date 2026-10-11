;;; chin-idle.el --- Idle configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Read during startup; each feature chooses its own idle delay.

;;; Code:

(defmacro chin/load-idle! (idle-seconds &rest body)
  "Run BODY once after Emacs has been idle for IDLE-SECONDS."
  (declare (indent 1))
  `(run-with-idle-timer ,idle-seconds nil
                        (lambda () ,@body)))

;; Emacs 31 ships which-key, so it does not belong in the ELPA-only package
;; path list in `init.el`.
(chin/load-idle! 0
  (require 'which-key)
  (which-key-mode 1))

(provide 'chin-idle)
;;; chin-idle.el ends here
