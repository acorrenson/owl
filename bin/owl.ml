open Lib.Solver
open Lib.Unification
open Lib.Language
open Lib.Loger

let display_sol qry sol =
  match sol with
  | None ->
    print_endline "no rules or knowledge matching this query"
  | Some u -> str_of_term (apply_subst u qry) |> print_endline

let display_sol2 qry sols =
  match sols with
  | [] -> print_endline "no rules or knowledge matching this query"
  | _ ->
    List.iter
      (fun u -> str_of_term (apply_subst u qry) |> print_endline) sols

let repl db =
  try while true do
      print_string "λ "; flush stdout;
      let inp = read_line () in
      match parse_command inp with
      | Some qry ->
        (* solve qry db |> display_sol qry *)
        solve_all qry db |> display_sol2 qry
      | None -> print_endline "!! invalid query !!"
    done
  with End_of_file -> print_endline "Bye !"; exit 0

let () =
  match parse_from_file (Sys.argv.(1)) with
  | Some db -> repl db
  | None -> failwith "syntax error"




