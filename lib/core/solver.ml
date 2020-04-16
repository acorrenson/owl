open Unification

let rec query qry db =
  match db with
  | [] -> []
  | r::tail ->
    match unify [qry, r] with
    | None -> query qry tail
    | Some s ->
      [s] @ (query qry tail)

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


(* let rec solve_one qry rules =
   let open List in
   match rules with
   | [] -> []
   | (Rule (n, t, tl) as r)::tail ->
    if !n >= 500 then [] else
      begin
        match unify [qry, (rename !n t)] with
        | None -> solve_one qry (tail @ [r])
        | Some s ->
          incr n;
          let sl1 = solve (map (apply_subst s) (map (rename !n) tl)) (tail @ [r]) in
          let sl2 = solve_one qry (tail @ [r]) in
          (List.map (fun x -> x @ s) sl1) @ sl2
      end
   | (Know (n, t) as r)::tail ->
    if !n >= 500 then [] else
      begin
        match unify [qry, (rename !n t)] with
        | None -> solve_one qry (tail @ [r])
        | Some s ->
          incr n;
          s::(solve_one qry (tail @ [r]))
      end

   and solve qryl rules =
   match qryl with
   | [] ->
    [[]]
   | q::ql ->
    let open List in
    let sols = solve_one q rules in
    map (fun s -> map (fun l -> l @ s) (solve (map (apply_subst s) ql) rules)) sols
    |> List.concat *)

let solve qry db =
  let rec step qry rules =
    match rules with
    | [] -> None
    | Rule (n, t1, [t2])::tail ->
      let t1' = rename !n t1 in
      let t2' = rename !n t2 in
      begin
        match unify [qry, t1'] with
        | Some u ->
          incr n;
          begin
            match step (apply_subst u t2') db with
            | Some u1 -> Some (compose u u1)
            | None -> None
          end
        | None -> step qry tail
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
