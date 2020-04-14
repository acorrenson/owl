open Owl_core.Core
open Owl_core.Language
open Libnacc.Parsing

let (let*) = Option.bind

let _ =
  let* r1 = do_parse parse_stmt "f(?x, ?y) :- p(?x) p(?y)." in
  let* r2 = do_parse parse_stmt "p(h)." in
  let* r3 = do_parse parse_stmt "p(i)." in
  let* r4 = do_parse parse_stmt "p(j)." in
  let* q = do_parse parse_fun "f(?a, ?b)" in
  let db = [r1; r2; r3; r4] in
  let ll = solve_one q db in
  Some (print_sols q ll)

let _ =
  let* r1 = do_parse parse_stmt "sm(z, ?y, ?y)." in
  let* r2 = do_parse parse_stmt "sm(sc(?a), ?b, sc(?c)) :- sm(?a, ?b, ?c)." in
  let* q1 = do_parse parse_fun "sm(sc(z), z, ?r)" in
  let* q2 = do_parse parse_fun "sm(sc(z), sc(z), ?r)" in
  let db = [r1; r2] in
  let ll1 = solve_one q1 db in
  let ll2 = solve_one q2 db in
  Some (print_sols q1 ll1; print_sols q2 ll2)