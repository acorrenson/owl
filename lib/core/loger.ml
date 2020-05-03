open Terms
open Printf

let rec str_of_term t =
  match t with
  | Var x -> sprintf "?%s" x
  | FFun (f, []) -> f
  | FFun (f, args) -> sprintf "%s(%s)" f (str_of_terms args)
and str_of_terms lt =
  match lt with
  | [] -> ""
  | x::[] -> str_of_term x
  | x::xs -> sprintf "%s, %s" (str_of_term x) (str_of_terms xs)

let rec str_of_qry q =
  match q with
  | Simple t -> str_of_term t
  | Conj (p, q) -> sprintf "(%s & %s)" (str_of_qry p) (str_of_qry q)
  | Disj (p, q) -> sprintf "(%s | %s)" (str_of_qry p) (str_of_qry q)


let str_of_subst (x, t) =
  Printf.sprintf "?%s <- %s" x (str_of_term t)

let str_of_substl l =
  List.fold_left (fun a t -> a ^ (str_of_subst t) ^ " ") " " l

let str_of_substll ll =
  List.fold_left (fun a t -> a ^ (str_of_substl t) ^ " ") " " ll
