;;; highlight-selection.el --- Yet another attempt to bring highlight selection to emacs.

;; Copyright (C) 2015 Quang-Linh LE

;; Author: Quang-Linh LE <linktohack@gmail.com>
;; URL: http://github.com/linktohack/highlight-selection
;; Version: 0.0.3
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
;; Works best with `evil-search'.


;;; Example:
;;
;; Select a word to highlight
;; Double-click to highlight
;; Double-click beyond end of line to remove highlight


;;; Code:

(defun highlight-selection-on-mouse-drag-region ()
  (when (use-region-p)
    (hi-lock-mode -1)
    (when (fboundp 'evil-ex-nohighlight)
      (evil-ex-nohighlight))
    (let* ((beg (region-beginning))
           (end (if (and (featurep 'evil)
                         (evil-visual-state-p))
                    (1+ (region-end))
                  (region-end)))
           (regexp (regexp-quote
                    (buffer-substring-no-properties beg end)))
           (count (count-matches regexp (point-min) (point-max))))
      ;; We don't want to highlight blank spaces or only one occurrence
      (unless (or (string-match "^[ \\t\\n]*$" regexp)
                  (< count 2))
        (message "%d occurents of `%s'" count regexp)
        (if (and (featurep 'evil)
                 (eq evil-search-module 'evil-search))
            (progn
              (setq evil-ex-search-direction 'forward
                    evil-ex-search-pattern
                    (evil-ex-make-search-pattern regexp))
              (evil-ex-search-activate-highlight evil-ex-search-pattern))
          (highlight-regexp regexp))))))

;;;###autoload
(define-minor-mode highlight-selection-mode
  "Highlight selection mode."
  :lighter " light"
  :global t
  (if highlight-selection-mode
      (progn
        (eval-after-load 'evil
          '(defadvice evil-mouse-drag-region (after highlight-selection () activate)
             (highlight-selection-on-mouse-drag-region)))
        (defadvice mouse-drag-region (after highlight-selection () activate)
          (highlight-selection-on-mouse-drag-region)))
    (eval-after-load 'evil
      '(progn
         (ad-remove-advice 'evil-mouse-drag-region 'after 'highlight-selection)
         (ad-update 'evil-mouse-drag-region)))
    (ad-remove-advice 'mouse-drag-region 'after 'highlight-selection)
    (ad-update 'mouse-drag-region)))


(provide 'highlight-selection)

;;; highlight-selection.el ends here
