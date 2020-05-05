open Lib.Solver
open Lib.Terms
open Lib.Unification
open Lib.Language
open Lib.Notations
open Lib.Loger
open Lib.Streams
open Libnacc.Parsing

let display_one qry sol =
  map_qry (fun t -> apply_subst sol t |> pretty_notations) qry
  |> str_of_qry
  |> print_endline

let abort () =
  print_string "[next : 1] [abort : 2] [+5 : A] [+10 : B] ";
  flush stdout;
  let rec step () =
    match read_line () with
    | "abort" | "2" -> `Abort
    | "next" | "1" -> `Next
    | "A" | "+5" -> `PlusFive
    | "B" | "+10" -> `PlusTen
    | _ -> step ()
  in
  step ()

let display_sols qry sols =
  match Lazy.force sols with
  | Nil ->
    if no_vars_qry qry then print_endline "false"
    else print_endline "no rules or knowledge matching this query"
  | _ ->
    if no_vars_qry qry then print_endline "true"
    else begin
      let step next =
        match abort () with
        | `PlusFive -> itern 5 (display_one qry) next
        | `PlusTen -> itern 10 (display_one qry) next
        | `Next -> itern 1 (display_one qry) next
        | `Abort -> ()
      in
      step sols
    end

let repl db =
  try while true do
      print_string "?- "; flush stdout;
      let inp = read_line () in
      match read_qry inp with
      | Ok qry ->
        solve qry db |> display_sols qry
      | Error e ->
        print_endline "!! invalid query !!";
        Libnacc.Parsing.report e
    done
  with End_of_file -> print_endline "Bye !"; exit 0

let () =
  match read_from_file (Sys.argv.(1)) with
  | Ok db -> repl db
  | Error e ->
    report e;
    failwith "syntax error"




