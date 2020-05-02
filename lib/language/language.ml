open Libnacc
open Parsing
open Parsers
open Terms
open Notations

let alpha = one_in "abcdefghijklmnopqrstuvwxyz_"
let digit = one_in "0123456789"
let implode l = List.(fold_left (^) "" @@ map (String.make 1) l)
let ident = implode <$> some alpha
let nat = (fun x -> implode x |> int_of_string |> nat_to_term) <$> some digit
let variable = var <$> char '?' *> ident
let constant = (fun i -> ffun i []) <$> ident

let one p = (fun x -> [x]) <$> p
let sep = (spaced (char ',')) *> pure (@)
let conj = (spaced (char '&')) *> pure (@)

let parse_args =
  let rec rargs inp =
    inp --> chainl sep ~~rterm
  and rterm inp =
    inp --> (one nat <|> (one variable <|> one ~~rfun))
  and rfun inp =
    inp --> (ffun <$> ident <*> parenthesized '(' ~~rargs ')' <|> constant)
  in
  ~~rargs

let parse_fun =
  ffun <$> ident <*> parenthesized '(' parse_args ')'

let parse_rule =
  let op = spaced (char ':' *> char '-')
  and qry = spaced @@ chainl conj (one parse_fun)
  in
  rule (ref 0) <$> parse_fun <*> op *> qry <* char '.'

let parse_know =
  fact (ref 0) <$> parse_fun <* char '.'

let parse_stmt =
  parse_rule <|> parse_know

let parse_prog =
  many (blanks *> parse_stmt <* blanks)

let parse_command =
  do_parse parse_fun

let parse_from_file f =
  do_parse_from_file parse_prog f

