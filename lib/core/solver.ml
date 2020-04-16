open Unification

type rule =
  | Rule of (int ref) * term * term list
  | Know of (int ref) * term
[@@deriving variants, show]

type rules = rule list [@@deriving show]

let rename i t =
  let rec step t =
    match t with
    | Var x -> Var (Printf.sprintf "%s_%d" x i)
    | FFun (f, args) -> FFun (f, List.map step args)
  in 
  step t

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


let solve qry db =
  let rec step qry rules =
    match rules with
    | [] -> None
    | Rule (n, t1, [t2])::tail ->
      let t1' = rename !n t1 in
      let t2' = rename !n t2 in
      begin
        match unify [qry, t1'] with
        | None -> step qry tail
        | Some u ->
          incr n;
          match step (apply_subst u t2') db with
          | Some u1 -> Some (compose u u1)
          | None -> None
      end
    | Know (n, t)::tail ->
      let t' = rename !n t in
      incr n;
      begin
        match unify [qry, t'] with
        | None -> step qry tail
        | u -> u
      end
    | _ -> assert false
  in
  step qry db


let solve_all qry db =
  let open List in

  let rec qeval frames qry =
    map (find_rules qry) frames
    |> flatten

  and find_rules qry frame =
    map (check_rule qry frame) db
    |> flatten

  and check_rule qry frame rule =
    match rule with
    | Know (n, t) ->
      incr n;
      (match unify [apply_subst frame qry, rename !n t] with
       | None -> []
       | Some u -> [compose frame u])
    | Rule (n, t, lt) ->
      incr n;
      (match unify [apply_subst frame qry, rename !n t] with
       | None -> []
       | Some u ->
         let conj = map (rename !n) lt |> map (apply_subst u) in
         qeval_conjoin [compose u frame] conj)

  and qeval_conjoin frames qrys =
    match qrys with
    | [] -> frames
    | q::ql -> qeval_conjoin (qeval frames q) ql
  in

  qeval [[]] qry

