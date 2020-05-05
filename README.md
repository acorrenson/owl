![owl](logo.png)

# Owl

Owl is a tiny logic programming language highly inspired by prolog. A version including a type system and a complete standard library is in progress.

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

This rule could be traduced in first order logic as `forall x, carnivores(x) -> likes(x, meat)`.

Rules can be more complex. We can express logical operators by using the symbols `&` or `|` :

```prolog
green(?x) :- blue(?x) & yellow(?x).
colored(?x) :- red(?x) | yellow(?x) | blue(?x).
```

Disjunctions can also be expressed by repeating several times a rule and modifying its right-hand side:

```prolog
colored(?x) :- red(?x).
colored(?x) :- yellow(?x).
colored(?x) :- blue(?x).
```

### Notations

Owl comes with a special notation for natural numbers. They are defined in the style of **Peano** : a natural number is simply zero or the successor of an other natural number. The **successor** function is abbreviated `s` and the constant `z` denotes **zero**. We can then represent 3 as `s(s(s(z)))` in Owl. To prevent writing unreadable programs, we can also use the standard notations `1, 2, 3 ...`. Owl will automatically convert numbers into the internal representation.

### Asking the database

Facts and rules should be defined inside a text file. The file can then be loaded using the command `owl path/to/file`. This will start an interactive session allowing to type queries.

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

We can also define data-structures such as lists in Owl :

```prolog
list(nil).
list(cons(?head, ?tail)) :- list(?tail).
```

Here is a simple implementation of `append`. This implementation takes the form of a predicate defined recursively.

```
list_append(nil, ?x, cons(?x, nil)).
list_append(cs(?head, ?tail), ?x, cs(?head, ?next)) :- list_append(?tail, ?x ?next).
```

To compute the result of appending an element to a list, we can type the following query :

```prolog
?- list_append(cons(1, cons(2, cons(3, nil))), 4, ?x)
-> list_append(cons(1, cons(2, cons(3, nil))), 4, cons(1, cons(2, cons(3, cons(4, nil)))))
```

The beauty of logic programming is that we can also ask what parameters gives a specific result :

```prolog
?- list_append(cons(1, ?x), ?y, cons(1, cons(2, cons(3, nil))))
-> list_append(cons(1, cons(2, nil)), 3, cons(1, cons(2, cons(3, nil))))
```

## Warning

The current implementation of the solver behind Owl is not guarantee to terminate against any query. Nevertheless, some recent modifications have been done to reduce this limitation. There is work in progress to improve the solver and make it both powerful and reliable. In some cases, rewriting rules by changing the order of the conjuncts may prevent the solver to be stuck in infinite loops.