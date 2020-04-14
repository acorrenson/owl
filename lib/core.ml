
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
  | Rule of (int ref) * term * term list
  | Know of (int ref) * term

let count = ref 0

let rename i t =
  let rec step t =
    match t with
    | Var x -> Var (Printf.sprintf "%s_%d" x i)
    | Fun (f, args) -> Fun (f, List.map step args)
  in 
  step t

let rec str_of_term t =
  match t with
  | Var x -> "?" ^ x
  | Fun (f, args) -> f ^ "(" ^ (str_of_terms args) ^ ")"
and str_of_terms lt =
  List.fold_left (fun a t -> a ^ (str_of_term t) ^ " ") " " lt

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


let rec solve_one qry rules =
  let open List in
  let rec step qry prev nexts =
    match nexts with
    | [] -> []
    | (Rule (n, t, tl) as r)::tail ->
      incr n;
      if !n >= 5 then []
      else begin
        match unify_one qry (rename !n t) with
        | None -> step qry (r::prev) tail
        | Some s -> 
          let sl1 = solve (map (apply s) (map (rename !n) tl)) ((rev prev) @ tail) in
          let sl2 = step qry (r::prev) tail in
          (List.map ((@) s) sl1) @ sl2
      end
    | (Know (n, t) as r)::tail ->
      incr n;
      if !n >= 50 then []
      else begin
        match unify_one qry (rename !n t) with
        | None -> step qry (r::prev) tail
        | Some s ->
          s::(step qry (r::prev) tail)
      end
  in
  step qry [] rules

and solve qryl rules =
  match qryl with
  | [] ->
    [[]]
  | q::ql ->
    let open List in
    let sols = solve_one q rules in
    map (fun s -> map (fun l -> l @ s) (solve (map (apply s) ql) rules)) sols
    |> List.concat


let print_sols qry sols =
  List.iter (fun t -> print_endline (str_of_term t)) (List.map (fun s -> apply s qry) sols)





