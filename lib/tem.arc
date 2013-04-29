(= templates* (table))

(mac deftem (tem . fields)
  (withs (name (carif tem) includes (if (acons tem) (cdr tem)))
    `(= (templates* ',name)
        (+ (mappend templates* ',(rev includes))
           (list ,@(map (fn ((k v)) `(list ',k (fn () ,v)))
                        (pair fields)))))))

(mac addtem (name . fields)
  `(= (templates* ',name)
      (union (fn (x y) (is (car x) (car y)))
             (list ,@(map (fn ((k v)) `(list ',k (fn () ,v)))
                          (pair fields)))
             (templates* ',name))))

; (tagged 'tem (tem-type fields nils))
(def inst (tem-type . args)
  (annotate 'tem (list tem-type
                       (let default-vals (map (fn((k v))
                                           (list k (v)))
                                         templates*.tem-type)
                         (coerce (+ default-vals pair.args)
                                 'table))
                       (memtable (map car (keep no:cadr pair.args))))))

(extend sref (tem v k) (isa tem 'tem)
  (sref rep.tem.1 v k)
  (if v
    (wipe rep.tem.2.k)
    (set rep.tem.2.k)))

(defcall tem (tem k)
  (or rep.tem.1.k
      (if (no rep.tem.2.k)
        (aif (alref (templates* rep.tem.0) k) (it)))))

(extend copy (x . args)   ($.vector? x)
  ; tagged type
  ($.vector-map copy x))

(defmethod iso(a b) tem
  (and (isa a 'tem)
       (isa b 'tem)
       (iso rep.a rep.b)))

(def temload (tem file)
  (w/infile i file (temread tem i)))

(def temloadall (tem file)
  (w/infile i file (drain:temread tem i)))

(def temstore (tem val file)
  (writefile (temlist tem val) file))

(def temread (tem (o str (stdin)))
  (reading fields str
    (listtem tem fields)))

(def temwrite (tem val (o o (stdout)))
  (write (temlist tem val) o))

; coerce alist to a specific template
(def listtem (tem fields)
  (apply inst tem (if fields (apply + fields))))

; like tablist, but include explicitly-set nil fields
(def temlist (tem val)
  (ret fields (coerce rep.val.1 'cons)
    (each nil-field (coerce rep.val.2 'cons)
      (push (list car.nil-field nil) fields))))

(def tem-report()
  (prn "after writing to file and reading back:")
  (let value (fn(template init)
               (if (~is template 'absent)
                 (deftem foo field template)
                 (deftem foo))
               (= x1
                  (if (~is init 'absent)
                    (inst 'foo 'field init)
                    (inst 'foo)))
               (= x2 (temlist 'foo x1))
               (= x3 (listtem 'foo x2))
               x3!field)
    (each template '(absent nil 1)
      (each init '(absent nil 2)
        (prn "  if default was " template " and inst field was " init " => read back " (value template init))))))
