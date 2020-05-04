(** Lazy Streams for deffered computations
    {1 Why a custom module ? }

    This module provides a simple implementation of lazy streams.
    One can wonder why not using the {{: https://caml.inria.fr/pub/docs/manual-ocaml/libref/Seq.html} Seq}
    module included in the ocaml standard library. The reason is realy simple, we need custom operators and 
    performances. Moreover, values are delayed under a closure in the {!Seq} module and we want to make use
    of the more efficient lazy blocks.

    {1 Why using lazy streams inside Owl ? }

    Logic programming is all about a compromise between the expressiveness of the language we expose and
    the capability for the so called solver to find answers in a reasonable time.
    In particular, the more expressivity you let for the programmers to play with, the more complicated it becomes
    to ensure that the solver will always find an answer to some problems. The typical exemple is recursive definitions.

    Let's condiser the following logic program :
    [
      p(?x) :- q(?x).
      q(?x) :- p(?x).
      p(a).
    ] and the simple query [p(?x)]. It seems completely obvious that the only possible answer to this query is [?x = a].
    However, a naive implementation of the solver may never found this trivial result because of infinite loops.
    The query [p(?x)] may lead the solver to apply the rule [p(?x) :- q(?x)] which lead to use the rule [q(?x) :- p(?x)]
    which again require the application of [p(?x) :- q(?x)] creating an infinite loop.

    Such problems happend when we want to find all possible solutions to a given query. A simple work-arround is to propose a procedure
    capable to find a single solution and to stop as soon as possible. In this case, the solver may find the fact [p(a)] in the
    database and stop (provided we implement a stragey contstraining the solver to search over facts before applying rules).
    This solution is sadly not acceptable. When it comes to compoud queries using conjunctions we sometimes need to explore 
    every combinations of solutions to find the one which satisfies the set of constraints. Moreover, users of our programming language
    may need to extract every solutions to a query for any reason. Therefore, we need to find a more reliable solution to the
    infinite loop problem.

    Let's again consider the rules and facts [q(?x) :- p(?x) & r(?x). p(a). p(b). r(b).]. Given this program, the query [q(?x)] has a unique
    solution [?x = b]. But if the solver search the database preserving its order, the first partial solution found is [?x = a] 
    (to satisfy the conjunction [p(?x) & r(?x)]) but [r(a)] is unsatisfiable in the context. The solver got stuck.
    Note that in this case, reversing the order of the conjuncts solve the problem.

    We just discussed annoying problems about writing a solver. Solutions exists for specific problems. An experienced programmer may
    also find a way to express rules which may prevent the solver to get stuck. But as soon as programs become longer, we can't assume
    the programmer to have a precise understanding of the solver to write working code. We need a clean, reliable and efficient solver
    capable to solve trivial problems without requiring explicit efforts from the programmers.

    The simple solution is of course Lazy Streams. We want a way to search the database incrementaly, preventing the solver to loop with
    recursive rules. We want a way to represent the set of every solutions to a query without explicitely computing it (cause it may lead to infinite loops).
    This is exactly the inferface exposed by Lazy Streams. Combined with good reasearch stragies, we can avoid many of the problems we've disccussed
    earlier and delay as much as possible the time when the solver is blocked trying to find every solutions to an infinite problem.
*)

(** {2 - Types } *)

(** A delayed value *)
type 'a stream = 'a node Lazy.t

(** An evaluated node *)
and 'a node =
  | Nil
  | Cons of 'a * 'a stream

(** {2 - Operators and constructors } *)

(** The empty stream *)
val empty : 'a stream

(** [return x] is the singleton stream containing [x] *)
val return : 'a -> 'a stream

(** Apply a function [f] to each node of a stream.
    The actual computations are delayed *)
val map : ('a -> 'b) -> 'a stream -> 'b stream

(** Concatenate two streams.
    Computations are delayed *)
val append : 'a stream -> 'a stream -> 'a stream

(** Concatenate two streams interleaving values.
    Using {!interleave} instead of {!append}
    ensures that every values may be reached if the streams are infinite *)
val interleave : 'a stream -> 'a stream -> 'a stream

(** Flatten a stream of stream *)
val flat : 'a stream stream -> 'a stream

(** Apply a stream constructor on each node of a stream while flattening the result.
    Every computations are delayed *)
val flat_map : ('a -> 'b stream) -> 'a stream -> 'b stream

(** Peek the first [n] elements of a stream returning them as a simple list.
    The tail of the stream is also returned *)
val peek : int -> 'a stream -> ('a list * 'a stream)

val of_list : 'a list -> 'a stream

(** {2 - Examples } *)

(** Factorial sequence *)
val fact : int stream

(** Even numbers *)
val even : int stream

(** Odd numbers *)
val odd : int stream

(** Natural numbers sequence *)
val nat : int stream


