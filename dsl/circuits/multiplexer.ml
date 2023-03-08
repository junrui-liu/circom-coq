open Ast
open Dsl
open Typecheck

let i = v "i"

let w = v "w"

let x = v "x"

let in1 = v "in1"

let in2 = v "in2"

let ins = v "ins"

let aux = v "aux"

let out = v "out"

let t_arr_tf k = tarr tf QTrue k

(* { F | v = in1[0] * in2[0] + ... + in1[k] * in2[k] } *)
let t_ep k =
  tfq
    (qeq nu
       (sum z0 k
          (map (lama "x" (ttuple [tf; tf]) (fmul (tget x 0) (tget x 1))) ins) ) )

(* \i x => x + aux[i] *)
let lam_ep = lama "i" tint (lama "x" tf (fadd x (get aux i)))

let inv_ep i _ = t_ep i

let escalar_product =
  Circuit
    { name= "EscalarProduct"
    ; inputs= [("w", tnat); ("in1", t_arr_tf w); ("in2", t_arr_tf w)]
    ; outputs= [("out", t_ep w)]
    ; dep= None
    ; body=
        [ (* ins = zip in1 in2 *)
          slet "ins" (zip in1 in2)
        ; (* aux = map (\(i1, i2) => i1 * i2) ins *)
          slet "aux"
            (map (lama "x" (ttuple [tf; tf]) (fmul (tget x 0) (tget x 1))) ins)
        ; (* out === iter 0 w lam_ep 0 *)
          assert_eq out (iter z0 w lam_ep f0 inv_ep) ] }

let check_escalar_product = typecheck_circuit d_empty escalar_product
