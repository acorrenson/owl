(**********************************************)
(*   Lazy Streams for deffered computations   *)
(**********************************************)

type 'a stream = 'a node Lazy.t
and 'a node =
  | Nil
  | Cons of 'a * 'a stream

let empty = lazy Nil

let return x = lazy (Cons (x, empty))

let rec map f s =
  lazy begin
    match Lazy.force s with
    | Nil -> Nil
    | Cons (x, xs) ->
      Cons (f x, map f xs)
  end

let rec append s1 s2 =
  lazy begin
    match Lazy.force s1 with
    | Nil -> Lazy.force s2
    | Cons (x, xs) ->
      Cons (x, append xs s2)
  end

let rec interleave s1 s2 =
  lazy begin
    match Lazy.force s1 with
    | Nil -> Lazy.force s2
    | Cons (x, xs) ->
      Cons (x, interleave s2 xs)
  end

let rec flat s =
  match Lazy.force s with
  | Nil -> lazy Nil
  | Cons(x, xs) -> append x (flat xs)


let rec flat_map f s =
  match Lazy.force s with
  | Nil -> lazy Nil
  | Cons(x, xs) -> append (f x) (flat_map f xs)


let peek n s =
  let rec step i acc ss =
    if i >= n then acc, ss
    else
      match Lazy.force ss with
      | Nil -> acc, empty
      | Cons (x, xs) ->
        step (i+1) (x::acc) xs 
  in
  let x, y = step 0 [] s in List.rev x, y

let rec of_list l =
  match l with
  | [] -> empty
  | x::xs -> lazy (Cons (x, of_list xs))

(** Examples *)

(** Factorial sequence *)
let fact =
  let rec step x a =
    Cons (a, lazy (step (x+1) (a*x)))
  in
  lazy (step 1 1)

let even =
  let rec step x =
    Cons (x, lazy (step (x + 2)))
  in
  lazy (step 0)

let odd =
  let rec step x =
    Cons (x, lazy (step (x + 2)))
  in
  lazy (step 1)

let nat = interleave even odd