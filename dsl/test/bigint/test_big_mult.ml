open Core
open Typecheck
open Coqgen
open Bigint
open Big_mult
module U = Test_utils.Utils

(* let _ = U.test mod_sum_three [Circomlib.Bitify.num2bits] *)

(* let _ = U.test big_add [mod_sum_three] *)
let _ = U.test mod_prod Circomlib.Bitify.[num2bits; bits2num]
