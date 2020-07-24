(defpackage cl-git-kusa/tests/main
  (:use :cl
        :cl-git-kusa
        :rove))
(in-package :cl-git-kusa/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-git-kusa)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
