;;; exwmx-buttons.el --- Add some exwm buttons to mode-line

;; * Header
;; Copyright 2015 Feng Shu

;; Author: Feng Shu <tumashu@163.com>
;; URL: https://github.com/tumashu/exwmx
;; Version: 0.0.1
;; Keywords: exwm, exwmx

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; * README                                                               :doc:
;;; Code:

;; * Code                                                                 :code:
(require 'cl-lib)
(require 'exwm)
(require 'exwmx-core)

(defun exwmx--create-button (mode-line string &optional mouse-1-action
                                        mouse-3-action mouse-2-action
                                        active-down-mouse)
  "Generate `,mode-or-head-line-format' style code of a clickable button, which name
is `string'.

`mouse-1-action', `mouse-2-action' and `mouse-2-action' are often quoted lists.
when click it with mouse-1, `mouse-1-action' will be execute.
click mouse-2, `mouse-2-action' execute. click mouse-3, `mouse-3-action'
execute. "
  `(:eval (propertize
           ,string
           'face 'mode-line-buffer-id
           'help-echo ""
           'mouse-face 'mode-line-highlight
           'local-map
           (let ((map (make-sparse-keymap)))
             (unless (eq (quote ,mouse-1-action) nil)
               (define-key map [,mode-line mouse-1]
                 #'(lambda (event)
                     (interactive "e")
                     (with-selected-window (posn-window (event-start event))
                       ,mouse-1-action))))
             (unless (eq (quote ,mouse-2-action) nil)
               (define-key map [,mode-line mouse-2]
                 #'(lambda (event)
                     (interactive "e")
                     (with-selected-window (posn-window (event-start event))
                       ,mouse-2-action))))
             (unless (eq (quote ,mouse-3-action) nil)
               (define-key map [,mode-line mouse-3]
                 #'(lambda (event)
                     (interactive "e")
                     (with-selected-window (posn-window (event-start event))
                       ,mouse-3-action))))
             (when (and (eq major-mode 'exwm-mode)
                        exwm--floating-frame
                        (not (eq (quote ,active-down-mouse) nil)))
               (define-key map [,mode-line down-mouse-1]
                 #'exwmx-mouse-move-floating-window)
               (define-key map [,mode-line down-mouse-3]
                 #'exwmx-mouse-move-floating-window))
             map))))

;; Emacs's default mode-line is not suitable for window manager,
;; This function will create a new mode-line, which has:

;; [+]: Maximize current window.
;; [D]: Delete current window.
;; [F]: toggle floating window.
;; [-]: Split window horizontal.
;; [|]: Split window vertical.
;; [<]: Move border to left.
;; [>]: Move border to right.

(defun exwmx--create-tilling-mode-line ()
  (setq mode-line-format
        (list (exwmx--create-button
               'mode-line "[X]" '(exwmx-kill-exwm-buffer) '(exwmx-kill-exwm-buffer))
              (exwmx--create-button
               'mode-line "[D]" '(delete-window) '(delete-window))
              (exwmx--create-button
               'mode-line "[F]" '(exwm-floating-toggle-floating) '(exwm-floating-toggle-floating))
              " "
              (exwmx--create-button
               'mode-line "[<]" '(exwmx-move-border-left 10) '(exwmx-move-border-left 10))
              (exwmx--create-button
               'mode-line "[+]" '(delete-other-windows) '(delete-other-windows))
              (exwmx--create-button
               'mode-line "[>]" '(exwmx-move-border-right 10) '(exwmx-move-border-right 10))
              " "
              (exwmx--create-button
               'mode-line "[-]" '(split-window-below) '(split-window-below))
              (exwmx--create-button
               'mode-line "[|]" '(split-window-right) '(split-window-right))
              " - "
              exwm-title)))

(defun exwmx--create-floating-mode-line ()
  (setq mode-line-format
        (list (exwmx--create-button
               'mode-line "[X]" '(exwmx-kill-exwm-buffer) '(exwmx-kill-exwm-buffer))
              (exwmx--create-button
               'mode-line "[_]" '(exwm-floating-hide) '(exwm-floating-hide))
              (exwmx--create-button
               'mode-line "[F]" '(exwm-floating-toggle-floating) '(exwm-floating-toggle-floating))
              " "
              (exwmx--create-button
               'mode-line "[Z+]"
               '(progn (exwm-layout-enlarge-window 30)
                       (exwm-layout-enlarge-window-horizontally 100))
               '(progn (exwm-layout-enlarge-window 30)
                       (exwm-layout-enlarge-window-horizontally 100)))
              (exwmx--create-button
               'mode-line "[Z-]"
               '(progn (exwm-layout-enlarge-window -30)
                       (exwm-layout-enlarge-window-horizontally -100))
               '(progn (exwm-layout-enlarge-window -30)
                       (exwm-layout-enlarge-window-horizontally -100)))
              (exwmx--create-button
               'mode-line
               (concat " - " exwm-title (make-string 200 ? )) nil nil nil t))))

(defun exwmx--reset-mode-line ()
  "Reset mode-line for tilling window"
  (setq mode-line-format
        (default-value 'mode-line-format)))

(defun exwmx--update-mode-line ()
  "Update all buffer's mode-lines."
  (interactive)
  ;; Set all buffer's mode-line.
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (cond ((and (eq major-mode 'exwm-mode)
                  (not exwm--floating-frame))
             (exwmx--create-tilling-mode-line))
            ((and (eq major-mode 'exwm-mode)
                  exwm--floating-frame)
             (exwmx--create-floating-mode-line))
            (t (exwmx--reset-mode-line))))
    (force-mode-line-update)))

(add-hook 'exwm-update-class-hook #'exwmx--update-mode-line)
(add-hook 'exwm-update-title-hook #'exwmx--update-mode-line)
(add-hook 'buffer-list-update-hook #'exwmx--update-mode-line)

;; * Footer

(provide 'exwmx-buttons)

;;; exwmx-modeline.el ends here