type term =
  | Var of string
  | FFun of string * term list
[@@deriving variants, show]

type rule =
  | Rule of (int ref) * term * term list
  | Know of (int ref) * term
[@@deriving variants, show]