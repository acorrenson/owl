open Owl_core.Core

let data1 = Know (Fun ("loves", [Fun ("A", []); Fun ("B", [])]))

let data4 = Rule (Fun ("loves", [Var "x"; Var "y"]), [Fun ("loves", [Var "y"; Var "x"])])

let db = [data1; data4]

let qry = Fun ("loves", [Var "a"; Var "b"])