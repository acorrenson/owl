open Owl_core.Core

let data1 = Know (ref 0, Fun ("loves", [Fun ("A", []); Fun ("B", [])]))
let data2 = Know (ref 0, Fun ("loves", [Fun ("B", []); Fun ("C", [])]))

(* let data2 = Know (Fun ("loves", [Fun ("A", []); Fun ("C", [])])) *)

let data4 = Rule (ref 0, Fun ("loves", [Var "x"; Var "y"]), [Fun ("loves", [Var "y"; Var "x"])])

let data5 = Rule (ref 0, Fun ("loves", [Var "p"; Var "q"]), [
    Fun ("loves", [Var "p"; Var "r"]);
    Fun ("loves", [Var "r"; Var "q"])
  ])

let db = [data1; data2; data5; data4]

let qry = Fun ("loves", [Var "a"; Var "b"])
(* let qry = Fun ("loves", [Fun ("A", []); Fun ("C", [])]) *)