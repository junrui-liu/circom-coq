open Ast
open Dsl
open Nice_dsl
open Expr

(* open Qual *)
open Typ
(* open TypRef *)

(* -------------------------------------------------------------------------- *)
(* Included from `semaphore.ml` *)
(* -------------------------------------------------------------------------- *)

let identityNullifier = v "identityNullifier"

let externalNullifier = v "externalNullifier"

let u_calc_null_hash x y = unint "CalculateNullifierHash" [x; y]

(* { F | nu =  #CalculateNullifierHash externalNullifier identityNullifier } *)
let t_semaphore_null_hash_qual =
  qeq nu (u_calc_null_hash externalNullifier identityNullifier)

let identityNullifier = v "identityNullifier"

let identityTrapdoor = v "identityTrapdoor"

let t_semaphore_null_hash = tfq t_semaphore_null_hash_qual

let u_calc_id_commit x = unint "CalculateIdentityCommitment" [x]

let u_calc_secret x y = unint "CalculateSecret" [x; y]

let u_calc_null_hash x y = unint "CalculateNullifierHash" [x; y]

let u_mrkl_tree_incl_pf xs i s = unint "MerkleTreeInclusionProof" [xs; i; s]

(* { F | nu = #MerkleTreeInclusionProof
         (#CalculateIdentityCommitment (#CalculateSecret identityNullifier identityTrapdoor))
         treePathIndices treeSiblings } *)
let t_semaphore_root_qual treePathIndices treeSiblings =
  qeq nu
    (u_mrkl_tree_incl_pf
       (u_calc_id_commit (u_calc_secret identityNullifier identityTrapdoor))
       treePathIndices treeSiblings )

let t_semaphore_root treePathIndices treeSiblings =
  tfq (t_semaphore_root_qual treePathIndices treeSiblings)

let semaphore_outputs =
  [ ( "root"
    , t_semaphore_root
        ( const_array field
        @@ List.map var
             [ "treePathIndices_i0"
             ; "treePathIndices_i1"
             ; "treePathIndices_i2"
             ; "treePathIndices_i3"
             ; "treePathIndices_i4"
             ; "treePathIndices_i5"
             ; "treePathIndices_i6"
             ; "treePathIndices_i7"
             ; "treePathIndices_i8"
             ; "treePathIndices_i9"
             ; "treePathIndices_i10"
             ; "treePathIndices_i11"
             ; "treePathIndices_i12"
             ; "treePathIndices_i13"
             ; "treePathIndices_i14"
             ; "treePathIndices_i15"
             ; "treePathIndices_i16"
             ; "treePathIndices_i17"
             ; "treePathIndices_i18"
             ; "treePathIndices_i19" ] )
        ( const_array field
        @@ List.map var
             [ "treeSiblings_i0"
             ; "treeSiblings_i1"
             ; "treeSiblings_i2"
             ; "treeSiblings_i3"
             ; "treeSiblings_i4"
             ; "treeSiblings_i5"
             ; "treeSiblings_i6"
             ; "treeSiblings_i7"
             ; "treeSiblings_i8"
             ; "treeSiblings_i9"
             ; "treeSiblings_i10"
             ; "treeSiblings_i11"
             ; "treeSiblings_i12"
             ; "treeSiblings_i13"
             ; "treeSiblings_i14"
             ; "treeSiblings_i15"
             ; "treeSiblings_i16"
             ; "treeSiblings_i17"
             ; "treeSiblings_i18"
             ; "treeSiblings_i19" ] ) )
  ; ("nullifierHash", t_semaphore_null_hash) ]

(* -------------------------------------------------------------------------- *)
(* Circom->Coda *)
(* -------------------------------------------------------------------------- *)

let circuit_Sigma =
  Circuit
    { name= "circuit_Sigma"
    ; inputs= [("in", field)]
    ; outputs= [("out", field)]
    ; dep= None
    ; body=
        elet "in2" F.(var "in" * var "in")
        @@ elet "in4" F.(var "in2" * var "in2")
        @@ elet "out" F.(var "in4" * var "in")
        @@ var "out" }

(* The circuit "circuit_Mix" is uninterpreted *)

(* The circuit "circuit_MixS" is uninterpreted *)

(* The circuit "circuit_MixLast" is uninterpreted *)

(* The circuit "circuit_PoseidonEx" is uninterpreted *)

(* The circuit "circuit_Poseidon" is uninterpreted *)

let circuit_CalculateSecret =
  Circuit
    { name= "circuit_CalculateSecret"
    ; inputs= [("identityNullifier", field); ("identityTrapdoor", field)]
    ; outputs= [("out", field)]
    ; dep= None
    ; body=
        elet "poseidon_dot_inputs_i0" (var "identityNullifier")
        @@ elet "poseidon_dot_inputs_i1" (var "identityTrapdoor")
        @@ elet "poseidon_result"
             (call "circuit_Poseidon"
                [var "poseidon_dot_inputs_i0"; var "poseidon_dot_inputs_i1"] )
        @@ elet "poseidon_dot_out" (var "poseidon_result")
        @@ elet "out" (var "poseidon_dot_out")
        @@ var "out" }

let circuit_CalculateIdentityCommitment =
  Circuit
    { name= "circuit_CalculateIdentityCommitment"
    ; inputs= [("secret", field)]
    ; outputs= [("out", field)]
    ; dep= None
    ; body=
        elet "poseidon_dot_inputs_i0" (var "secret")
        @@ elet "poseidon_result"
             (call "circuit_Poseidon" [var "poseidon_dot_inputs_i0"])
        @@ elet "poseidon_dot_out" (var "poseidon_result")
        @@ elet "out" (var "poseidon_dot_out")
        @@ var "out" }

let circuit_CalculateNullifierHash =
  Circuit
    { name= "circuit_CalculateNullifierHash"
    ; inputs= [("externalNullifier", field); ("identityNullifier", field)]
    ; outputs= [("out", field)]
    ; dep= None
    ; body=
        elet "poseidon_dot_inputs_i0" (var "externalNullifier")
        @@ elet "poseidon_dot_inputs_i1" (var "identityNullifier")
        @@ elet "poseidon_result"
             (call "circuit_Poseidon"
                [var "poseidon_dot_inputs_i0"; var "poseidon_dot_inputs_i1"] )
        @@ elet "poseidon_dot_out" (var "poseidon_result")
        @@ elet "out" (var "poseidon_dot_out")
        @@ var "out" }

(* The circuit "circuit_MultiMux1" is uninterpreted *)

let circuit_MerkleTreeInclusionProof =
  Circuit
    { name= "circuit_MerkleTreeInclusionProof"
    ; inputs=
        [ ("leaf", field)
        ; ("pathIndices_i0", field)
        ; ("pathIndices_i1", field)
        ; ("pathIndices_i2", field)
        ; ("pathIndices_i3", field)
        ; ("pathIndices_i4", field)
        ; ("pathIndices_i5", field)
        ; ("pathIndices_i6", field)
        ; ("pathIndices_i7", field)
        ; ("pathIndices_i8", field)
        ; ("pathIndices_i9", field)
        ; ("pathIndices_i10", field)
        ; ("pathIndices_i11", field)
        ; ("pathIndices_i12", field)
        ; ("pathIndices_i13", field)
        ; ("pathIndices_i14", field)
        ; ("pathIndices_i15", field)
        ; ("pathIndices_i16", field)
        ; ("pathIndices_i17", field)
        ; ("pathIndices_i18", field)
        ; ("pathIndices_i19", field)
        ; ("siblings_i0", field)
        ; ("siblings_i1", field)
        ; ("siblings_i2", field)
        ; ("siblings_i3", field)
        ; ("siblings_i4", field)
        ; ("siblings_i5", field)
        ; ("siblings_i6", field)
        ; ("siblings_i7", field)
        ; ("siblings_i8", field)
        ; ("siblings_i9", field)
        ; ("siblings_i10", field)
        ; ("siblings_i11", field)
        ; ("siblings_i12", field)
        ; ("siblings_i13", field)
        ; ("siblings_i14", field)
        ; ("siblings_i15", field)
        ; ("siblings_i16", field)
        ; ("siblings_i17", field)
        ; ("siblings_i18", field)
        ; ("siblings_i19", field) ]
    ; outputs= [("root", field)]
    ; dep= None
    ; body=
        elet "hashes_i0" (var "leaf")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i0" * F.(F.const 1 - var "pathIndices_i0"))
                (F.const 0) )
        @@ elet "mux_dot_c_i0_i0" (var "hashes_i0")
        @@ elet "mux_dot_c_i0_i1" (var "siblings_i0")
        @@ elet "mux_dot_c_i1_i0" (var "siblings_i0")
        @@ elet "mux_dot_c_i1_i1" (var "hashes_i0")
        @@ elet "mux_dot_s" (var "pathIndices_i0")
        @@ elet "mux_result"
             (call "circuit_MultiMux1"
                [ var "mux_dot_c_i0_i0"
                ; var "mux_dot_c_i0_i1"
                ; var "mux_dot_c_i1_i0"
                ; var "mux_dot_c_i1_i1"
                ; var "mux_dot_s" ] )
        @@ elet "mux_dot_out_i0" (project (var "mux_result") 1)
        @@ elet "mux_dot_out_i1" (project (var "mux_result") 0)
        @@ elet "poseidons_dot_inputs_i0" (var "mux_dot_out_i0")
        @@ elet "poseidons_dot_inputs_i1" (var "mux_dot_out_i1")
        @@ elet "poseidons_result"
             (call "circuit_Poseidon"
                [var "poseidons_dot_inputs_i0"; var "poseidons_dot_inputs_i1"] )
        @@ elet "poseidons_dot_out" (var "poseidons_result")
        @@ elet "hashes_i1" (var "poseidons_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i1" * F.(F.const 1 - var "pathIndices_i1"))
                (F.const 0) )
        @@ elet "mux_c1_dot_c_i0_i0" (var "hashes_i1")
        @@ elet "mux_c1_dot_c_i0_i1" (var "siblings_i1")
        @@ elet "mux_c1_dot_c_i1_i0" (var "siblings_i1")
        @@ elet "mux_c1_dot_c_i1_i1" (var "hashes_i1")
        @@ elet "mux_c1_dot_s" (var "pathIndices_i1")
        @@ elet "mux_c1_result"
             (call "circuit_MultiMux1"
                [ var "mux_c1_dot_c_i0_i0"
                ; var "mux_c1_dot_c_i0_i1"
                ; var "mux_c1_dot_c_i1_i0"
                ; var "mux_c1_dot_c_i1_i1"
                ; var "mux_c1_dot_s" ] )
        @@ elet "mux_c1_dot_out_i0" (project (var "mux_c1_result") 1)
        @@ elet "mux_c1_dot_out_i1" (project (var "mux_c1_result") 0)
        @@ elet "poseidons_c1_dot_inputs_i0" (var "mux_c1_dot_out_i0")
        @@ elet "poseidons_c1_dot_inputs_i1" (var "mux_c1_dot_out_i1")
        @@ elet "poseidons_c1_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c1_dot_inputs_i0"
                ; var "poseidons_c1_dot_inputs_i1" ] )
        @@ elet "poseidons_c1_dot_out" (var "poseidons_c1_result")
        @@ elet "hashes_i2" (var "poseidons_c1_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i2" * F.(F.const 1 - var "pathIndices_i2"))
                (F.const 0) )
        @@ elet "mux_c2_dot_c_i0_i0" (var "hashes_i2")
        @@ elet "mux_c2_dot_c_i0_i1" (var "siblings_i2")
        @@ elet "mux_c2_dot_c_i1_i0" (var "siblings_i2")
        @@ elet "mux_c2_dot_c_i1_i1" (var "hashes_i2")
        @@ elet "mux_c2_dot_s" (var "pathIndices_i2")
        @@ elet "mux_c2_result"
             (call "circuit_MultiMux1"
                [ var "mux_c2_dot_c_i0_i0"
                ; var "mux_c2_dot_c_i0_i1"
                ; var "mux_c2_dot_c_i1_i0"
                ; var "mux_c2_dot_c_i1_i1"
                ; var "mux_c2_dot_s" ] )
        @@ elet "mux_c2_dot_out_i0" (project (var "mux_c2_result") 1)
        @@ elet "mux_c2_dot_out_i1" (project (var "mux_c2_result") 0)
        @@ elet "poseidons_c2_dot_inputs_i0" (var "mux_c2_dot_out_i0")
        @@ elet "poseidons_c2_dot_inputs_i1" (var "mux_c2_dot_out_i1")
        @@ elet "poseidons_c2_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c2_dot_inputs_i0"
                ; var "poseidons_c2_dot_inputs_i1" ] )
        @@ elet "poseidons_c2_dot_out" (var "poseidons_c2_result")
        @@ elet "hashes_i3" (var "poseidons_c2_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i3" * F.(F.const 1 - var "pathIndices_i3"))
                (F.const 0) )
        @@ elet "mux_c3_dot_c_i0_i0" (var "hashes_i3")
        @@ elet "mux_c3_dot_c_i0_i1" (var "siblings_i3")
        @@ elet "mux_c3_dot_c_i1_i0" (var "siblings_i3")
        @@ elet "mux_c3_dot_c_i1_i1" (var "hashes_i3")
        @@ elet "mux_c3_dot_s" (var "pathIndices_i3")
        @@ elet "mux_c3_result"
             (call "circuit_MultiMux1"
                [ var "mux_c3_dot_c_i0_i0"
                ; var "mux_c3_dot_c_i0_i1"
                ; var "mux_c3_dot_c_i1_i0"
                ; var "mux_c3_dot_c_i1_i1"
                ; var "mux_c3_dot_s" ] )
        @@ elet "mux_c3_dot_out_i0" (project (var "mux_c3_result") 1)
        @@ elet "mux_c3_dot_out_i1" (project (var "mux_c3_result") 0)
        @@ elet "poseidons_c3_dot_inputs_i0" (var "mux_c3_dot_out_i0")
        @@ elet "poseidons_c3_dot_inputs_i1" (var "mux_c3_dot_out_i1")
        @@ elet "poseidons_c3_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c3_dot_inputs_i0"
                ; var "poseidons_c3_dot_inputs_i1" ] )
        @@ elet "poseidons_c3_dot_out" (var "poseidons_c3_result")
        @@ elet "hashes_i4" (var "poseidons_c3_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i4" * F.(F.const 1 - var "pathIndices_i4"))
                (F.const 0) )
        @@ elet "mux_c4_dot_c_i0_i0" (var "hashes_i4")
        @@ elet "mux_c4_dot_c_i0_i1" (var "siblings_i4")
        @@ elet "mux_c4_dot_c_i1_i0" (var "siblings_i4")
        @@ elet "mux_c4_dot_c_i1_i1" (var "hashes_i4")
        @@ elet "mux_c4_dot_s" (var "pathIndices_i4")
        @@ elet "mux_c4_result"
             (call "circuit_MultiMux1"
                [ var "mux_c4_dot_c_i0_i0"
                ; var "mux_c4_dot_c_i0_i1"
                ; var "mux_c4_dot_c_i1_i0"
                ; var "mux_c4_dot_c_i1_i1"
                ; var "mux_c4_dot_s" ] )
        @@ elet "mux_c4_dot_out_i0" (project (var "mux_c4_result") 1)
        @@ elet "mux_c4_dot_out_i1" (project (var "mux_c4_result") 0)
        @@ elet "poseidons_c4_dot_inputs_i0" (var "mux_c4_dot_out_i0")
        @@ elet "poseidons_c4_dot_inputs_i1" (var "mux_c4_dot_out_i1")
        @@ elet "poseidons_c4_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c4_dot_inputs_i0"
                ; var "poseidons_c4_dot_inputs_i1" ] )
        @@ elet "poseidons_c4_dot_out" (var "poseidons_c4_result")
        @@ elet "hashes_i5" (var "poseidons_c4_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i5" * F.(F.const 1 - var "pathIndices_i5"))
                (F.const 0) )
        @@ elet "mux_c5_dot_c_i0_i0" (var "hashes_i5")
        @@ elet "mux_c5_dot_c_i0_i1" (var "siblings_i5")
        @@ elet "mux_c5_dot_c_i1_i0" (var "siblings_i5")
        @@ elet "mux_c5_dot_c_i1_i1" (var "hashes_i5")
        @@ elet "mux_c5_dot_s" (var "pathIndices_i5")
        @@ elet "mux_c5_result"
             (call "circuit_MultiMux1"
                [ var "mux_c5_dot_c_i0_i0"
                ; var "mux_c5_dot_c_i0_i1"
                ; var "mux_c5_dot_c_i1_i0"
                ; var "mux_c5_dot_c_i1_i1"
                ; var "mux_c5_dot_s" ] )
        @@ elet "mux_c5_dot_out_i0" (project (var "mux_c5_result") 1)
        @@ elet "mux_c5_dot_out_i1" (project (var "mux_c5_result") 0)
        @@ elet "poseidons_c5_dot_inputs_i0" (var "mux_c5_dot_out_i0")
        @@ elet "poseidons_c5_dot_inputs_i1" (var "mux_c5_dot_out_i1")
        @@ elet "poseidons_c5_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c5_dot_inputs_i0"
                ; var "poseidons_c5_dot_inputs_i1" ] )
        @@ elet "poseidons_c5_dot_out" (var "poseidons_c5_result")
        @@ elet "hashes_i6" (var "poseidons_c5_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i6" * F.(F.const 1 - var "pathIndices_i6"))
                (F.const 0) )
        @@ elet "mux_c6_dot_c_i0_i0" (var "hashes_i6")
        @@ elet "mux_c6_dot_c_i0_i1" (var "siblings_i6")
        @@ elet "mux_c6_dot_c_i1_i0" (var "siblings_i6")
        @@ elet "mux_c6_dot_c_i1_i1" (var "hashes_i6")
        @@ elet "mux_c6_dot_s" (var "pathIndices_i6")
        @@ elet "mux_c6_result"
             (call "circuit_MultiMux1"
                [ var "mux_c6_dot_c_i0_i0"
                ; var "mux_c6_dot_c_i0_i1"
                ; var "mux_c6_dot_c_i1_i0"
                ; var "mux_c6_dot_c_i1_i1"
                ; var "mux_c6_dot_s" ] )
        @@ elet "mux_c6_dot_out_i0" (project (var "mux_c6_result") 1)
        @@ elet "mux_c6_dot_out_i1" (project (var "mux_c6_result") 0)
        @@ elet "poseidons_c6_dot_inputs_i0" (var "mux_c6_dot_out_i0")
        @@ elet "poseidons_c6_dot_inputs_i1" (var "mux_c6_dot_out_i1")
        @@ elet "poseidons_c6_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c6_dot_inputs_i0"
                ; var "poseidons_c6_dot_inputs_i1" ] )
        @@ elet "poseidons_c6_dot_out" (var "poseidons_c6_result")
        @@ elet "hashes_i7" (var "poseidons_c6_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i7" * F.(F.const 1 - var "pathIndices_i7"))
                (F.const 0) )
        @@ elet "mux_c7_dot_c_i0_i0" (var "hashes_i7")
        @@ elet "mux_c7_dot_c_i0_i1" (var "siblings_i7")
        @@ elet "mux_c7_dot_c_i1_i0" (var "siblings_i7")
        @@ elet "mux_c7_dot_c_i1_i1" (var "hashes_i7")
        @@ elet "mux_c7_dot_s" (var "pathIndices_i7")
        @@ elet "mux_c7_result"
             (call "circuit_MultiMux1"
                [ var "mux_c7_dot_c_i0_i0"
                ; var "mux_c7_dot_c_i0_i1"
                ; var "mux_c7_dot_c_i1_i0"
                ; var "mux_c7_dot_c_i1_i1"
                ; var "mux_c7_dot_s" ] )
        @@ elet "mux_c7_dot_out_i0" (project (var "mux_c7_result") 1)
        @@ elet "mux_c7_dot_out_i1" (project (var "mux_c7_result") 0)
        @@ elet "poseidons_c7_dot_inputs_i0" (var "mux_c7_dot_out_i0")
        @@ elet "poseidons_c7_dot_inputs_i1" (var "mux_c7_dot_out_i1")
        @@ elet "poseidons_c7_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c7_dot_inputs_i0"
                ; var "poseidons_c7_dot_inputs_i1" ] )
        @@ elet "poseidons_c7_dot_out" (var "poseidons_c7_result")
        @@ elet "hashes_i8" (var "poseidons_c7_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i8" * F.(F.const 1 - var "pathIndices_i8"))
                (F.const 0) )
        @@ elet "mux_c8_dot_c_i0_i0" (var "hashes_i8")
        @@ elet "mux_c8_dot_c_i0_i1" (var "siblings_i8")
        @@ elet "mux_c8_dot_c_i1_i0" (var "siblings_i8")
        @@ elet "mux_c8_dot_c_i1_i1" (var "hashes_i8")
        @@ elet "mux_c8_dot_s" (var "pathIndices_i8")
        @@ elet "mux_c8_result"
             (call "circuit_MultiMux1"
                [ var "mux_c8_dot_c_i0_i0"
                ; var "mux_c8_dot_c_i0_i1"
                ; var "mux_c8_dot_c_i1_i0"
                ; var "mux_c8_dot_c_i1_i1"
                ; var "mux_c8_dot_s" ] )
        @@ elet "mux_c8_dot_out_i0" (project (var "mux_c8_result") 1)
        @@ elet "mux_c8_dot_out_i1" (project (var "mux_c8_result") 0)
        @@ elet "poseidons_c8_dot_inputs_i0" (var "mux_c8_dot_out_i0")
        @@ elet "poseidons_c8_dot_inputs_i1" (var "mux_c8_dot_out_i1")
        @@ elet "poseidons_c8_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c8_dot_inputs_i0"
                ; var "poseidons_c8_dot_inputs_i1" ] )
        @@ elet "poseidons_c8_dot_out" (var "poseidons_c8_result")
        @@ elet "hashes_i9" (var "poseidons_c8_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i9" * F.(F.const 1 - var "pathIndices_i9"))
                (F.const 0) )
        @@ elet "mux_c9_dot_c_i0_i0" (var "hashes_i9")
        @@ elet "mux_c9_dot_c_i0_i1" (var "siblings_i9")
        @@ elet "mux_c9_dot_c_i1_i0" (var "siblings_i9")
        @@ elet "mux_c9_dot_c_i1_i1" (var "hashes_i9")
        @@ elet "mux_c9_dot_s" (var "pathIndices_i9")
        @@ elet "mux_c9_result"
             (call "circuit_MultiMux1"
                [ var "mux_c9_dot_c_i0_i0"
                ; var "mux_c9_dot_c_i0_i1"
                ; var "mux_c9_dot_c_i1_i0"
                ; var "mux_c9_dot_c_i1_i1"
                ; var "mux_c9_dot_s" ] )
        @@ elet "mux_c9_dot_out_i0" (project (var "mux_c9_result") 1)
        @@ elet "mux_c9_dot_out_i1" (project (var "mux_c9_result") 0)
        @@ elet "poseidons_c9_dot_inputs_i0" (var "mux_c9_dot_out_i0")
        @@ elet "poseidons_c9_dot_inputs_i1" (var "mux_c9_dot_out_i1")
        @@ elet "poseidons_c9_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c9_dot_inputs_i0"
                ; var "poseidons_c9_dot_inputs_i1" ] )
        @@ elet "poseidons_c9_dot_out" (var "poseidons_c9_result")
        @@ elet "hashes_i10" (var "poseidons_c9_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i10" * F.(F.const 1 - var "pathIndices_i10"))
                (F.const 0) )
        @@ elet "mux_c10_dot_c_i0_i0" (var "hashes_i10")
        @@ elet "mux_c10_dot_c_i0_i1" (var "siblings_i10")
        @@ elet "mux_c10_dot_c_i1_i0" (var "siblings_i10")
        @@ elet "mux_c10_dot_c_i1_i1" (var "hashes_i10")
        @@ elet "mux_c10_dot_s" (var "pathIndices_i10")
        @@ elet "mux_c10_result"
             (call "circuit_MultiMux1"
                [ var "mux_c10_dot_c_i0_i0"
                ; var "mux_c10_dot_c_i0_i1"
                ; var "mux_c10_dot_c_i1_i0"
                ; var "mux_c10_dot_c_i1_i1"
                ; var "mux_c10_dot_s" ] )
        @@ elet "mux_c10_dot_out_i0" (project (var "mux_c10_result") 1)
        @@ elet "mux_c10_dot_out_i1" (project (var "mux_c10_result") 0)
        @@ elet "poseidons_c10_dot_inputs_i0" (var "mux_c10_dot_out_i0")
        @@ elet "poseidons_c10_dot_inputs_i1" (var "mux_c10_dot_out_i1")
        @@ elet "poseidons_c10_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c10_dot_inputs_i0"
                ; var "poseidons_c10_dot_inputs_i1" ] )
        @@ elet "poseidons_c10_dot_out" (var "poseidons_c10_result")
        @@ elet "hashes_i11" (var "poseidons_c10_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i11" * F.(F.const 1 - var "pathIndices_i11"))
                (F.const 0) )
        @@ elet "mux_c11_dot_c_i0_i0" (var "hashes_i11")
        @@ elet "mux_c11_dot_c_i0_i1" (var "siblings_i11")
        @@ elet "mux_c11_dot_c_i1_i0" (var "siblings_i11")
        @@ elet "mux_c11_dot_c_i1_i1" (var "hashes_i11")
        @@ elet "mux_c11_dot_s" (var "pathIndices_i11")
        @@ elet "mux_c11_result"
             (call "circuit_MultiMux1"
                [ var "mux_c11_dot_c_i0_i0"
                ; var "mux_c11_dot_c_i0_i1"
                ; var "mux_c11_dot_c_i1_i0"
                ; var "mux_c11_dot_c_i1_i1"
                ; var "mux_c11_dot_s" ] )
        @@ elet "mux_c11_dot_out_i0" (project (var "mux_c11_result") 1)
        @@ elet "mux_c11_dot_out_i1" (project (var "mux_c11_result") 0)
        @@ elet "poseidons_c11_dot_inputs_i0" (var "mux_c11_dot_out_i0")
        @@ elet "poseidons_c11_dot_inputs_i1" (var "mux_c11_dot_out_i1")
        @@ elet "poseidons_c11_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c11_dot_inputs_i0"
                ; var "poseidons_c11_dot_inputs_i1" ] )
        @@ elet "poseidons_c11_dot_out" (var "poseidons_c11_result")
        @@ elet "hashes_i12" (var "poseidons_c11_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i12" * F.(F.const 1 - var "pathIndices_i12"))
                (F.const 0) )
        @@ elet "mux_c12_dot_c_i0_i0" (var "hashes_i12")
        @@ elet "mux_c12_dot_c_i0_i1" (var "siblings_i12")
        @@ elet "mux_c12_dot_c_i1_i0" (var "siblings_i12")
        @@ elet "mux_c12_dot_c_i1_i1" (var "hashes_i12")
        @@ elet "mux_c12_dot_s" (var "pathIndices_i12")
        @@ elet "mux_c12_result"
             (call "circuit_MultiMux1"
                [ var "mux_c12_dot_c_i0_i0"
                ; var "mux_c12_dot_c_i0_i1"
                ; var "mux_c12_dot_c_i1_i0"
                ; var "mux_c12_dot_c_i1_i1"
                ; var "mux_c12_dot_s" ] )
        @@ elet "mux_c12_dot_out_i0" (project (var "mux_c12_result") 1)
        @@ elet "mux_c12_dot_out_i1" (project (var "mux_c12_result") 0)
        @@ elet "poseidons_c12_dot_inputs_i0" (var "mux_c12_dot_out_i0")
        @@ elet "poseidons_c12_dot_inputs_i1" (var "mux_c12_dot_out_i1")
        @@ elet "poseidons_c12_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c12_dot_inputs_i0"
                ; var "poseidons_c12_dot_inputs_i1" ] )
        @@ elet "poseidons_c12_dot_out" (var "poseidons_c12_result")
        @@ elet "hashes_i13" (var "poseidons_c12_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i13" * F.(F.const 1 - var "pathIndices_i13"))
                (F.const 0) )
        @@ elet "mux_c13_dot_c_i0_i0" (var "hashes_i13")
        @@ elet "mux_c13_dot_c_i0_i1" (var "siblings_i13")
        @@ elet "mux_c13_dot_c_i1_i0" (var "siblings_i13")
        @@ elet "mux_c13_dot_c_i1_i1" (var "hashes_i13")
        @@ elet "mux_c13_dot_s" (var "pathIndices_i13")
        @@ elet "mux_c13_result"
             (call "circuit_MultiMux1"
                [ var "mux_c13_dot_c_i0_i0"
                ; var "mux_c13_dot_c_i0_i1"
                ; var "mux_c13_dot_c_i1_i0"
                ; var "mux_c13_dot_c_i1_i1"
                ; var "mux_c13_dot_s" ] )
        @@ elet "mux_c13_dot_out_i0" (project (var "mux_c13_result") 1)
        @@ elet "mux_c13_dot_out_i1" (project (var "mux_c13_result") 0)
        @@ elet "poseidons_c13_dot_inputs_i0" (var "mux_c13_dot_out_i0")
        @@ elet "poseidons_c13_dot_inputs_i1" (var "mux_c13_dot_out_i1")
        @@ elet "poseidons_c13_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c13_dot_inputs_i0"
                ; var "poseidons_c13_dot_inputs_i1" ] )
        @@ elet "poseidons_c13_dot_out" (var "poseidons_c13_result")
        @@ elet "hashes_i14" (var "poseidons_c13_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i14" * F.(F.const 1 - var "pathIndices_i14"))
                (F.const 0) )
        @@ elet "mux_c14_dot_c_i0_i0" (var "hashes_i14")
        @@ elet "mux_c14_dot_c_i0_i1" (var "siblings_i14")
        @@ elet "mux_c14_dot_c_i1_i0" (var "siblings_i14")
        @@ elet "mux_c14_dot_c_i1_i1" (var "hashes_i14")
        @@ elet "mux_c14_dot_s" (var "pathIndices_i14")
        @@ elet "mux_c14_result"
             (call "circuit_MultiMux1"
                [ var "mux_c14_dot_c_i0_i0"
                ; var "mux_c14_dot_c_i0_i1"
                ; var "mux_c14_dot_c_i1_i0"
                ; var "mux_c14_dot_c_i1_i1"
                ; var "mux_c14_dot_s" ] )
        @@ elet "mux_c14_dot_out_i0" (project (var "mux_c14_result") 1)
        @@ elet "mux_c14_dot_out_i1" (project (var "mux_c14_result") 0)
        @@ elet "poseidons_c14_dot_inputs_i0" (var "mux_c14_dot_out_i0")
        @@ elet "poseidons_c14_dot_inputs_i1" (var "mux_c14_dot_out_i1")
        @@ elet "poseidons_c14_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c14_dot_inputs_i0"
                ; var "poseidons_c14_dot_inputs_i1" ] )
        @@ elet "poseidons_c14_dot_out" (var "poseidons_c14_result")
        @@ elet "hashes_i15" (var "poseidons_c14_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i15" * F.(F.const 1 - var "pathIndices_i15"))
                (F.const 0) )
        @@ elet "mux_c15_dot_c_i0_i0" (var "hashes_i15")
        @@ elet "mux_c15_dot_c_i0_i1" (var "siblings_i15")
        @@ elet "mux_c15_dot_c_i1_i0" (var "siblings_i15")
        @@ elet "mux_c15_dot_c_i1_i1" (var "hashes_i15")
        @@ elet "mux_c15_dot_s" (var "pathIndices_i15")
        @@ elet "mux_c15_result"
             (call "circuit_MultiMux1"
                [ var "mux_c15_dot_c_i0_i0"
                ; var "mux_c15_dot_c_i0_i1"
                ; var "mux_c15_dot_c_i1_i0"
                ; var "mux_c15_dot_c_i1_i1"
                ; var "mux_c15_dot_s" ] )
        @@ elet "mux_c15_dot_out_i0" (project (var "mux_c15_result") 1)
        @@ elet "mux_c15_dot_out_i1" (project (var "mux_c15_result") 0)
        @@ elet "poseidons_c15_dot_inputs_i0" (var "mux_c15_dot_out_i0")
        @@ elet "poseidons_c15_dot_inputs_i1" (var "mux_c15_dot_out_i1")
        @@ elet "poseidons_c15_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c15_dot_inputs_i0"
                ; var "poseidons_c15_dot_inputs_i1" ] )
        @@ elet "poseidons_c15_dot_out" (var "poseidons_c15_result")
        @@ elet "hashes_i16" (var "poseidons_c15_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i16" * F.(F.const 1 - var "pathIndices_i16"))
                (F.const 0) )
        @@ elet "mux_c16_dot_c_i0_i0" (var "hashes_i16")
        @@ elet "mux_c16_dot_c_i0_i1" (var "siblings_i16")
        @@ elet "mux_c16_dot_c_i1_i0" (var "siblings_i16")
        @@ elet "mux_c16_dot_c_i1_i1" (var "hashes_i16")
        @@ elet "mux_c16_dot_s" (var "pathIndices_i16")
        @@ elet "mux_c16_result"
             (call "circuit_MultiMux1"
                [ var "mux_c16_dot_c_i0_i0"
                ; var "mux_c16_dot_c_i0_i1"
                ; var "mux_c16_dot_c_i1_i0"
                ; var "mux_c16_dot_c_i1_i1"
                ; var "mux_c16_dot_s" ] )
        @@ elet "mux_c16_dot_out_i0" (project (var "mux_c16_result") 1)
        @@ elet "mux_c16_dot_out_i1" (project (var "mux_c16_result") 0)
        @@ elet "poseidons_c16_dot_inputs_i0" (var "mux_c16_dot_out_i0")
        @@ elet "poseidons_c16_dot_inputs_i1" (var "mux_c16_dot_out_i1")
        @@ elet "poseidons_c16_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c16_dot_inputs_i0"
                ; var "poseidons_c16_dot_inputs_i1" ] )
        @@ elet "poseidons_c16_dot_out" (var "poseidons_c16_result")
        @@ elet "hashes_i17" (var "poseidons_c16_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i17" * F.(F.const 1 - var "pathIndices_i17"))
                (F.const 0) )
        @@ elet "mux_c17_dot_c_i0_i0" (var "hashes_i17")
        @@ elet "mux_c17_dot_c_i0_i1" (var "siblings_i17")
        @@ elet "mux_c17_dot_c_i1_i0" (var "siblings_i17")
        @@ elet "mux_c17_dot_c_i1_i1" (var "hashes_i17")
        @@ elet "mux_c17_dot_s" (var "pathIndices_i17")
        @@ elet "mux_c17_result"
             (call "circuit_MultiMux1"
                [ var "mux_c17_dot_c_i0_i0"
                ; var "mux_c17_dot_c_i0_i1"
                ; var "mux_c17_dot_c_i1_i0"
                ; var "mux_c17_dot_c_i1_i1"
                ; var "mux_c17_dot_s" ] )
        @@ elet "mux_c17_dot_out_i0" (project (var "mux_c17_result") 1)
        @@ elet "mux_c17_dot_out_i1" (project (var "mux_c17_result") 0)
        @@ elet "poseidons_c17_dot_inputs_i0" (var "mux_c17_dot_out_i0")
        @@ elet "poseidons_c17_dot_inputs_i1" (var "mux_c17_dot_out_i1")
        @@ elet "poseidons_c17_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c17_dot_inputs_i0"
                ; var "poseidons_c17_dot_inputs_i1" ] )
        @@ elet "poseidons_c17_dot_out" (var "poseidons_c17_result")
        @@ elet "hashes_i18" (var "poseidons_c17_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i18" * F.(F.const 1 - var "pathIndices_i18"))
                (F.const 0) )
        @@ elet "mux_c18_dot_c_i0_i0" (var "hashes_i18")
        @@ elet "mux_c18_dot_c_i0_i1" (var "siblings_i18")
        @@ elet "mux_c18_dot_c_i1_i0" (var "siblings_i18")
        @@ elet "mux_c18_dot_c_i1_i1" (var "hashes_i18")
        @@ elet "mux_c18_dot_s" (var "pathIndices_i18")
        @@ elet "mux_c18_result"
             (call "circuit_MultiMux1"
                [ var "mux_c18_dot_c_i0_i0"
                ; var "mux_c18_dot_c_i0_i1"
                ; var "mux_c18_dot_c_i1_i0"
                ; var "mux_c18_dot_c_i1_i1"
                ; var "mux_c18_dot_s" ] )
        @@ elet "mux_c18_dot_out_i0" (project (var "mux_c18_result") 1)
        @@ elet "mux_c18_dot_out_i1" (project (var "mux_c18_result") 0)
        @@ elet "poseidons_c18_dot_inputs_i0" (var "mux_c18_dot_out_i0")
        @@ elet "poseidons_c18_dot_inputs_i1" (var "mux_c18_dot_out_i1")
        @@ elet "poseidons_c18_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c18_dot_inputs_i0"
                ; var "poseidons_c18_dot_inputs_i1" ] )
        @@ elet "poseidons_c18_dot_out" (var "poseidons_c18_result")
        @@ elet "hashes_i19" (var "poseidons_c18_dot_out")
        @@ elet "fresh_0"
             (assert_eq
                F.(var "pathIndices_i19" * F.(F.const 1 - var "pathIndices_i19"))
                (F.const 0) )
        @@ elet "mux_c19_dot_c_i0_i0" (var "hashes_i19")
        @@ elet "mux_c19_dot_c_i0_i1" (var "siblings_i19")
        @@ elet "mux_c19_dot_c_i1_i0" (var "siblings_i19")
        @@ elet "mux_c19_dot_c_i1_i1" (var "hashes_i19")
        @@ elet "mux_c19_dot_s" (var "pathIndices_i19")
        @@ elet "mux_c19_result"
             (call "circuit_MultiMux1"
                [ var "mux_c19_dot_c_i0_i0"
                ; var "mux_c19_dot_c_i0_i1"
                ; var "mux_c19_dot_c_i1_i0"
                ; var "mux_c19_dot_c_i1_i1"
                ; var "mux_c19_dot_s" ] )
        @@ elet "mux_c19_dot_out_i0" (project (var "mux_c19_result") 1)
        @@ elet "mux_c19_dot_out_i1" (project (var "mux_c19_result") 0)
        @@ elet "poseidons_c19_dot_inputs_i0" (var "mux_c19_dot_out_i0")
        @@ elet "poseidons_c19_dot_inputs_i1" (var "mux_c19_dot_out_i1")
        @@ elet "poseidons_c19_result"
             (call "circuit_Poseidon"
                [ var "poseidons_c19_dot_inputs_i0"
                ; var "poseidons_c19_dot_inputs_i1" ] )
        @@ elet "poseidons_c19_dot_out" (var "poseidons_c19_result")
        @@ elet "hashes_i20" (var "poseidons_c19_dot_out")
        @@ elet "root" (var "hashes_i20")
        @@ var "root" }

let circuit_Semaphore =
  Circuit
    { name= "circuit_Semaphore"
    ; inputs=
        [ ("signalHash", field)
        ; ("externalNullifier", field)
        ; ("identityNullifier", field)
        ; ("identityTrapdoor", field)
        ; ("treePathIndices_i0", field)
        ; ("treePathIndices_i1", field)
        ; ("treePathIndices_i2", field)
        ; ("treePathIndices_i3", field)
        ; ("treePathIndices_i4", field)
        ; ("treePathIndices_i5", field)
        ; ("treePathIndices_i6", field)
        ; ("treePathIndices_i7", field)
        ; ("treePathIndices_i8", field)
        ; ("treePathIndices_i9", field)
        ; ("treePathIndices_i10", field)
        ; ("treePathIndices_i11", field)
        ; ("treePathIndices_i12", field)
        ; ("treePathIndices_i13", field)
        ; ("treePathIndices_i14", field)
        ; ("treePathIndices_i15", field)
        ; ("treePathIndices_i16", field)
        ; ("treePathIndices_i17", field)
        ; ("treePathIndices_i18", field)
        ; ("treePathIndices_i19", field)
        ; ("treeSiblings_i0", field)
        ; ("treeSiblings_i1", field)
        ; ("treeSiblings_i2", field)
        ; ("treeSiblings_i3", field)
        ; ("treeSiblings_i4", field)
        ; ("treeSiblings_i5", field)
        ; ("treeSiblings_i6", field)
        ; ("treeSiblings_i7", field)
        ; ("treeSiblings_i8", field)
        ; ("treeSiblings_i9", field)
        ; ("treeSiblings_i10", field)
        ; ("treeSiblings_i11", field)
        ; ("treeSiblings_i12", field)
        ; ("treeSiblings_i13", field)
        ; ("treeSiblings_i14", field)
        ; ("treeSiblings_i15", field)
        ; ("treeSiblings_i16", field)
        ; ("treeSiblings_i17", field)
        ; ("treeSiblings_i18", field)
        ; ("treeSiblings_i19", field) ]
    ; outputs= semaphore_outputs
    ; dep= None
    ; body=
        elet "calculateSecret_dot_identityNullifier" (var "identityNullifier")
        @@ elet "calculateSecret_dot_identityTrapdoor" (var "identityTrapdoor")
        @@ elet "calculateSecret_result"
             (call "circuit_CalculateSecret"
                [ var "calculateSecret_dot_identityNullifier"
                ; var "calculateSecret_dot_identityTrapdoor" ] )
        @@ elet "calculateSecret_dot_out" (var "calculateSecret_result")
        @@ elet "secret" (var "calculateSecret_dot_out")
        @@ elet "calculateIdentityCommitment_dot_secret" (var "secret")
        @@ elet "calculateIdentityCommitment_result"
             (call "circuit_CalculateIdentityCommitment"
                [var "calculateIdentityCommitment_dot_secret"] )
        @@ elet "calculateIdentityCommitment_dot_out"
             (var "calculateIdentityCommitment_result")
        @@ elet "calculateNullifierHash_dot_externalNullifier"
             (var "externalNullifier")
        @@ elet "calculateNullifierHash_dot_identityNullifier"
             (var "identityNullifier")
        @@ elet "calculateNullifierHash_result"
             (call "circuit_CalculateNullifierHash"
                [ var "calculateNullifierHash_dot_externalNullifier"
                ; var "calculateNullifierHash_dot_identityNullifier" ] )
        @@ elet "calculateNullifierHash_dot_out"
             (var "calculateNullifierHash_result")
        @@ elet "inclusionProof_dot_leaf"
             (var "calculateIdentityCommitment_dot_out")
        @@ elet "inclusionProof_dot_siblings_i0" (var "treeSiblings_i0")
        @@ elet "inclusionProof_dot_pathIndices_i0" (var "treePathIndices_i0")
        @@ elet "inclusionProof_dot_siblings_i1" (var "treeSiblings_i1")
        @@ elet "inclusionProof_dot_pathIndices_i1" (var "treePathIndices_i1")
        @@ elet "inclusionProof_dot_siblings_i2" (var "treeSiblings_i2")
        @@ elet "inclusionProof_dot_pathIndices_i2" (var "treePathIndices_i2")
        @@ elet "inclusionProof_dot_siblings_i3" (var "treeSiblings_i3")
        @@ elet "inclusionProof_dot_pathIndices_i3" (var "treePathIndices_i3")
        @@ elet "inclusionProof_dot_siblings_i4" (var "treeSiblings_i4")
        @@ elet "inclusionProof_dot_pathIndices_i4" (var "treePathIndices_i4")
        @@ elet "inclusionProof_dot_siblings_i5" (var "treeSiblings_i5")
        @@ elet "inclusionProof_dot_pathIndices_i5" (var "treePathIndices_i5")
        @@ elet "inclusionProof_dot_siblings_i6" (var "treeSiblings_i6")
        @@ elet "inclusionProof_dot_pathIndices_i6" (var "treePathIndices_i6")
        @@ elet "inclusionProof_dot_siblings_i7" (var "treeSiblings_i7")
        @@ elet "inclusionProof_dot_pathIndices_i7" (var "treePathIndices_i7")
        @@ elet "inclusionProof_dot_siblings_i8" (var "treeSiblings_i8")
        @@ elet "inclusionProof_dot_pathIndices_i8" (var "treePathIndices_i8")
        @@ elet "inclusionProof_dot_siblings_i9" (var "treeSiblings_i9")
        @@ elet "inclusionProof_dot_pathIndices_i9" (var "treePathIndices_i9")
        @@ elet "inclusionProof_dot_siblings_i10" (var "treeSiblings_i10")
        @@ elet "inclusionProof_dot_pathIndices_i10" (var "treePathIndices_i10")
        @@ elet "inclusionProof_dot_siblings_i11" (var "treeSiblings_i11")
        @@ elet "inclusionProof_dot_pathIndices_i11" (var "treePathIndices_i11")
        @@ elet "inclusionProof_dot_siblings_i12" (var "treeSiblings_i12")
        @@ elet "inclusionProof_dot_pathIndices_i12" (var "treePathIndices_i12")
        @@ elet "inclusionProof_dot_siblings_i13" (var "treeSiblings_i13")
        @@ elet "inclusionProof_dot_pathIndices_i13" (var "treePathIndices_i13")
        @@ elet "inclusionProof_dot_siblings_i14" (var "treeSiblings_i14")
        @@ elet "inclusionProof_dot_pathIndices_i14" (var "treePathIndices_i14")
        @@ elet "inclusionProof_dot_siblings_i15" (var "treeSiblings_i15")
        @@ elet "inclusionProof_dot_pathIndices_i15" (var "treePathIndices_i15")
        @@ elet "inclusionProof_dot_siblings_i16" (var "treeSiblings_i16")
        @@ elet "inclusionProof_dot_pathIndices_i16" (var "treePathIndices_i16")
        @@ elet "inclusionProof_dot_siblings_i17" (var "treeSiblings_i17")
        @@ elet "inclusionProof_dot_pathIndices_i17" (var "treePathIndices_i17")
        @@ elet "inclusionProof_dot_siblings_i18" (var "treeSiblings_i18")
        @@ elet "inclusionProof_dot_pathIndices_i18" (var "treePathIndices_i18")
        @@ elet "inclusionProof_dot_siblings_i19" (var "treeSiblings_i19")
        @@ elet "inclusionProof_dot_pathIndices_i19" (var "treePathIndices_i19")
        @@ elet "inclusionProof_result"
             (call "circuit_MerkleTreeInclusionProof"
                [ var "inclusionProof_dot_leaf"
                ; var "inclusionProof_dot_pathIndices_i0"
                ; var "inclusionProof_dot_pathIndices_i1"
                ; var "inclusionProof_dot_pathIndices_i2"
                ; var "inclusionProof_dot_pathIndices_i3"
                ; var "inclusionProof_dot_pathIndices_i4"
                ; var "inclusionProof_dot_pathIndices_i5"
                ; var "inclusionProof_dot_pathIndices_i6"
                ; var "inclusionProof_dot_pathIndices_i7"
                ; var "inclusionProof_dot_pathIndices_i8"
                ; var "inclusionProof_dot_pathIndices_i9"
                ; var "inclusionProof_dot_pathIndices_i10"
                ; var "inclusionProof_dot_pathIndices_i11"
                ; var "inclusionProof_dot_pathIndices_i12"
                ; var "inclusionProof_dot_pathIndices_i13"
                ; var "inclusionProof_dot_pathIndices_i14"
                ; var "inclusionProof_dot_pathIndices_i15"
                ; var "inclusionProof_dot_pathIndices_i16"
                ; var "inclusionProof_dot_pathIndices_i17"
                ; var "inclusionProof_dot_pathIndices_i18"
                ; var "inclusionProof_dot_pathIndices_i19"
                ; var "inclusionProof_dot_siblings_i0"
                ; var "inclusionProof_dot_siblings_i1"
                ; var "inclusionProof_dot_siblings_i2"
                ; var "inclusionProof_dot_siblings_i3"
                ; var "inclusionProof_dot_siblings_i4"
                ; var "inclusionProof_dot_siblings_i5"
                ; var "inclusionProof_dot_siblings_i6"
                ; var "inclusionProof_dot_siblings_i7"
                ; var "inclusionProof_dot_siblings_i8"
                ; var "inclusionProof_dot_siblings_i9"
                ; var "inclusionProof_dot_siblings_i10"
                ; var "inclusionProof_dot_siblings_i11"
                ; var "inclusionProof_dot_siblings_i12"
                ; var "inclusionProof_dot_siblings_i13"
                ; var "inclusionProof_dot_siblings_i14"
                ; var "inclusionProof_dot_siblings_i15"
                ; var "inclusionProof_dot_siblings_i16"
                ; var "inclusionProof_dot_siblings_i17"
                ; var "inclusionProof_dot_siblings_i18"
                ; var "inclusionProof_dot_siblings_i19" ] )
        @@ elet "inclusionProof_dot_root" (var "inclusionProof_result")
        @@ elet "root" (var "inclusionProof_dot_root")
        @@ elet "signalHashSquared" F.(var "signalHash" * var "signalHash")
        @@ elet "nullifierHash" (var "calculateNullifierHash_dot_out")
        @@ Expr.tuple [var "root"; var "nullifierHash"] }
