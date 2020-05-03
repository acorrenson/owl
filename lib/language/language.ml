open Libnacc
open Parsing
open Parsers
open Terms
open Notations

let alpha = one_in "abcdefghijklmnopqrstuvwxyz_"
let implode l = List.(fold_left (^) "" @@ map (String.make 1) l)
let ident = implode <$> some alpha

let parse_nat = nat_to_term <$> integer
let parse_var = var <$> char '?' *> ident
let parse_const = (fun i -> ffun i []) <$> ident

let one p = (fun x -> [x]) <$> p
let sep = (spaced (char ',')) *> pure (@)

let parse_conj = spaced (char '&') *> pure conj
let parse_disj = spaced (char '|') *> pure disj

let parse_args =
  let rec rargs inp =
    inp --> chainl sep ~~rterm
  and rterm inp =
    inp --> (one parse_nat <|> (one parse_var <|> one ~~rfun))
  and rfun inp =
    inp --> (ffun <$> ident <*> parenthesized '(' ~~rargs ')' <|> parse_const)
  in
  ~~rargs

let parse_fun =
  ffun <$> ident <*> parenthesized '(' parse_args ')'

let parse_qry =
  let rec rdisj inp =
    inp --> chainl parse_disj ~~rconj
  and rconj inp =
    inp --> chainl parse_conj ~~rsimple
  and rsimple inp =
    inp --> (simple <$> parse_fun <|> parenthesized '(' ~~rdisj ')')
  in
  ~~rdisj

let parse_rule =
  let op = spaced (char ':' *> char '-')
  and qry = spaced @@ chainl parse_conj (simple <$> parse_fun)
  in
  rule <$> parse_fun <*> op *> qry <* char '.'

let parse_fact =
  fact <$> parse_fun <* char '.'

let parse_stmt =
  parse_rule <|> parse_fact

let parse_prog =
  many (blanks *> parse_stmt <* blanks)

let read_qry =
  do_parse parse_qry

let read_from_file f =
  do_parse_from_file parse_prog f

