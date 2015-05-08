;;; highlight-selection.el --- Yet another attempt to bring highlight selection to emacs.

;; Copyright (C) 2015 Quang-Linh LE

;; Author: Quang-Linh LE <linktohack@gmail.com>
;; URL: http://github.com/linktohack/highlight-selection
;; Version: 0.0.1
;; Keywords: highlight selection highlight-selection
;; Package-Requires: ()

;; This file is not part of GNU Emacs.

;;; License:

;; This file is part of highlight-selection
;;
;; highlight-selection is free software: you can redistribute it
;; and/or modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.
;;
;; highlight-selection is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied warranty
;; of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This program is another attempt to bring highlight selection to emacs.

;; Unlike other attempts, that highlight symbol-at-point using an idle
;; timer, this program advises `mouse-drag-region' to highlight
;; current selection, that means that user will be able to
;; double-click a word, or manually section a symbol, then all
;; occurrences of that word/symbol will be highlighted. The highlight
;; will be remove when user select a blank space or new line.
;;
;; Works best with `evil-visualstar'.


;;; Example:
;;
;; Select a word to highlight
;; Double-click to highlight
;; Double-click beyond end of line to remove highlight


;;; Code:

(defun highlight-selection-highlight-occurrence ()
  (when (and highlight-selection-mode
             (use-region-p))
    (hi-lock-mode -1)
    (let ((beg (region-beginning))
          (end (region-end))
          (target nil)
          (count nil))
      (if (and (featurep 'evil)
               (evil-visual-state-p))
          (setq target (buffer-substring-no-properties beg (1+ end)))
        (setq target (buffer-substring-no-properties beg end)))
      (setq count (count-matches target (point-min) (point-max)))
      ;; We don't want to highlight blank spaces or only one occurrence
      (unless (or (string-match "^[ \\t\\n]+$" target)
                  (< count 2))
        (message "%d occurents of `%s'" count target)
        (highlight-regexp target)))))

;;;###autoload
(define-minor-mode highlight-selection-mode
  "Highlight selection mode."
  :lighter " light"
  (interactive)
  (eval-after-load 'evil
    '(defadvice evil-mouse-drag-region (after advice-highlight-selection () activate)
       (highlight-selection-highlight-occurrence)))
  (defadvice mouse-drag-region (after advice-highlight-selection () activate)
    (highlight-selection-highlight-occurrence)))


(provide 'highlight-selection)

;;; highlight-selection.el ends here
