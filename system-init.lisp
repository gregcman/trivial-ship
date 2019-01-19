(defpackage #:temporary-loader
  (:use :cl))
(in-package :temporary-loader)

;;;;implementation dependent socket-code ripped from quicklisp.lisp
#+ (or ecl clasp mkcl)
(require 'sockets)
#+ (or lispworks)
(require "comm")
#+sbcl
(progn
  (require 'sb-posix)
  (require 'sb-bsd-sockets)

  (require 'asdf)

  (require 'sb-aclrepl)
  ;;(require 'sb-capstone)
  (require 'sb-cltl2)
  (require 'sb-concurrency)
  (require 'sb-cover)
  (require 'sb-executable)
  (require 'sb-gmp)
  (require 'sb-grovel)
  (require 'sb-introspect)
  (require 'sb-md5)
  (require 'sb-mpfr)
  (require 'sb-queue)
  (require 'sb-rotate-byte)
  (require 'sb-rt)
  (require 'sb-simple-streams)
  (require 'sb-sprof))

(defparameter *this-directory* nil)
(progn
  (defparameter *lisp-system-root* nil)
  (defparameter *system-root-name* nil)
  (defparameter *system-root-postfix* "_sys")
  (progn
    (defparameter *quicklisp-directory* nil)
    (progn
      (defparameter *quicklisp-setup-file* nil)
      ;;#+nil
      (defparameter *asdf-install-file* nil)
      ;;#+nil
      (defparameter *quicklisp-asdf-cache* nil)))
  (progn
    (defparameter *cache-files-name* "cache/")
    (defparameter *cache-files* nil))
  (progn
    (defparameter *other-files* nil)
    (defparameter *other-files-name* "other/")
    (progn
      (defparameter *quicklisp-install-file* nil))))
(defparameter *exe-name* nil)
(defparameter *exe-path* nil)

(defparameter *start-file* nil)
(defparameter *init-file-type* "lisp")
(defparameter *init-file-name* nil)

(defmacro etouq (&body body)
  (let ((var (gensym)))
    `(macrolet ((,var () ,@body))
       (,var))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun pathname-directory-pathname (pathname)
    "Returns a new pathname with same HOST, DEVICE, DIRECTORY as PATHNAME,
and NIL NAME, TYPE and VERSION components"
    (when pathname
      (make-pathname :name nil :type nil :version nil :defaults pathname)))
  ;;ripped from http://sodaware.sdf.org/notes/cl-read-file-into-string/
  (defun file-get-contents (filename)
    (with-open-file (stream filename)
      (let ((contents (make-string (file-length stream))))
	(read-sequence contents stream)
	contents))))
(defparameter *some-data*
  (etouq
    (let ((compile-path-this-file
	   (pathname-directory-pathname
	    (let ((value (or *compile-file-truename*
			     *load-truename*)))
	      (make-pathname :host (pathname-host value)
			     :directory (pathname-directory value))))))
      (list
       (quote quote)
       (list
	(file-get-contents
	 (merge-pathnames
	  "quicklisp.lisp"
	  compile-path-this-file))
	;;#+nil
	(file-get-contents
	 (merge-pathnames
	  "asdf.lisp"
	  compile-path-this-file)))))))

(defparameter *quicklisp-install-file-text*
  (first *some-data*))
;;#+nil
(defparameter *asdf-install-file-text*
  (second *some-data*))
(defun string-concatenate (&rest args)
  (apply 'concatenate 'string args))
(defun path-rootify (exe-name)
  (string-concatenate exe-name
		      *system-root-postfix*
		      "/"))
(defun path-startify (exe-name)
  (make-pathname :defaults exe-name
		 :type *init-file-type*))
;;ripped from UIOP
(defun eval-input (input)
  "Portably read and evaluate forms from INPUT, return the last values."
  (with-open-file (input input)
    (loop :with results :with eof ='#:eof
       :for form = (read input nil eof)
       :until (eq form eof)
       :do (setf results (multiple-value-list (eval form)))
       :finally (return (values-list results)))))
(defun dump-text-to-file (text file-path)
  (ensure-directories-exist file-path)
  (with-open-file (stream file-path
			  :direction :output
			  :if-exists :supersede
			  :if-does-not-exist :create)
    (write-string text stream)))
(defun find-symbol* (package name)
  (find-symbol (string name)
	       (find-package package)))
(defun symbol-call (package name &rest args)
  (apply (find-symbol* package name)
	 args))
(defun main (argv)
  (declare (ignorable argv))
  (setf *exe-path* sb-ext:*core-pathname*)
  (setf *exe-name* (pathname-name *exe-path*))
  (setf *this-directory*
	(pathname-directory-pathname *exe-path*))
  (progn
    (setf *system-root-name*
	  (path-rootify *exe-name*))
    (setf *lisp-system-root*
	  (merge-pathnames *system-root-name*
			   *this-directory*))
    (progn
      ;;the quicklisp directory
      (setf *quicklisp-directory*
	    (merge-pathnames "quicklisp/"
			     *lisp-system-root*))
      (ensure-directories-exist *quicklisp-directory*)
      (progn
	;;the quicklisp setup file when already installed
	(setf *quicklisp-setup-file*
	      (merge-pathnames "setup.lisp"
			       *quicklisp-directory*))
	
	;;the asdf install file, to be overwritten when
	;;#+nil
	(setf *asdf-install-file*
	      (merge-pathnames "asdf.lisp" *quicklisp-directory*))
	;;the asdf cache
	;;#+nil
	(setf *quicklisp-asdf-cache*
	      (merge-pathnames "cache/asdf-fasls/" *quicklisp-directory*))))

    (progn
      (setf *cache-files*
	    (merge-pathnames *cache-files-name*
			     *lisp-system-root*)))

    (progn
      ;;where quicklisp install file goes
      (setf *other-files*
	    (merge-pathnames *other-files-name*
			     *lisp-system-root*))
      (progn
	;;the quicklisp install file
	(setf *quicklisp-install-file*
	      (merge-pathnames "quicklisp.lisp" *other-files*)))))
  (progn
    ;;the configurable start file
    (setf *init-file-name*
	  (path-startify *exe-name*))
    (progn
      (setf *start-file*
	    (merge-pathnames *init-file-name*
			     *this-directory*))))
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
      (progn
	(dump-text-to-file *quicklisp-install-file-text*
			   *quicklisp-install-file*)
	(setf *quicklisp-install-file-text* nil))
      
      (load *quicklisp-install-file*)
      ;;FIXME::muffle quicklisp output?
      (symbol-call :quicklisp-quickstart 'install
	       :path *quicklisp-directory*)

      ;;ripped from fare's instructions on how to update quicklisp asdf:
      ;;https://stackoverflow.com/questions/45043190/updating-to-asdf-3-x-in-clisp
      ;;;overwrite the old asdf
      ;;#+nil
      (progn
	(dump-text-to-file *asdf-install-file-text*
			   *asdf-install-file*)
	(setf *asdf-install-file-text* nil))

      #+nil
      (progn
	;;FIXME::is loading necessary here?
	(load *asdf-install-file*)
	;;FIXME::dangerous?
	(symbol-call
	 :uiop 'delete-directory-tree		   
	 *quicklisp-asdf-cache*
	 :validate
	 (lambda (x)
	   ;;final check that the directory is named as such
	   (string=
	    "asdf-fasls"
	    (car (last (pathname-directory x)))))
	 :if-does-not-exist :ignore))))
  ;;by this point asdf should be loaded? 
  (setf (symbol-value (list (find-symbol* :asdf '*user-cache*)))
	(list *cache-files*))
  (unless (find :quicklisp *features*)
    (load *quicklisp-setup-file*))
    
  (if (probe-file *start-file*)
      (progn
	(delete-package :temporary-loader)
	(let ((*default-pathname-defaults* *this-directory*))
	  (eval-input *start-file*)))
      (format t "No ~a found in ~a"
	      *init-file-name*
	      *this-directory*)))
