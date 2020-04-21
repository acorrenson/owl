open Terms
open Unification

let rename i t =
  let rec step t =
    match t with
    | Var x -> Var (Printf.sprintf "%s_%d" x i)
    | FFun (f, args) -> FFun (f, List.map step args)
  in 
  step t

let rec var_less t =
  match t with
  | Var _ -> false
  | FFun (_, args) -> List.for_all var_less args

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
         let conj = map (fun x -> rename !n x |> apply_subst u) lt in
         qeval_conjoin [compose frame u] conj)

  and qeval_conjoin frames qrys =
    match qrys with
    | [] -> frames
    | q::ql -> qeval_conjoin (qeval frames q) ql
  in

  qeval [[]] qry

