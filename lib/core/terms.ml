type term =
  | Var of string
  | FFun of string * term list
[@@deriving variants, show]

type rule =
  | Rule of (int ref) * term * term list
  | Fact of (int ref) * term
[@@deriving variants, show]

let rename i t =
  let rec step t =
    match t with
    | Var x -> Var (Printf.sprintf "%s_%d" x i)
    | FFun (f, args) -> FFun (f, List.map step args)
  in
  step t

let rec no_vars t =
  match t with
  | Var _ -> false
  | FFun (_, args) -> List.for_all no_vars args