;;; ob-wavedrom.el --- org-babel support for wavedrom evaluation

;; Copyright (C) 2023-2024 Andrew Peck

;; Author: Andrew Peck
;; URL: https://github.com/andrewpeck/ob-wavedrom
;; Version: 0.1
;; Package-Requires: ((emacs "24.1"))
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; Org-Babel support for evaluating wavedrom diagrams.
;;
;; Adapted heavily from the the excellent ob-mermaid.el by Alexei Nunez
;;
;;; Requirements:
;;
;; wavedrom.cli | https://github.com/wavedrom/cli

;;; Code:

(require 'ob)
(require 'ob-eval)

(defvar org-babel-default-header-args:wavedrom
  '((:results . "file") (:exports . "results"))
  "Default arguments for evaluating a wavedrom source block.")

(defcustom ob-wavedrom-cli-path nil
  "Path to wavedrom.cli executable."
  :group 'org-babel
  :type 'string)

(defun org-babel-execute:wavedrom (body params)
  ""
  (let* ((out-file (or (cdr (assoc :file params))
                       (error "Wavedrom requires a \":file\" header argument")))
         (extension (downcase (file-name-extension  out-file)))
         (theme (cdr (assoc :theme params)))
         (width (cdr (assoc :width params)))
         (height (cdr (assoc :height params)))
         (background-color (cdr (assoc :background-color params)))
         (wavedrom-config-file (cdr (assoc :wavedrom-config-file params)))
         (css-file (cdr (assoc :css-file params)))
         (pupeteer-config-file (cdr (assoc :pupeteer-config-file params)))
         (temp-file (org-babel-temp-file "wavedrom-"))
         (wavedrom-cli (or ob-wavedrom-cli-path
                           (executable-find "wavedrom-cli")
                           (error "`ob-wavedrom-cli-path' is not set and wavedrom-cli is not in `exec-path'")))
         (cmd (concat
               (shell-quote-argument (expand-file-name wavedrom-cli))
               ;; input file
               " -i " (org-babel-process-file-name temp-file)
               ;; output format
               " --" extension " "
               ;; output file
               (org-babel-process-file-name out-file))))

    (unless (or  (string= extension "png")
                 (string= extension "svg"))
      (error "Extension format %s not recognized. Please specify a :file with .svg or .png extension" extension))

    (unless (file-executable-p wavedrom-cli)
      ;; cannot happen with `executable-find', so we complain about
      ;; `ob-wavedrom-cli-path'
      (error "Cannot find or execute %s, please check `ob-wavedrom-cli-path'" wavedrom-cli))
    (with-temp-file temp-file (insert body))
    (message "%s" cmd)
    (org-babel-eval cmd "")
    nil))

(provide 'ob-wavedrom)


;;; ob-wavedrom.el ends here
