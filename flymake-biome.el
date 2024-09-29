;;; flymake-biome.el --- A flymake plugin for SQL files using biome -*- lexical-binding: t -*-

;; Copyright © 2024 Erick Navarro
;; Author: Erick Navarro <erick@navarro.io>
;; URL: https://github.com/erickgnavar/flymake-biome
;; Version: 0.1.0
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Package-Requires: ((emacs "27.1"))

;;; Commentary:

;; Usage:
;;   (require 'flymake-biome)
;;   (add-hook 'js-mode-hook #'flymake-biome-load)

;;; Code:
(defcustom flymake-biome-program "biome"
  "Path to program biome."
  :group 'flymake-biome
  :type 'string)

;;;###autoload
(defun flymake-biome-load ()
  "Load hook for the current buffer to tell flymake to run checker."
  (interactive)
  (add-hook 'flymake-diagnostic-functions #'flymake-biome--run-checker nil t))

(defvar flymake-biome--output-regex ",line=\\([0-9]+\\),.*,col=\\([0-9]+\\).*::\\(.*\\)")

(defun flymake-biome--check-buffer ()
  "Generate a list of diagnostics for the current buffer."
  (let ((code-buffer (current-buffer))
        (code-content (without-restriction
                        (buffer-substring-no-properties (point-min) (point-max))))
        (dxs '()))
    (with-temp-buffer
      (insert code-content)
      ;; call-process-region will run the program and replace current buffer
      ;; with its stdout, that's why we need to run it in a temporary buffer
      (apply #'call-process-region (point-min) (point-max) flymake-biome-program t t nil '("lint" "--reporter" "github"))
      (goto-char (point-min))
      (while (search-forward-regexp flymake-biome--output-regex (point-max) t)
        (when (match-string 1)
          (let* ((line (string-to-number (match-string 1)))
                 (col (string-to-number (match-string 2)))
                 (description (match-string 3))
                 (region (flymake-diag-region code-buffer line col))
                 (dx (flymake-make-diagnostic code-buffer (car region) (cdr region)
                                              :error description)))
            (push dx dxs)))))
    dxs))

(defun flymake-biome--run-checker (report-fn &rest _args)
  "Run checker using REPORT-FN."
  (funcall report-fn (flymake-biome--check-buffer)))

(provide 'flymake-biome)
;;; flymake-biome.el ends here
