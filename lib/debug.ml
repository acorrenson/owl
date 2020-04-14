open Owl_core.Core

let data1 = Know (1, Fun ("loves", [Fun ("A", []); Fun ("B", [])]))
let data2 = Know (2, Fun ("loves", [Fun ("B", []); Fun ("C", [])]))

(* let data2 = Know (Fun ("loves", [Fun ("A", []); Fun ("C", [])])) *)

let data4 = Rule (3, Fun ("loves", [Var "x"; Var "y"]), [Fun ("loves", [Var "y"; Var "x"])])

let data5 = Rule (4, Fun ("loves", [Var "p"; Var "q"]), [
    Fun ("loves", [Var "p"; Var "r"]);
    Fun ("loves", [Var "r"; Var "q"])
  ])

let db = [data1; data2; data4; data5]

let qry = Fun ("loves", [Var "a"; Var "b"])