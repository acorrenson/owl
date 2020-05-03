type term =
  | Var of string
  | FFun of string * term list
[@@deriving variants, show]

type query =
  | Simple of term
  | Conj of query * query
  | Disj of query * query
[@@deriving variants, show]

type rule =
  | Rule of term * query
  | Fact of term
[@@deriving variants, show]

let rename_term i t =
  let rec step t =
    match t with
    | Var x -> Var (Printf.sprintf "%s_%d" x i)
    | FFun (f, args) -> FFun (f, List.map step args)
  in
  step t

let rec map_qry f q =
  match q with
  | Simple t -> simple (f t)
  | Conj (q1, q2) -> conj (map_qry f q1) (map_qry f q2)
  | Disj (q1, q2) -> disj (map_qry f q1) (map_qry f q2)


let rec no_vars_term t =
  match t with
  | Var _ -> false
  | FFun (_, args) -> List.for_all no_vars_term args

let rec no_vars_qry q =
  match q with
  | Simple t -> no_vars_term t
  | Conj (q1, q2) | Disj (q1, q2) -> no_vars_qry q1 && no_vars_qry q2



