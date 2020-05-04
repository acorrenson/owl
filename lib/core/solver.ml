open Terms
open Unification

let solve (qry:query) (db:rule Streams.stream) =
  let count = ref 0 in
  let open List in

  let rec qeval frames tqry =
    Streams.flat_map (find_rules tqry) frames

  and find_rules tqry frame =
    Streams.flat_map (check_rule tqry frame) db

  and check_rule tqry frame rule =
    match rule with
    | Fact t ->
      incr count;
      (match unify [apply_subst frame tqry, rename_term !count t] with
       | None -> Streams.empty
       | Some u -> compose frame u |> Streams.return)
    | Rule (t, qry) ->
      incr count;
      (match unify [apply_subst frame tqry, rename_term !count t] with
       | None -> Streams.empty
       | Some u ->
         let conds = map_qry (fun x -> rename_term !count x |> apply_subst u) qry in
         qeval_qry (compose frame u |> Streams.return) conds)

  and qeval_qry frames qry =
    match qry with
    | Simple t -> qeval frames t
    | Conj (p, q) -> qeval_conjoin frames p q
    | Disj (p, q) -> qeval_disjoin frames p q

  and qeval_conjoin frames p q =
    qeval_qry (qeval_qry frames p) q

  and qeval_disjoin frames p q =
    Streams.interleave (qeval_qry frames p) (qeval_qry frames q)

  in

  qeval_qry Streams.(return []) qry

