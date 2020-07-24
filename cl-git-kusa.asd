(defsystem "cl-git-kusa"
  :version "0.1.0"
  :author ""
  :license ""
  :depends-on ("cl-rainbow" "cl-json" "dexador"
							"cl-ppcre" "chronicity" "mylib" "local-time")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "cl-git-kusa/tests"))))

(defsystem "cl-git-kusa/tests"
  :author ""
  :license ""
  :depends-on ("cl-git-kusa"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cl-git-kusa"
  :perform (test-op (op c) (symbol-call :rove :run c)))
