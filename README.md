# owl

A mini language for logic programming

## Example

Here is a simple implementation of natural numbers addition :

```prolog
sum(z, ?x, ?x).

sum(succ(?x), ?y, succ(?z)) :- sum(?x, ?y, ?z).
```

The following query computes the sum of 1 and 1 :

```prolog
sum(succ(z), succ(z), ?x).
-> m(succ(z), succ(z), succ(succ(z)))
```