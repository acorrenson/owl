open Lib.Solver
open Lib.Terms
open Lib.Unification
open Lib.Language
open Lib.Notations
open Lib.Loger
open Libnacc.Parsing

let display_sols qry sols =
  (* List.iter (fun s -> print_endline (str_of_substl s)) sols; *)
  match sols with
  | [] ->
    if no_vars_qry qry then print_endline "false"
    else print_endline "no rules or knowledge matching this query"
  | _ ->
    if no_vars_qry qry then print_endline "true"
    else List.iter (fun u ->
        map_qry (fun t -> apply_subst u t |> pretty_notations) qry
        |> str_of_qry
        |> print_endline) sols

let repl db =
  try while true do
      print_string "λ "; flush stdout;
      let inp = read_line () in
      match read_qry inp with
      | Ok qry ->
        solve qry db |> Lib.Streams.peek 1 |> fst |> display_sols qry
      | Error e ->
        print_endline "!! invalid query !!";
        Libnacc.Parsing.report e
    done
  with End_of_file -> print_endline "Bye !"; exit 0

let () =
  match read_from_file (Sys.argv.(1)) with
  | Ok db -> repl (db |> Lib.Streams.of_list)
  | Error e ->
    report e;
    failwith "syntax error"




