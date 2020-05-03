open Terms
open Unification

let rec merge_sols s1 s2 =
  match s1 with
  | [] -> s2
  | x::xs ->
    if List.exists ((subst_eq) x) s2
    then merge_sols xs s2
    else x::(merge_sols xs s2)

let (<@>) = merge_sols

let solve (qry:query) db =
  let count = ref 0 in
  let open List in
  let rec qeval frames tqry =
    map (find_rules tqry) frames
    |> flatten

  and find_rules tqry frame =
    map (check_rule tqry frame) db
    |> flatten

  and check_rule tqry frame rule =
    match rule with
    | Fact t ->
      incr count;
      (match unify [apply_subst frame tqry, rename_term !count t] with
       | None -> []
       | Some u -> [compose frame u])
    | Rule (t, qry) ->
      incr count;
      (match unify [apply_subst frame tqry, rename_term !count t] with
       | None -> []
       | Some u ->
         let conds = map_qry (fun x -> rename_term !count x |> apply_subst u) qry in
         qeval_qry [compose frame u] conds)

  and qeval_qry frames qry =
    match qry with
    | Simple t -> qeval frames t
    | Conj (p, q) -> qeval_conjoin frames p q
    | Disj (p, q) -> qeval_disjoin frames p q

  and qeval_conjoin frames p q =
    qeval_qry (qeval_qry frames p) q

  and qeval_disjoin frames p q =
    let sols_p = qeval_qry frames p in
    let sols_q = qeval_qry frames q in
    let sols_pq = qeval_qry sols_q p in
    let sols_qp = qeval_qry sols_p q in
    sols_pq <@> sols_qp

  in

  qeval_qry [[]] qry

