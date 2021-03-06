(define (enclosing-environment env) (cdr env))
(define (first-frame env) (car env))
(define (the-empty-environment '()))

(define (make-frame vars vals) (zip vars vals))
(define (add-binding-to-frame! var val frame)
  (set-car! frame (cons (cons var val) frame)))

(define (extend-environment vars vals base-env)
  (if (= length vars) (length vals)
      (cons (make-frame vars vals) base-env)
      (if (< (length vars) (length vals))
          (error "Too many arguments supplied" vars vals)
          (error "Too few arguments supplied" vars vals))))

(define (env-loop var env on-null-bindings on-eq-var)
  (define (scan bindings)
    (cond ((null? bindings)
           (on-null-bingdings env))
          ((eq? var (car (car bindings)))
           (on-eq-var (car bindings)))
          (else (scan (cdr bindings)))))
  (if (eq? env the-empty-environment)
      (error "Unknown varialbe" var)
      (scan (first-frame env))))

(define (lookup-variable-value var env)
  (define (on-null-bindings env)
    (env-loop var (enclosing-environment env) on-null-bindings on-eq-var))
  (define (on-eq-var binding)
    (car binding))
  (env-loop var env on-null-bindings on-eq-var))

(define (set-variable-value! var val env)
  (define (on-null-bindings env)
    (env-loop var (enclosing-environment env) on-null-bindings on-eq-var))
  (define (on-eq-var binding)
    (set-cdr! binding val))
  (env-loop var env on-null-bindings on-eq-var))

(define (define-variable! var val env)
  (define (on-null-bindings env)
    (add-binding-to-frame! var val (first-frame env)))
  (define (on-eq-var binding)
    (set-cdr! binding val))
  (env-loop var env on-null-bindings on-eq-var))
