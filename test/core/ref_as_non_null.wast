(module
  (type $t (func (result i32)))

  (func $nn (param $r (ref $t)) (result i32)
    (call_ref (ref.as_non_null (type $t) (local.get $r)))
  )
  (func $n (param $r (ref null $t)) (result i32)
    (call_ref (ref.as_non_null (type $t) (local.get $r)))
  )

  (elem func $f)
  (func $f (result i32) (i32.const 7))

  (func (export "nullable-null") (result i32) (call $n (ref.null (type $t))))
  (func (export "nonnullable-f") (result i32) (call $nn (ref.func $f)))
  (func (export "nullable-f") (result i32) (call $n (ref.func $f)))

  (func (export "unreachable") (result i32)
    (unreachable)
    (ref.as_non_null (type $t))
    (call $nn)
  )
)

(assert_trap (invoke "unreachable") "unreachable")

(assert_trap (invoke "nullable-null") "null reference")
(assert_return (invoke "nonnullable-f") (i32.const 7))
(assert_return (invoke "nullable-f") (i32.const 7))

(assert_invalid
  (module
    (type $t (func (result i32)))
    (func $g (param $r (ref $t)) (drop (ref.as_non_null (type $t) (local.get $r))))
    (func (call $g (ref.null (type $t))))
  )
  "type mismatch"
)


(module
  (type $t (func))
  (func (param $r (ref $t)) (drop (ref.as_non_null (type $t) (local.get $r))))
  (func (param $r (ref func)) (drop (ref.as_non_null func (local.get $r))))
  (func (param $r (ref extern)) (drop (ref.as_non_null extern (local.get $r))))
)