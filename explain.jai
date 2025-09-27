SCB :: Line.{.Start_Code_Block, ""};
ECB :: Line.{.End_Code_Block, ""};
EML :: Line.{.Text, ""};

explanation :: Line.[
	.{.Header1, "1- Unfurl Explanation"}
,	.{.Line, "Unfurl is really nothing more than an elaborate substitution machine."}
,	.{.Text, "You input rules:"}, SCB
,	.{.Rule_Arg, "a"}, .{.Rule_Res, "b"}, ECB
,	.{.Text, "And queries:"}, SCB
,	.{.Query, "bbb"}, ECB
,	.{.Text, "And the evaluator applies the rules to the queries:"}, SCB
,	.{.Result_Solved, "aaa"}, ECB
,	EML
,	.{.Text, "Interestingly enough, there is an enormous wealth of complexity that can be extracted"}
,	.{.Line, "from this simple paradigm."}
,	.{.Text, "For example, some rules and inputs have multiple different combinations. The evaluator"}
,	.{.Line, "always evaluates every single possible combination."}
,	.{.Text, "As an example:"}, SCB
,	.{.Rule_Arg, "aa"}, .{.Rule_Res, "b"}
,	.{.Query, "aaa"}, ECB
,	.{.Text, "Has two possible solutions:"}, SCB
,	.{.Result_Solved, "ba"}, .{.Result_Solved, "ab"}, ECB
,	.{.Text, "A more elaborate example:"}, SCB
,	.{.Rule_Arg, "aa"}, .{.Rule_Res, "u"}
,	.{.Rule_Arg, "aa"}, .{.Rule_Res, "v"}
,	.{.Query, "aaa"}, ECB
,	.{.Text, "Results in four possible solutions:"}, SCB
,	.{.Result_Solved, "ua"}, .{.Result_Solved, "au"}, .{.Result_Solved, "va"}, .{.Result_Solved, "av"}, ECB
,	EML
,	.{.Text, "The evaluation continues applying rules until no more changes happen. This has two"}
,	.{.Text, "implications."}
,	.{.Text, "1) Infinite evalution is possible:"}, SCB
,	.{.Rule_Arg, "n"}, .{.Rule_Res, "nn"}, .{.Query, "n"}, ECB
,	.{.Text, "2) The rules are applied to 'intermediate' results. This is where most of the real"}
,	.{.Line, "   useful complexity of Unfurl comes from."}
,	.{.Text, "As a basic example:"}, SCB
,	.{.Rule_Arg, "N0"}, .{.Rule_Res, "1"}
,	.{.Rule_Arg, "N1"}, .{.Rule_Res, "2"}
,	.{.Rule_Arg, "N2"}, .{.Rule_Res, "3"}
,	.{.Query, "NNN0"}, ECB
,	.{.Text, "Results in:"}, SCB
,	.{.Result_Solved, "3"}, ECB
,	.{.Text, "When running the evaluator with `-all-states`, you can see all the intermediate steps."}, SCB
,	.{.Result_Interm, "NNN0"}
,	.{.Result_Interm, "NN1"}
,	.{.Result_Interm, "N2"}
,	.{.Result_Solved_Verbose, "3"}, ECB
,	EML
,	.{.Header3, "1.1- Writing .furl files (aka my parser is not so smart so don't shake it too much it'll throw up)"}
,	.{.Line, "The only valid input is ascii."}
,	.{.Text, "All whitespace is ignored and removed (so spaces will not show up in rules,"}
,	.{.Line, "queries, or solutions)."}
,	.{.Line, "Comments can be placed between parentheses (like so (they can nest))."}
,	.{.Text, "When calling the evaluator on multiple files at once, all their rules and queries are"}
,	.{.Text, "combined into one larger evaluation pool."}
,	EML
];

explain_turing :: Line.[
	.{.Header2, "2- Turing Compleness"}
,	.{.Text, "Unfurl is turing complete. The reason why anything is Turing complete is always somewhat"}
,	.{.Line, "vague, since it comes down to \"Can you do the things that a Turing machine can do?\""}
,	.{.Text, "The standard way to go about proving this is to provide a method to simulate any Turing"}
,	.{.Line, "machine, or to simulate something else that can simulate any turing machine."}
,	.{.Text, "In Unfurl's case, both have been done. The latter via an implementation of rule 110, and"}
,	.{.Text, "the former will be outlined in here. Furthermore, we will look at some important qualities"}
,	.{.Text, "of Unfurl that make these things possible."}
,	EML
,	.{.Header3, "2.1- Important Qualities of Equivalence"}
,	.{.Header4, "2.1.1- The Readhead"}
,	.{.Text, "Turing machines sit on a tape and move cell-by-cell. Unfurl evaluates one tape in full, but"}
,	.{.Text, "in order to apply rules, it subdivides the tape into smaller 'subtapes' to compare against."}
,	.{.Text, "In fact, it subdivides in all possible ways, which means that there is always a set of"}
,	.{.Text, "'subtapes' that _look_ like a 'scanning window' of the full tape: just like the one a Turing"}
,	.{.Text, "machine sees. Let's take the following rule and query:"}, SCB
,	.{.Rule_Arg, "a"}, .{.Rule_Res, ">A"}, .{.Query, "aaa"}, ECB
,	.{.Text, "When we look at the intermediate results, we can see that the first three applications appear"}
,	.{.Text, "as if there is a readhead going through the tape, capitalizing the letter it looks at."}, SCB
,	.{.Result_Interm, ">Aaa"}, .{.Result_Interm, "a>Aa"}, .{.Result_Interm, "aa>A"}, ECB
,	.{.Line, "Of course, the evaluator continues, because we did not fully constrain it."}
,	.{.Text, "To constrain it, we can include the readhead in the query, as well as including it"}
,	.{.Text, "in every rule, so that evaluation can only happen wherever the readhead is."}
,	EML
,	.{.Header4, "2.1.2- The Unbounded Tape"}
,	.{.Text, "Turing machines have infinite tapes. At least, they are not principially bounded."}
,	.{.Text, "Unfurl begins with a finite tape, but there is a large number of rulesets that expand the"}
,	.{.Text, "tape during evaluation, since the length of a rule's result can be larger than its input:"}, SCB
,	.{.Rule_Arg, "a"}, .{.Rule_Res, "bbb"}, .{.Query, "aaa"}, .{.Result_Solved, "bbbbbbbbb"}, ECB
,	.{.Text, "A good way to make use of this is to have 'end markers' on the tape, and some rules to"}
,	.{.Text, "expand the tape when required."}
,	EML
,	.{.Header4, "2.1.2- 'Internal' State"}
,	.{.Text, "Finally, Turing machines have internal state. Unfurl does not have this at all."}
,	.{.Text, "However, that is not the end of the line; internal state can be translated into"}
,	.{.Text, "symbols on the tape, and the ruleset adjusted accordingly. More on this later."}
// ,	.{.Header3, "2.2- Making the Evaluator 'Walk' and Externalizing Internal State"}
// ,	.{.Text, "When directly simulating a turing machine, it can be impractical how unfurl evaluates"}
// ,	.{.Text, "at all points on the tape at the same time. Indeed, it can lead to"}
// ,	.{.Text, "guarenteed 'race conditions'. To mitigate this, there are two prominent strategies."}
// ,	EML
// ,	.{.Text, "The first technique is to constrain evaluation to one point in the tape using a 'readhead'"}
// ,	.{.Text, "that is included in every rule."}, SCB
// ,	.{.Rule_Arg, "|a"}, .{.Rule_Res, "b|"}, .{.Query, "|aaa"}, ECB
// ,	.{.Text, "When looking at the intermediate states, we can see how the evaluation went very orderly:"}, SCB
// ,	.{.Result_Interm, "|aaa"}, .{.Result_Interm, "b|aa"}, .{.Result_Interm, "bb|a"}, .{.Result_Solved_Verbose, "bbb|"}, ECB
// ,	.{.Text, "As opposed to without the readhead:"}, SCB
// ,	.{.Rule_Arg, "a"}, .{.Rule_Res, "b"}, .{.Query, "aaa"}, .{.Result_Interm, "aaa"}
// ,	.{.Result_Interm, "baa"}, .{.Result_Interm, "aba"}, .{.Result_Interm, "aab"}
// ,	.{.Result_Interm, "bba"}, .{.Result_Interm, "bab"}, .{.Result_Interm, "abb"}
// ,	.{.Result_Solved_Verbose, "bbb"}, ECB
// ,	EML
// ,	.{.Text, "The second technique is to change the symbol set during evaluation."}
// ,	.{.Text, "Generally this is only useful in conjuction with the first technique."}
// ,	.{.Text, "UNFINISHED"}
,	.{.Header3, "2.2- General technique for converting a Turing machine to Unfurl substitution rules"}
,	.{.Text, "There is of course more than one way to do this, but the technique layed out here"}
,	.{.Text, "approaches optimal."}
,	.{.Text, "UNFINISHED"}
,	EML
];

explain_usefulness :: Line.[
	.{.Header2, "3- What is this good for?"}
,	.{.Text, "I wanted to make a really simple language that I could practice"}
,	.{.Line, "nontrivial multithreading on."}
,	.{.Text, "After I'd made the reference interpreter, I realized that it's really fascinating to"}
,	.{.Text, "have a single-operator turing complete language, and it's a fun sort of puzzle"}
,	.{.Text, "activity to play with."}
,	EML
,	.{.Text, "This being said, at some point I want to make a 'program searcher', that can find"}
,	.{.Text, "rulesets to solve problems on its own."}
,	EML
];
