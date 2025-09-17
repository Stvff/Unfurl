SCB :: Line.{.START_CODE_BLOCK, ""};
ECB :: Line.{.END_CODE_BLOCK, ""};
EML :: Line.{.TEXT, ""};

explanation :: Line.[
	.{.HEADER1, "1- Unfurl Explanation"}
,	.{.LINE, "Unfurl is really nothing more than an elaborate substitution machine."}
,	.{.TEXT, "You input rules:"}, SCB
,	.{.RULE_ARG, "a"}, .{.RULE_RES, "b"}, ECB
,	.{.TEXT, "And queries:"}, SCB
,	.{.QUERY, "bbb"}, ECB
,	.{.TEXT, "And the evaluator applies the rules to the queries:"}, SCB
,	.{.RESULT_SOLVED, "aaa"}, ECB
,	EML
,	.{.TEXT, "Interestingly enough, there is an enormous wealth of complexity that can be extracted"}
,	.{.LINE, "from this simple paradigm."}
,	.{.TEXT, "For example, some rules and inputs have multiple different combinations. The evaluator"}
,	.{.LINE, "always evaluates every single possible combination."}
,	.{.TEXT, "As an example:"}, SCB
,	.{.RULE_ARG, "aa"}, .{.RULE_RES, "b"}
,	.{.QUERY, "aaa"}, ECB
,	.{.TEXT, "Has two possible solutions:"}, SCB
,	.{.RESULT_SOLVED, "ba"}, .{.RESULT_SOLVED, "ab"}, ECB
,	.{.TEXT, "A more elaborate example:"}, SCB
,	.{.RULE_ARG, "aa"}, .{.RULE_RES, "u"}
,	.{.RULE_ARG, "aa"}, .{.RULE_RES, "v"}
,	.{.QUERY, "aaa"}, ECB
,	.{.TEXT, "Results in four possible solutions:"}, SCB
,	.{.RESULT_SOLVED, "ua"}, .{.RESULT_SOLVED, "au"}, .{.RESULT_SOLVED, "va"}, .{.RESULT_SOLVED, "av"}, ECB
,	EML
,	.{.TEXT, "The evaluation continues applying rules until no more changes happen. This has two"}
,	.{.TEXT, "implications."}
,	.{.TEXT, "1) Infinite evalution is possible:"}, SCB
,	.{.RULE_ARG, "n"}, .{.RULE_RES, "nn"}, .{.QUERY, "n"}, ECB
,	.{.TEXT, "2) The rules are applied to 'intermediate' results. This is where most of the real"}
,	.{.LINE, "   useful complexity of Unfurl comes from."}
,	.{.TEXT, "As a basic example:"}, SCB
,	.{.RULE_ARG, "N0"}, .{.RULE_RES, "1"}
,	.{.RULE_ARG, "N1"}, .{.RULE_RES, "2"}
,	.{.RULE_ARG, "N2"}, .{.RULE_RES, "3"}
,	.{.QUERY, "NNN0"}, ECB
,	.{.TEXT, "Results in:"}, SCB
,	.{.RESULT_SOLVED, "3"}, ECB
,	.{.TEXT, "When running the evaluator with `-all-states`, you can see all the intermediate steps."}, SCB
,	.{.RESULT_INTERM, "NNN0"}
,	.{.RESULT_INTERM, "NN1"}
,	.{.RESULT_INTERM, "N2"}
,	.{.RESULT_SOLVED_VERBOSE, "3"}, ECB
,	EML
,	.{.HEADER3, "1.1- Writing .furl files (aka my parser is not so smart so don't shake it too much it'll throw up)"}
,	.{.LINE, "The only valid input is ascii."}
,	.{.TEXT, "All whitespace is ignored and removed (so spaces will not show up in rules,"}
,	.{.LINE, "queries, or solutions)."}
,	.{.LINE, "Comments can be placed between parentheses (like so (also they can nest))."}
,	.{.TEXT, "When calling the evaluator on multiple files at once, all their rules and queries are"}
,	.{.TEXT, "combined into one larger evaluation pool."}
,	EML
];

explain_turing :: Line.[
	.{.HEADER2, "2- Turing Compleness"}
,	.{.TEXT, "Unfurl is turing complete. The reason why anything is Turing complete is always somewhat"}
,	.{.LINE, "vague, since it comes down to \"Can you do the things that a Turing machine can do?\""}
,	.{.TEXT, "The standard way to go about proving this is to simulate a Turing machine, or to simulate"}
,	.{.LINE, "something else that can simulate a turing machine."}
,	.{.TEXT, "In Unfurl's case, the latter has been done (via rule 110), and I'll attempt to lay out"}
,	.{.TEXT, "a rough guide on how to do the former here, as well as highlight some important"}
,	.{.TEXT, "qualities that make it possible."}
,	EML
,	.{.HEADER3, "2.1- Important Qualities of Equivalence"}
,	.{.TEXT, "Turing machines sit on a tape and move cell-by-cell. Unfurl evaluates one tape in full, but"}
,	.{.TEXT, "in order to apply rules, it subdivides the tape into smaller 'subtapes' to compare against."}
,	.{.TEXT, "In fact, it subdivides in all possible ways, whichs means that there is always a set of"}
,	.{.TEXT, "'subtapes' that _look_ like a 'scanning window' of the full tape: just like the one a Turing"}
,	.{.TEXT, "machine sees. We will look at how to leverage this effectively in the next paragraph."}
,	EML
,	.{.TEXT, "Turing machines have infinite tapes. At least, they are not principially bounded."}
,	.{.TEXT, "Unfurl begins with a finite tape, but there is a large number of rulesets that expand the"}
,	.{.TEXT, "tape during evaluation, since the length of a rule's result can be larger than its input:"}, SCB
,	.{.RULE_ARG, "a"}, .{.RULE_RES, "bbb"}, .{.QUERY, "aaa"}, .{.RESULT_SOLVED, "bbbbbbbbb"}, ECB
,	.{.TEXT, "A good way to make use of this is to have 'end markers' on the tape, and some rules to"}
,	.{.TEXT, "expand the tape when required."}
,	EML
,	.{.TEXT, "Finally, Turing machines have internal state. Unfurl does not have this at all."}
,	.{.TEXT, "However, that is not the end of the line; internal state can be translated into"}
,	.{.TEXT, "symbols on the tape, and the ruleset adjusted accordingly. More on this later."}
,	EML
,	.{.HEADER3, "2.2- Making the Evaluator 'Walk' and Externalizing Internal State"}
,	.{.TEXT, "When directly simulating a turing machine, it can be impractical how unfurl evaluates"}
,	.{.TEXT, "at all points on the tape at the same time. Indeed, it can lead to"}
,	.{.TEXT, "guarenteed 'race conditions'. To mitigate this, there are two prominent strategies."}
,	EML
,	.{.TEXT, "The first technique is to constrain evaluation to one point in the tape using a 'readhead'"}
,	.{.TEXT, "that is included in every rule."}, SCB
,	.{.RULE_ARG, "|a"}, .{.RULE_RES, "b|"}, .{.QUERY, "|aaa"}, ECB
,	.{.TEXT, "When looking at the intermediate states, we can see how the evaluation went very orderly:"}, SCB
,	.{.RESULT_INTERM, "|aaa"}, .{.RESULT_INTERM, "b|aa"}, .{.RESULT_INTERM, "bb|a"}, .{.RESULT_SOLVED_VERBOSE, "bbb|"}, ECB
,	.{.TEXT, "As opposed to without the readhead:"}, SCB
,	.{.RULE_ARG, "a"}, .{.RULE_RES, "b"}, .{.QUERY, "aaa"}, .{.RESULT_INTERM, "aaa"}
,	.{.RESULT_INTERM, "baa"}, .{.RESULT_INTERM, "aba"}, .{.RESULT_INTERM, "aab"}
,	.{.RESULT_INTERM, "bba"}, .{.RESULT_INTERM, "bab"}, .{.RESULT_INTERM, "abb"}
,	.{.RESULT_SOLVED_VERBOSE, "bbb"}, ECB
,	EML
,	.{.TEXT, "The second technique is to change the symbol set during evaluation."}
,	.{.TEXT, "Generally this is only useful in conjuction with the first technique."}
,	.{.TEXT, "UNFINISHED"}
];

explain_usefulness :: Line.[
	.{.HEADER2, "3- What is this good for?"}
,	.{.TEXT, "I wanted to make a really simple language that I could practice"}
,	.{.LINE, "nontrivial multithreading on."}
,	.{.TEXT, "After I'd made the reference interpreter, I realized that it's really fascinating to"}
,	.{.TEXT, "have a single-operator turing complete language, and it's a fun sort of puzzle"}
,	.{.TEXT, "activity to play with."}
,	EML
,	.{.TEXT, "This being said, at some point I want to make a 'program searcher', that can find"}
,	.{.TEXT, "rulesets to solve problems on its own."}
,	EML
];
