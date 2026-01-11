;;; package-inception.el --- because package.el sucks ass  -*- lexical-binding:t -*-

(require 'package)
(require 'project)

(defsubst package-where ()
  (make-directory (file-name-directory project-list-file) t)
  (directory-file-name (expand-file-name (project-root (project-current)))))

(defsubst package-desc (main-file)
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name main-file (package-where)))
    (package-buffer-info)))

(defun package-versioned-name (main-file)
  (let ((pkg-desc (package-desc main-file)))
    (concat (symbol-name (package-desc-name pkg-desc))
	    "-" (package-version-join (package-desc-version pkg-desc)))))

(defun package-inception (main-file &rest other-files)
  "To get a -pkg.el file, you need to run `package-unpack'.
To run `package-unpack', you need a -pkg.el."
  (let* ((pkg-dir (expand-file-name
		   (package-versioned-name main-file)
		   (package-where))))
    (ignore-errors (delete-directory pkg-dir t))
    (make-directory pkg-dir t)
    (dolist (f (cons main-file other-files))
      (copy-file (expand-file-name f (package-where))
		 (expand-file-name f pkg-dir)))
    (package--make-autoloads-and-stuff (package-desc main-file) pkg-dir)))
