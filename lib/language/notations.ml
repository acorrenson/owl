open Terms

let nat_to_term n =
  let rec step i acc =
    if i = 0 then acc
    else step (i-1) (ffun "s" [acc])
  in
  step n (ffun "z" [])

let pretty_notations t =
  let rec step tt acc =
    match tt with
    | FFun ("z", []) -> FFun (string_of_int acc, [])
    | FFun ("s", [x]) -> step x (acc+1)
    | FFun (f, args) -> FFun (f, List.map (fun t -> step t 0) args)
    | _ -> tt
  in
  step t 0

