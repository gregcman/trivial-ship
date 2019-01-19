(defpackage #:trivial-ship
  (:use :cl))
(in-package :trivial-ship)

(defparameter *this-directory* (asdf:system-source-directory :trivial-ship))
(defparameter *bin-folder* "bin")

(defun featurep (n)
  (find n *features*))
(defun stringify (&rest args)
  (setf args (mapcar 'string args))
  (apply 'concatenate 'string args))

(defun find-arch ()
  (find-if 'featurep *archs*))
(defun find-os ()
  (find-if 'featurep *operating-systems*))

;;see https://superuser.com/questions/358855/what-characters-are-safe-in-cross-platform-file-names-for-linux-windows-and-os
(defun strip-bad-chars (&optional (string "asdf--sdf"))
  ;;replace hyphen with underscore
  (substitute #\_ #\- string))

(defparameter *archs*
  '(:X86
    :X86-64
    :PPC
    :PPC64
    :MIPS
    :ALPHA
    :SPARC
    :SPARC64
    :HPPA
    :HPPA64))
(defparameter *operating-systems*
  '(:WINDOWS
    :DARWIN
    :LINUX
    :NETBSD
    :OPENBSD
    :FREEBSD))

(defun wat ()
  (make-pathname :defaults *this-directory*
		 :directory (append (pathname-directory *this-directory*)
				    (list
				     *bin-folder*
				     (strip-bad-chars (stringify (find-os)))
				     (strip-bad-chars (stringify (find-arch)))))))
(defun buildapp-path ()
  (merge-pathnames "buildapp" (wat)))

(defun build-buildapp ()
  (let ((top (buildapp-path)))
    (ensure-directories-exist top)
    (buildapp:build-buildapp top)))


buildapp --load-system uiop --load "system-init.lisp" --entry temporary-loader::main --output "build\\puprun"
