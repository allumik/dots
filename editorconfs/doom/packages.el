;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el
(package! emacsql-sqlite3)

(package! diredfl :disable t)
(package! dired-hacks)
(package! dired-single)           ;; dired conveniences, helps with the ranger setup
(package! dired+)

(package! golden-ratio)           ;; resize windows

(package! org-fragtog)            ;; autorender latex in org
(package! org-pandoc-import
  :recipe (:host github
           :repo "tecosaur/org-pandoc-import"
           :files ("*.el" "filters" "preprocessors"))) ;; convert heretical file formats

(package! polymode)
(package! poly-noweb)
(package! poly-markdown)

(package! yascroll)
(package! quarto-mode)
