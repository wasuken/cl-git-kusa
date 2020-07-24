(defpackage cl-git-kusa
  (:use :cl))
(in-package :cl-git-kusa)

(defvar *user-event-url-format* "https://api.github.com/users/~S/events")

;; blah blah blah.
(defun stats (username)
  (let ((url (format nil *user-event-url-format* username))
		(events-json (json:decode-json-from-string (dex:get url))))
	(print (car events-json))))
