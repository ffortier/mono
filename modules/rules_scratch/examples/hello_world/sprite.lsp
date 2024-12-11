(when flag-clicked
    (call "say something ~s" ("hello world"))
)
(define "say something ~s" (value)
    (say value)
)