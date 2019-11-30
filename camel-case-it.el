(defun camel-case-it ()
  (search-forward-regexp ":.+_.+:")
  (backward-word)
  (string-inflection-lower-camelcase))
