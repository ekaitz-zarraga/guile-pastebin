;;; GNUPaste --- A Pastebin service for GNU
;;; Copyright © 2017 Kristofer Buffington <kristoferbuffington@gmail.com>
;;;
;;; This file is part of GNUPaste.
;;;
;;; GNUPaste is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNUPaste is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNUPaste.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnupaste paste)
  #:use-module (wiredtiger wiredtiger)
  #:use-module (wiredtiger extra)
  #:use-module (wiredtiger feature-space)
  #:use-module (wiredtiger grf3)
  #:use-module (srfi srfi-9)
  #:use-module (ice-9 rdelim)

  :export (new-paste
	   get-paste
	   make-paste
	   paste-name
	   paste-code))

(define (env) (env-open* (string-append (getcwd) "/wt")
			  (list *feature-space*)
			  "create"))

(define-record-type <paste>
  (make-paste name code)
  paste?
  (name paste-name)
  (code paste-code))

(define (uuid)
    (with-input-from-file
	"/proc/sys/kernel/random/uuid"
      (lambda ()
	(read-line (current-input-port)))))

(define (new-paste paste)
  (if (paste? paste)
      (with-env (env)
		(fs:add! `((kind . paste)
			   (paste/name . ,(paste-name paste))
			   (paste/code . ,(paste-code paste)))))
      #f))

(define (get-paste uid)
  (let* ((data (with-env (env)
			(fs:ref* uid)))
	 (name (cdar data))
	 (code (cdar (cdr data))))
    (make-paste name code)))