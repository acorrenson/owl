
type term =
  | Var of string
  | Fun of string * term list

let (let*) = Option.bind

let rec subst (x, y) t =
  match t with
  | Fun (f, args) ->
    Fun (f, List.map (subst (x, y)) args)
  | Var v -> if v = x then y else Var v

let apply s t =
  List.fold_right subst s t

let apply_all s ltt = List.map (fun (x, y) -> apply s x, apply s y) ltt

let rec unify_one t1 t2 =
  match t1, t2 with
  | Var x, Var y -> Some [y, Var x]
  | Var x, Fun (f, args)
  | Fun (f, args), Var x ->
    if List.exists ((=) (Var x)) args then None
    else Some [x, Fun (f, args)]
  | Fun (f, args1), Fun (g, args2) ->
    if f = g && (List.length args1 = List.length args2) 
    then unify (List.combine args1 args2)
    else None
and unify l =
  match l with
  | [] -> Some []
  | (a, b)::tail ->
    let* m1 = unify_one a b in
    let* m2 = unify (apply_all m1 tail) in
    Some (m2 @ m1)

let rec query qry db =
  match db with
  | [] -> []
  | r::tail ->
    match unify_one qry r with
    | None -> query qry tail
    | Some s ->
      [s] @ (query qry tail)

type rule =
  | Rule of term * term list
  | Know of term

let rec solve_one qry rules =
  let rec step qry prev nexts =
    match nexts with
    | [] -> []
    | (Rule (t, tl) as r)::tail ->
      begin
        match unify_one qry t with
        | None -> step qry (r::prev) tail
        | Some s -> solve (List.map (apply s) tl) (prev @ tail)
      end
    | (Know t as r)::tail ->
      begin
        match unify_one qry t with
        | None -> step qry (r::prev) tail
        | Some s -> [s] @ (step qry (r::prev) tail)
      end
  in
  step qry [] rules

and solve qryl rules : (string * term) list list =
  match qryl with
  | [] -> []
  | q::ql ->
    match solve_one q rules with
    | [] -> []
    | sols ->
      List.map (fun s -> [s] @ (solve (List.map (apply s) ql) rules)) sols
      |> List.concat








