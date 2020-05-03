open Terms

(** Test if a variable is free in a term
    @param x the variable name
    @param t the term *)
let rec fv x t =
  match t with
  | Var y when x = y -> true
  | Var _ -> false
  | FFun (_, args) -> List.exists ((=) true) (List.map (fv x) args)

(** Apply a substitution s in a term
    @param s a substitution
    @param t a term *)
let rec apply_subst s t =
  match t with
  | FFun (f, args) ->
    FFun (f, List.map (apply_subst s) args)
  | Var x ->
    match List.assoc_opt x s with
    | Some t' -> t'
    | None -> t

let subst_eq s1 s2 =
  let l1 = List.sort (fun a b -> compare (fst a) (fst b)) s1
  and l2 = List.sort (fun a b -> compare (fst a) (fst b)) s2
  in l1 = l2

(** Compose a subsitution and a "one variable" substitution
    @param sub  a substitution
    @param asg  a "one variable" substitution *)
let compose_one sub asg =
  asg::(List.map (fun (v, t) -> v, apply_subst [asg] t) sub)

let compose s1 s2 =
  s2 @ (List.map (fun (v, t) -> v, apply_subst s2 t) s1)

(** Apply a substitution in a term equation 
    @param sub      the substitution
    @param (e1, e2) the equation *)
let apply_equ sub (e1, e2) = apply_subst sub e1, apply_subst sub e2

(** Apply a substitution in a system of term equation 
    @param sub  the substitution
    @param equs the system *)
let apply_sys sub equs = List.map (apply_equ sub) equs

(** { 2 - Warning !!!!} 

    Substitutions are usually represented 
*)

type equs = (term * term ) list [@@deriving show]

(** Resolve a system of term equations *)
let unify equs =
  let cycle x t = fv x t in
  let clash f l1 g l2 = f <> g || List.length l1 <> List.length l2 in
  let rec unify_rec equs sol =
    match equs with
    | [] -> Some sol
    | (tx, ty)::tail when tx = ty -> unify_rec tail sol
    | (Var x, t)::tail ->
      if cycle x t then None
      else unify_rec (apply_sys [x, t] tail) (compose_one sol (x, t))
    | (t, Var x)::tail -> unify_rec ((Var x, t)::tail) sol
    | (FFun (f, l1), FFun (g, l2))::tail ->
      if clash f l1 g l2 then None
      else unify_rec ((List.combine l1 l2) @ tail) sol
  in
  unify_rec equs []

type sol = (string * term) list option [@@deriving show]