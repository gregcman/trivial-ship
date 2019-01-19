(defpackage #:temporary-loader
  (:use :cl))
(in-package :temporary-loader)

;;;;implementation dependent socket-code ripped from quicklisp.lisp
#+ (or ecl clasp mkcl)
(require 'sockets)
#+ (or lispworks)
(require "comm")
#+sbcl
(require 'sb-bsd-sockets)

(defparameter *this-directory* nil)
(defparameter *quicklisp-directory* nil)
(defparameter *quicklisp-setup-file* nil)
(defparameter *quicklisp-install-file* nil)
(defparameter *exe-path* nil)
(defparameter *start-file* nil)
(defparameter *lisp-system-root* nil)

(defparameter *system-root-postfix* "_sys")
(defparameter *init-file-type* "lisp")
(defparameter *system-root-name* nil)
(defparameter *init-file-name* nil)
(defparameter *exe-name* nil)

(defmacro etouq (&body body)
    (let ((var (gensym)))
      `(macrolet ((,var () ,@body))
	 (,var))))
(defmacro this-directory ()
  `(etouq (let ((value (or *compile-file-truename*
			   *load-truename*)))
	    (make-pathname :host (pathname-host value)
			   :directory (pathname-directory value)))))
(defparameter *quicklisp-install-file-text*
  (etouq (uiop:read-file-string
	  (merge-pathnames
	   "quicklisp.lisp"
	   (uiop:pathname-directory-pathname (this-directory))))))
(defun string-concatenate (&rest args)
  (apply 'concatenate 'string args))
(defun path-rootify (exe-name)
  (string-concatenate exe-name
		      *system-root-postfix*
		      "/"))
(defun path-startify (exe-name)
  (make-pathname :defaults exe-name
		 :type *init-file-type*))
(defun main (argv)
  (declare (ignorable argv))
  (setf *exe-path* sb-ext:*core-pathname*)
  (setf *exe-name* (pathname-name *exe-path*))
  (setf *this-directory*
	(uiop:pathname-directory-pathname *exe-path*))
  (setf *system-root-name*
	(path-rootify *exe-name*))
  (setf *lisp-system-root*
	(merge-pathnames *system-root-name*
			 *this-directory*))
  ;;the quicklisp directory
  (setf *quicklisp-directory*
	(merge-pathnames "quicklisp/"
			 *lisp-system-root*))
  (ensure-directories-exist *quicklisp-directory*)
  ;;the quicklisp setup file when already installed
  (setf *quicklisp-setup-file*
	(merge-pathnames "setup.lisp"
			 *quicklisp-directory*))
  ;;the quicklisp install file
  (setf *quicklisp-install-file*
	(merge-pathnames "quicklisp.lisp" *quicklisp-directory*))

  ;;the configurable start file
  (setf *init-file-name*
	(path-startify *exe-name*))
  (setf *start-file*
	(merge-pathnames *init-file-name*
			 *this-directory*))
  #+nil
  (print (list argv
	       *exe-path*
	       *this-directory*
	       *quicklisp-directory*
	       *quicklisp-setup-file*
	       *quicklisp-install-file*
	       *start-file*
	       *quicklisp-install-file-text*))
  
  (let ((setup-exists? (probe-file *quicklisp-setup-file*)))
    (unless setup-exists?
      (with-open-file (stream *quicklisp-install-file*
			      :direction :output
			      :if-exists :supersede
			      :if-does-not-exist :create)
	(write-string *quicklisp-install-file-text* stream))
      (load *quicklisp-install-file*)
      (uiop:symbol-call :quicklisp-quickstart
			:install
			:path *quicklisp-directory*)) 
    (unless (find :quicklisp *features*)
      (load *quicklisp-setup-file*)))
  
  (if (probe-file *start-file*)
      (progn
	(delete-package :temporary-loader)
	(uiop:eval-input *start-file*))
      (format t "No ~a found in ~a"
	      *init-file-name*
	      *this-directory*)))
