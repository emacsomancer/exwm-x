;;; exwmx-appconfig.el --- Send string to application

;; * Header
;; Copyright 2016-2017 Feng Shu

;; Author: Feng Shu <tumashu@163.com>
;; URL: https://github.com/tumashu/exwm-x
;; Version: 1.0
;; Keywords: window-manager, exwm

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

;; * exwmx-appconfig manual                                                   :doc:

;;; Code:

;; * Code                                                                 :code:
(require 'exwmx-core)

(defvar exwmx-appconfig-file (locate-user-emacs-file "exwm-x/exwmx-appconfig")
  "File which is used to record Exwm-X appconfig.

An appconfig is a property list, which record an application's class, instance,
title and other useful property used by Exwm-X commands.")

(defvar exwmx-appconfig-mode-map
  (let ((keymap (make-sparse-keymap)))
    (define-key keymap "\C-c\C-c" 'exwmx-appconfig-finish)
    (define-key keymap "\C-c\C-q" 'exwmx-appconfig-ignore)
    keymap)
  "Keymap for `exwmx-appconfig-mode'")

(define-minor-mode exwmx-appconfig-mode
  "Minor for exwmx-appconfig."
  nil " exwmx-appconfig" exwmx-appconfig-mode-map)

(defvar exwmx-appconfig-buffer " *exwmx-appconfig*")

;; Fix compile warn
(defvar exwmx-sendstring-default-paste-key)

(defun exwmx-appconfig--get-all-appconfigs ()
  "Get all appconfigs stored in `exwmx-appconfig-file'."
  (let ((file (expand-file-name exwmx-appconfig-file))
        appconfigs search-result)
    (when (file-readable-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (ignore-errors
          (while (not (eobp))
            (push (read (current-buffer)) appconfigs)))))
    appconfigs))

(defun exwmx-appconfig--search (string search-prop return-prop &optional equal)
  "Search record-plist from `exwmx-appconfig-file', if a record-plist
which property `search-prop' is match or equal (if `equal set to t) `string',
the value of property `return-prop' will be returned, if `return-prop' is t,
the record-plist will be returned. "
  (when (and string (stringp string))
    (let ((appconfigs (exwmx-appconfig--get-all-appconfigs))
          search-result)
      (while appconfigs
        (let* ((x (pop appconfigs))
               (search-string (plist-get x search-prop))
               (value (if (eq return-prop t)
                          x
                        (plist-get x return-prop))))
          (if equal
              (when (equal search-string string)
                (setq search-result value)
                (setq appconfigs nil))
            (when (or (exwmx--string-match-p string search-string)
                      (exwmx--string-match-p search-string string))
              (setq search-result value)
              (setq appconfigs nil)))))
      search-result)))

(defun exwmx-appconfig--insert-plist (plist)
  "Format a `plist' and insert to current buffer."
  (let ((first t))
    (insert "(")
    (while plist
      (let ((prop (pop plist))
            (value (pop plist)))
        (if first
            (setq first nil)
          (insert " "))
        (insert (format "%-15S" prop))
        (insert (format "%S" value))
        (when plist
          (insert "\n"))))
    (insert ")")))

(defun exwmx-appconfig ()
  "Exwm-X's application configure tool, which will pop to a buffer.
and insert a record-plist template to let user edit. then user can
use `exwmx-appconfig-file' to save the record to `exwmx-appconfig-file'
or use `exwmx-appconfig-ignore' ignore."
  (interactive)
  (if (not (derived-mode-p 'exwm-mode))
      (message "Exwm-X: No application is found.")
    (unless (file-readable-p exwmx-appconfig-file)
      (append-to-file "" nil exwmx-appconfig-file))
    (let* ((buffer (get-buffer-create exwmx-appconfig-buffer))
           (history (exwmx-appconfig--search
                     (md5 (concat exwm-class-name exwm-instance-name)) :key t t))
           (appconfig (list :command exwm-instance-name
                            :alias exwm-instance-name
                            :pretty-name exwm-instance-name
                            :paste-key exwmx-sendstring-default-paste-key
                            :class exwm-class-name
                            :instance exwm-instance-name
                            :title exwm-title)))
      (while history
        (let ((prop (pop history))
              (value (pop history)))
          (when (keywordp prop)
            (plist-put appconfig prop value))))
      (plist-put appconfig :key (md5 (concat exwm-class-name exwm-instance-name)))
      (with-current-buffer buffer
        (text-mode)
        (exwmx-appconfig-mode)
        (setq truncate-lines t)
        (erase-buffer)
        (exwmx-appconfig--insert-plist appconfig)
        (goto-char (point-min))
        (setq header-line-format
              (substitute-command-keys
               (concat
                "\\<exwmx-appconfig-mode-map>"
                "Appconfig: "
                "Finish with `\\[exwmx-appconfig-finish]', "
                "Ignore with `\\[exwmx-appconfig-ignore]'. "))))
      (pop-to-buffer buffer))))

(defun exwmx-appconfig--plist-p (list)
  "Non-null if and only if LIST is a plist with keyword keys."
  (while (consp list)
    (setq list (if (and (keywordp (car list))
                        (consp (cdr list)))
                   (cddr list)
                 'not-plist)))
  (null list))

(defun exwmx-appconfig-finish ()
  "Save edited appconfig to `exwmx-appconfig-file' then delete window."
  (interactive)
  (if exwmx-appconfig-mode
      (let (record)
        (goto-char (point-min))
        (setq record (read (current-buffer)))
        (goto-char (point-min))
        (if (not (exwmx-appconfig--plist-p record))
            (message "Exwm-X: the current appconfig has a syntax error, re-edit it again.")
          (exwmx-appconfig--add-record record)
          (delete-window)
          (kill-buffer exwmx-appconfig-buffer)))
    (message "Exwm-X: exwmx-appconfig-mode is not enabled.")))

(defun exwmx-appconfig--add-record (record)
  "Add `record' to appconfig file `exwmx-appconfig-file' and remove
all other records which :key is equal the :key of `record'."
  (let ((appconfigs (exwmx-appconfig--get-all-appconfigs))
        (key (plist-get record :key)))
    (when (and (exwmx-appconfig--plist-p record)
               (file-readable-p exwmx-appconfig-file))
      (with-temp-buffer
        (setq appconfigs
              (cons record
                    (cl-remove-if
                     #'(lambda (x)
                         (equal key (plist-get x :key)))
                     appconfigs)))
        (erase-buffer)
        (mapc
         #'(lambda (x)
             (insert (format "%S\n" x)))
         appconfigs)
        (write-file exwmx-appconfig-file)))))

(defun exwmx-appconfig-ignore ()
  "Ignore edited appconfig then delete window."
  (interactive)
  (if exwmx-appconfig-mode
      (progn
        (delete-window)
        (kill-buffer exwmx-appconfig-buffer))
    (message "Exwm-X: exwmx-appconfig-mode is not enabled.")))

(provide 'exwmx-appconfig)

;;; exwmx-appconfig.el ends here
