![owl](logo.png)

# Owl

Owl is a tiny logic programming language highly inspired by prolog. A version including a type sytem and an efficient indexing algorithm is in progress.

## Installing and testing Owl

Installing simply requires [dune](https://dune.build/).

```
git clone https://github.com/jdrprod/owl.git
cd owl
dune install owl
```

## Programming in Owl

### Rules and Facts

The syntax of Owl is very similar to prolog. We can define facts and rules:

**A Fact**
```
likes(foo, bar).
```
*Notice that capital case characters are not allowed*

**A Rule**
```prolog
likes(?x, meat) :- carnivores(?x).
```
*Notice that variables are introduced using a question mark*

This rules could be traduced in first order logic as `forall x, carnivores(x) -> likes(x, meat)`.

Rules can be more complex. We can express conjunctions by using the `&` operator :

```prolog
green(?x) :- blue(?x) & yellow(?x).
```

One can also express disjunctions by repeating several times a rule and modifying its right-hand side:

```prolog
colored(?x) :- red(?x).
colored(?x) :- yellow(?x).
colored(?x) :- blue(?x).
```

### Notations

Owl comes with a special notation for natural numbers. They are defined in the style of **Peano** : a natural number is simply zero or the successor of an other natural number. The **successor** function is abbreviated `s` and the constant `z` denotes **zero**. We can then represent 3 as `s(s(s(z)))` in Owl. To prevent writing unreadable programs, we can also use the standard notations `1, 2, 3 ...`. Owl will automatically convert numbers into the internal representation.

### Asking the database

Facts and rules should be defined inside a text file. The file can then be loaded using the command `owl path/to/file`. This will start an interactive session allowing to type queries. Notice that queries don't support the `&` operator. This feature will be added soon.

## Examples

Here is a simple implementation of natural numbers addition :

```prolog
sum(z, ?x, ?x).
sum(s(?x), ?y, s(?z)) :- sum(?x, ?y, ?z).
```

The following query computes the sum of 1 and 1 :

```prolog
sum(1, 1, ?x).
-> sum(1, 1, 2)
```

We could also define data-structures such as lists in Owl :

```prolog
list(nil).
list(cons(?head, ?tail)) :- list(?tail).

list_append(nil, ?x, cons(?x, nil)).
list_append(cs(?head, ?tail), ?x, cs(?head, ?next)) :- list_append(?tail, ?x ?next).

list_reverse(nil, nil).
list_reverse(cons(?head, ?tail), ?rev) :- list_append(?rev_tail, ?head, ?rev) & list_reverse(?tail, ?rev_tail).
```

To reverse a list, we can type the following query :

```prolog
list_reverse(cons(1, cons(2, cons(3, nil))), ?x)
```

We can also ask which list is gives another list once reversed :

```prolog
list_reverse(?x, cons(1, cons(2, cons(3, nil))))
```

## Warning

The current implementation of the solver behind Owl is not guarantee to terminate against any query. Nevertheless, depending on the way programs are written, some infinite loops may be avoided. For example, in the `list_reverse` rule, swapping the order of the conjuncts in the right-hand side produces an infinite loop against the query `list_reverse(?x, cs(1, cs(2, nil)))`. The solver will first apply recursively the rule `list_reverse`, which will lead to another recursive application of the rule `list_reverse` and so on. By applying `list_append` first, the problem is solved.
