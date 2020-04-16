open Libnacc
open Parsing
open Parsers
open Unification
open Solver

let alpha = one_in "abcdefghijklmnopqrstuvwxyz_"
let implode l = List.fold_left (^) "" (List.map (String.make 1) l)
let ident = implode <$> many alpha
let variable = var <$> char '?' *> ident
let constant = (fun i -> ffun i []) <$> ident

let ( let* ) p f =
  let inner input =
    match input --> p with
    | None -> None
    | Some (v, r) -> r --> f v
  in
  ~~inner

let chainl op term =
  let rec loop v =
    (let* f = op in
     let* y = term in
     loop (f v y))
    <|> pure v
  in
  let* x = term in
  loop x

let one p = (fun x -> [x]) <$> p
let sep = (spaced (char ',')) *> pure (@)

let parse_args =
  let rec rargs inp = inp --> chainl sep ~~rterm
  and rterm inp = inp --> ((one variable) <|> (one ~~rfun))
  and rfun inp = inp --> (ffun <$> ident <*> parenthesized '(' ~~rargs ')' <|> constant)
  in
  ~~rargs

let parse_fun =
  ffun <$> ident <*> parenthesized '(' parse_args ')'

let parse_rule =
  rule (ref 0) <$> parse_fun <*> spaced (char ':' *> char '-') *> many (spaced parse_fun) <* char '.'

let parse_know =
  know (ref 0) <$> parse_fun <* char '.'

let parse_stmt = parse_rule <|> parse_know

let parse_prog = many (blanks *> parse_stmt <* blanks)


let string_of_ic ic =
  let s = ref "" in
  let ok = ref false in
  while not !ok do
    try s := !s ^ (input_line ic) ^ "\n"
    with End_of_file -> ok := true;
  done;
  !s

let parse_from_file f =
  open_in f
  |> string_of_ic
  |> do_parse parse_prog

let parse_command = do_parse parse_fun