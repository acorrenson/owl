open Owl_core.Core
open Owl_core.Language

let display_sols qry sols =
  match sols with
  | [] ->
    print_endline "no rules or knowledge matching this query"
  | _ -> print_sols qry sols

let repl db =
  try while true do
      print_string "λ "; flush stdout;
      let inp = read_line () in
      match parse_command inp with
      | Some qry -> solve_one qry db |> display_sols qry
      | None -> print_endline "!! invalid query !!"
    done
  with End_of_file -> print_endline "Bye !"; exit 0

let () =
  match parse_from_file (Sys.argv.(1)) with
  | Some db -> repl db
  | None -> failwith "syntax error"




