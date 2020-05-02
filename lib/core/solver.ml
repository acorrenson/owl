open Terms
open Unification

let solve qry db =
  let open List in

  let rec qeval frames qry =
    map (find_rules qry) frames
    |> flatten

  and find_rules qry frame =
    map (check_rule qry frame) db
    |> flatten

  and check_rule qry frame rule =
    match rule with
    | Fact (n, t) ->
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

