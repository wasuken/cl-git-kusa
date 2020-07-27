(defpackage cl-git-kusa
  (:use :cl)
  (:export :stats))
(in-package :cl-git-kusa)

(defvar *user-event-url-format* "https://api.github.com/users/~a/events?page=~a&per_page=100")
(defvar *space* " ")

(defun date-groupby (events table)
  (loop for e in events
	 do (let* ((created-at (car (ppcre:split "T" (cdr (find :created--at e :key #'car)))))
			   (target (gethash created-at table)))
		  (if (null target)
			  (setf (gethash created-at table)
					`((:count 1)))
			  (setf (gethash created-at table)
					`((:count ,(1+ (cadr (find :count
											   target
											   :key #'car)))))))))
  table)

(defun print-calendar (table)
  (let ((one-years-ago-last-sunday
		 (chronicity:parse "last sunday"
						   :now (chronicity:parse "1 years ago")))
		(cnt 0)
		(max-weeks 54))
	(loop for i from 0 to 6
	   do (progn
			(format t "~a ~~ ~a:"
					(local-time:format-timestring
					 nil
					 (chronicity:parse (format nil "~a days after" i)
									   :now one-years-ago-last-sunday)
					 :format '((:year 4) #\- (:month 2) #\- (:day 2)))
					(local-time:format-timestring
					 nil
					 (chronicity:parse (format nil "~a days after" (- (* max-weeks 7) (- 6 i)))
									   :now one-years-ago-last-sunday)
					 :format '((:year 4) #\- (:month 2) #\- (:day 2))))
			(loop for j from 1 to max-weeks
			   do (let* ((dt-str (format nil
									  "~a days after"
									  (+ i (* j 7))))
						 (datetime-string (local-time:format-timestring
										   nil
										   (chronicity:parse dt-str
															 :now one-years-ago-last-sunday)
										   :format '((:year 4) #\- (:month 2) #\- (:day 2)))))
					(if (gethash datetime-string table)
						(format t (cl-rainbow:background :green *space*))
						(format t (cl-rainbow:background :white *space*)))
					(incf cnt)))
			(format t "~%")))))

(defun event-table-print (table)
  (maphash #'(lambda (k v)
			   (format t "~a"
					   (cl-rainbow:color #x7fff00
										 (format nil "date:~a => count:~a~%"
												 k
												 (cadr (find :count v :key #'car))))))
		   table))

(defun safe-get->json (url)
  (let ((resp ""))
	(handler-bind ((dex:http-request-failed #'(lambda (x) ()))
				   (dex:http-request-forbidden #'(lambda (x) ())))
	  (let ((body (dex:request url)))
		(setf resp body)))
	(json:decode-json-from-string resp)))

(defun stats (username)
  (setf chronicity:*now* (chronicity:parse (mylib:get-format-date)))
  (setf cl-rainbow:*enabled* t)
  (let ((table (make-hash-table :test #'equal))
		(empty? nil)
		(max-page (multiple-value-bind (body status headers)
					  (dex:request (format nil *user-event-url-format* username 1) :method :get)
					(parse-integer (nth 1 (ppcre:split "=" (car (ppcre:split "&" (nth 1 (ppcre:split "\\?" (ppcre:regex-replace-all "<|>| " (nth 1 (ppcre:split "," (nth 1 (ppcre:split ";" (gethash "link" headers))))) "")))))))))))
	(loop for i from 1 to max-page
	   do (let* ((url (format nil *user-event-url-format* username i))
				 (events-json (safe-get->json url))
				 (push-events (remove-if-not #'(lambda (x)
												 (string= "PushEvent"
														  (cdr (find :type x :key #'car))))
											 events-json)))
			(if events-json
				(setf table (date-groupby push-events table))
				(setf empty? t))
			(sleep 3)))
	(print-calendar table)))
