;;; chin-basic.el --- Compatibility loader  -*- lexical-binding: t; -*-

;;; Commentary:
;; Keep the old feature name working while configuration is split into
;; startup and first-call stages.

;;; Code:

(require 'chin-start)
(require 'chin-first-call)

(provide 'chin-basic)
;;; chin-basic.el ends here
