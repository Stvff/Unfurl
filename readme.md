# Unfurl Explanation
Unfurl is really nothing more than an elaborate substitution machine.
You input rules:
```a := b;```
And queries:
```bbb:```
And the evaluator applies the rule to the queries:
```aaa```

Interestingly enough, there is an enormous wealth of complexity that can be extracted
from this simple paradigm.\
For example, some rules and inputs have multiple different combinations. The evaluator
always evaluates every single possible combination.\
As an example:
```aa := b;
aaa:```
Has two possible solutions:
```ba
ab```
A more elaborate example:
```aa := u;
aa := v;
aaa:```
Results in four possible solutions:
```ua
au
va
av```

The evaluation continues applying rules until no more rules can be applied. This has
two implications:
1) Infinite evaluation is possible (for example (n := nn; n:))
2) The rules are applied to 'intermediate' results. This is where most of the real
useful complexity of Unfurl comes from.\
As a basic example:
```N0 := 1;
N1 := 2;
N2 := 3;
NN0:```
Results in:
```3```
When running the evaluator with -all-states, you can see all the intermediate steps.
```NNN0, state: ANALYZED
NN1, state: ANALYZED
N2, state: ANALYZED
3, state: SOLVED```

## Writing .furl files (aka my parser is not so smart so don't shake it too much it'll throw up)
The only valid input is ascii.\
All whitespace is ignored and removed (so spaces will not show up in rules, queries, or solutions).\
Comments can be placed between parentheses (like so (also they can nest)).\
When calling the evaluator on multiple files at once, all their rules and queries are combined into
one larger evaluation pool.

## What is this good for?
I wanted to make a really simple language that I could practice non-trivial multithreading on.\
Unfurl is actually turing complete as well, so at some point I want to make a 'program searcher'
for it, which is a type of symbolic artificial intelligence.
