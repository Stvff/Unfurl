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
,	.{.Text, "When running the evaluator with `-all-states`, it prints all the intermediate steps as well."}, SCB
,	.{.Result_Interm, "NNN0"}
,	.{.Result_Interm, "NN1"}
,	.{.Result_Interm, "N2"}
,	.{.Result_Solved_Verbose, "3"}, ECB
,	EML
,	.{.Header3, "1.1- Writing .furl files (aka my parser is not so smart so don't shake it too much it'll throw up)"}
,	.{.Line, "The only valid input is ASCII."}
,	.{.Text, "All whitespace is ignored and removed (so spaces will not show up in rules,"}
,	.{.Line, "queries, or solutions)."}
,	.{.Text, "Comments can be placed between parentheses (like so (they can nest))."}
,	EML
,	.{.Text, "Rules consist of an argument, followed by `:=` and a result, ending with `;`:"}, SCB
,	.{.Rule_Arg, "Arg"}, .{.Rule_Res, "Res"}, ECB
,	.{.Text, "Queries consist of the query string, ending with `:`;"}, SCB
,	.{.Query, "Query"}, ECB
,	.{.Text, "Arguments, results, and queries can be any ASCII string besides whitespace, nor can they"}
,	.{.Text, "contain `:`, `=`, `;`, `(`, `)`."}
,	EML
,	.{.Text, "When calling the evaluator on multiple files at once, all their rules and queries are"}
,	.{.Text, "combined into one larger evaluation pool."}
,	EML
];

explain_turing :: Line.[
	.{.Header2, "2- Turing Completeness"}
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
,	.{.Result_Interm, ">Aaa"}, .{.Result_Interm, "a>Aa"}, .{.Result_Interm, "aa>A"}, .{.Text, "..."}, ECB
,	.{.Line, "Of course, the evaluator continues, because we did not fully constrain it."}
,	.{.Text, "To constrain it, we can include the readhead in the query, as well as including it"}
,	.{.Text, "in every rule, so that evaluation can only happen wherever the readhead is."}, SCB
,	.{.Rule_Arg, ">a"}, .{.Rule_Res, ">A"}
,	.{.Query, ">aaa"}, .{.Result_Solved, ">Aaa"}
,	.{.Query, "a>aa"}, .{.Result_Solved, "a>Aa"}
,	.{.Query, "aa>a"}, .{.Result_Solved, "aa>A"}, ECB
,	.{.Text, "This readhead doesn't move yet on its own, but making it 'walk' can be easily done from here:"}, SCB
,	.{.Rule_Arg, ">a"}, .{.Rule_Res, "A>"}, .{.Query, ">aaa"}
,	.{.Result_Interm, ">aaa"}, .{.Result_Interm, "A>aa"}, .{.Result_Interm, "AA>a"}, .{.Result_Solved_Verbose, "AAA>"}, ECB
,	EML
,	.{.Header4, "2.1.2- The Unbounded Tape"}
,	.{.Text, "Turing machines sit on an infinite tape. At least, they are not principially bounded."}
,	.{.Text, "Unfurl begins with a finite tape, but there are many possible rulesets that expand the"}
,	.{.Text, "tape during evaluation, since the length of a rule's result can be larger than its input:"}, SCB
,	.{.Rule_Arg, "a"}, .{.Rule_Res, "bbb"}, .{.Query, "aaa"}, .{.Result_Solved, "bbbbbbbbb"}, ECB
,	.{.Text, "A good way to make use of this is to have 'end markers' on the tape, and some rules to"}
,	.{.Text, "expand the tape when required. Using our readhead from the previous section,"}
,	.{.Text, "we can make an orderly and infinitely expanding tape:"}, SCB
,	.{.Rule_Arg, ">a"}, .{.Rule_Res, "a>"}, .{.Rule_Arg, ">|"}, .{.Rule_Res, ">a|"}
,	.{.Query, ">aaa|"}, ECB
,	EML
,	.{.Header4, "2.1.2- The Internal State"}
,	.{.Text, "Finally, Turing machines have internal state. Unfurl does not have this at all."}
,	.{.Text, "However, that is not the end of the line; really the important part is the state"}
,	.{.Text, "of the whole system, tape and 'internal state' (or M-configuration) combined."}
,	.{.Text, "This all-encompassing state can be easily transposed onto an Unfurl tape."}
,	.{.Text, "The most straightforward way is to include the M-configuration next to the earlier"}
,	.{.Text, "defined readhead. In the following example, `1`, `2`, `3`, and `4` are M-configurations."}, SCB
,	.{.Rule_Arg, "1> a"}, .{.Rule_Res, "a 2>"}, .{.Rule_Arg, "2> a"}, .{.Rule_Res, "a 3>"}, .{.Rule_Arg, "3> a"}, .{.Rule_Res, "a 4>"}
,	.{.Query, "1> aaaaa"}, .{.Result_Solved, "aaa4>aaa"}, ECB
,	.{.Text, "A careful reader might notice that the M-configuration can serve as the readhead itself,"}
,	.{.Text, "but it is good for readability to give an indication of which symbol is currently"}
,	.{.Line, "'under' the readhead."}
,	.{.Text, "Notably, this last example is already a pretty direct transcription of a"}
,	.{.Text, "Turing machine. Indeed, we now have all the tools to start generalizing."}
,	EML
,	.{.Header3, "2.2- General technique for converting a Turing machine to Unfurl substitution rules"}
,	.{.Text, "There is of course more than one way to do this, but the technique layed out here"}
,	.{.Text, "approaches optimal."}
,	EML
,	.{.Header4, "2.2.1- Query formatting"}
,	.{.Text, "The query can consist of any number of symbols from the alphabet, but should have"}
,	.{.Text, "'end-markers' on both ends. For example:"}, SCB
,	.{.Query, "|001010|"}, ECB
,	.{.Text, "Taking q to be the initial M-configuration, the readhead on the tape is formatted like so:"}, SCB
,	.{.Query, "{q>"}
,	.{.Query, "|001 {q>0 10|"},  ECB
,	.{.Text, "The spacing is only to help us see the current symbol 'under' the readhed."}
,	.{.Text, "`{` is added to the readhead for purposes that will become clear later, but for now it"}
,	.{.Line, "also serves to seperate between readhead and tape even more."}
,	.{.Text, "A tape consisting of only empty cells can be formatted as follows:"}, SCB
,	.{.Query, "|{q>|"}, ECB
,	EML
,	.{.Header4, "2.2.2- Transcribing Rules"}
,	.{.Line, "Essentially, it is a simple translation of the 5-tuple state table."}
,	.{.Text, "Take the M-configuration (`q`) and the scanned symbol (`s`) on one side, the symbol"}
,	.{.Text, "to print (`p`) and the next M-configuration (`n`)  on the other."}, SCB
,	.{.Rule_Arg, "{q> s"}, .{.Rule_Res, "{n> p"}, ECB
,	.{.Text, "However, the readhead often also needs to move. When this is a move to the right, this"}
,	.{.Text, "is done simply by moving the readhead right of the printed symbol in the rule result:"}, SCB
,	.{.Rule_Arg, "{q> s"}, .{.Rule_Res, "p {n>"}, ECB
,	.{.Text, "When moving left, we flip the readhead. The next section will explain how that"}
,	.{.Text, "is dealt with."}, SCB
,	.{.Rule_Arg, "{q> s"}, .{.Rule_Res, "<n} p"}, ECB
,	EML
,	.{.Header4, "2.2.3- Boilerplate"}
,	.{.Text, "Next to the state-table, there are two (and a half) more things that need to be arranged"}
,	.{.Line, "before a functional Turing machine can be implemented."}
,	EML
,	.{.Text, "The first is the tape expansion, as outlined in 2.1.2, including expansion to the left:"}, SCB
,	.{.Rule_Arg, ">|"}, .{.Rule_Res, "> 0|"}
,	.{.Rule_Arg, "|<"}, .{.Rule_Res, "|0 <"}, ECB
,	.{.Line, "We use `0` as the 'empty cell' symbol here, which can of course be changed."}
,	EML
,	.{.Text, "The second thing to be arranged is the flipped readhead from earlier."}
,	.{.Text, "To define any move of the readhead, that move has to be defined for every symbol"}
,	.{.Text, "in the alphabet of the Turing machine, for every M-configuration."}, SCB
,	.{.Rule_Arg, "s <q}"}, .{.Rule_Res, "{q> s"}, ECB
,	.{.Text, "The amount of rules here is the same as the amount of entries in the 5-tuple"}
,	.{.Text, "state table, but these left-moves require a lot less strain on the mind,"}
,	.{.Text, "as there is no state change or printed symbol."}
,	EML
,	.{.Text, "The last half thing is to define what halting looks like, as well as producing"}
,	.{.Text, "intermediate steps for the final solution set. Defining the following rule for"}
,	.{.Text, "every M-configuration will split off the intermediate steps:"}, SCB
,	.{.Rule_Arg, "{q>"}, .{.Rule_Res, "[q>"}, ECB
,	.{.Text, "This convention can also be used to extra clearly denote when the machine has halted:"}, SCB
,	.{.Rule_Arg, "{f> s"}, .{.Rule_Res, "[H> s"}, ECB
,	.{.Line, "`f` here is the final M-configuration that results in halting."}
,	.{.Text, "But we can optionally choose for halting to mean the complete deletion of the readhead:"}, SCB
,	.{.Rule_Arg, "{f> s"}, .{.Rule_Res, "s"}, ECB
,	EML
,	.{.Header4, "2.2.4- Total Amount of Rules and Limits Thereof"}
,	.{.Text, "Let Q be the total amount of M-configurations, and let G be the total"}
,	.{.Line, "amount of symbols in the alphabet (including the 'empty cell' symbol)."}
,	.{.Text, "The given technique requires R amount of rules for such a machine:"}
,	EML
,	.{.Text, "R = 2QG + 2"}
,	EML
,	.{.Text, "This does not count the rules required to split off intermediate sets (as that is"}
,	.{.Text, "more of a debugging feature), but it would add Q amount of rules."}
,	EML
,	.{.Text, "The given value of R is also the minimum amount of Unfurl substitution rules"}
,	.{.Line, "that a transcribed Turing machine can have."}
,	.{.Text, "There are proofs and some arguable exceptions for this, but for now"}
,	.{.Line, "this is presented as fact, with proof by intimidation."}
,	.{.Text, "Feel free to contact me with any questions or objections."}
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
,	.{.Text, "This being said, at some point I would like to make a 'program searcher', that can"}
,	.{.Text, "find rulesets to solve problems on its own."}
,	EML
];
