open Terms

let rec str_of_term t =
  match t with
  | Var x -> "?" ^ x
  | FFun (f, []) -> f
  | FFun (f, args) -> f ^ "(" ^ (str_of_terms args) ^ ")"
and str_of_terms lt =
  match lt with
  | [] -> ""
  | x::[] -> str_of_term x
  | x::tail -> str_of_term x ^ ", " ^ (str_of_terms tail)

let str_of_rule r =
  match r with
  | Rule (n, _, _)
  | Know (n, _) -> string_of_int !n
let str_of_rules lr =
  List.fold_left (fun a t -> a ^ (str_of_rule t) ^ " ") " " lr

let str_of_subst (x, t) =
  Printf.sprintf "?%s <- %s" x (str_of_term t)

let str_of_substl l =
  List.fold_left (fun a t -> a ^ (str_of_subst t) ^ " ") " " l

let str_of_substll ll =
  List.fold_left (fun a t -> a ^ (str_of_substl t) ^ " ") " " ll
