help_message :: #string END_STRING
This is the Unfurl evaluator.
Usage:
    $ unfurl [options] <files/ending/in.furl>;

Possible options:
    -all-states
        Makes the evaluator print out all explored intermediate states.

    -only-solutions
        Reduces the output so that it does not print the given rules,
        queries, or any stats.

    -explain
        Prints an explanation of Unfurl (and its evaluator).

For any problems or questions, visit the github (https://github.com/Stvff/Unfurl)
or vstvff@gmail.com.

END_STRING

Expression :: struct {
	offset: int; /* offset into a token arena */
	count: int;
}

Statement :: struct {
	arg: Expression;
	res: Expression;
}

Solution :: struct {
	state: enum {NEW; ANALYZED; SOLVED; };
	expression: Expression;
}

main :: () {
	print_all_intermediate_states := false;
	quiet_down := false;

	os_args := get_command_line_arguments();
	// os_args: []string = .["unfurl", "rule110.furl"];
	os_args.data += 1; os_args.count -= 1;
	ascii_files, nfurl_files, xfurl_files: [..]u8;
	nfurl_query_files: [..]u8;
	xfurl_query_files: [..]u64;
	if !os_args {
		print("%", help_message);
		return;
	} else for os_args {
		if it[0] == "-" {
			arg := it;
			arg.data += 1; arg.count -= 1;
			if arg == "all-states" print_all_intermediate_states = true;
			else if arg == "only-solutions" quiet_down = true;
			else if arg == "explain" {
				print("%", explanation_message);
				return;
			} else {
				print("%", help_message);
				return;
			}
			continue;
		}
		file, ok := read_entire_file(it);
		if !ok return;
		array_add(*ascii_files, .. cast([]u8, file));
	}

	tokens: [..]u8; /* this is the backing character 'arena' */
	statements: [..]Statement;
	queries: [..]Expression;

	{/* first grouping */
		current_statement: Statement;
		on_res, skip_equals := false;
		in_comment := 0;
		for ascii_files if it > " " {
			if in_comment > 0 {
				if it == {
				case "("; in_comment += 1;
				case ")"; in_comment -= 1;
				}
				continue;
			}
			if it == {
			case "("; in_comment += 1;
			case ":";
				if it_index < ascii_files.count-2 && ascii_files[it_index+1] == "=" {
					skip_equals = true;
					on_res = true;
					current_statement.res.offset = tokens.count;
					current_statement.res.count = 0;
				} else {
					array_add(*queries, current_statement.arg);
					on_res = false;
					current_statement.arg.offset = tokens.count;
					current_statement.arg.count = 0;
				}
			case ";";
				if current_statement.arg.count array_add(*statements, current_statement);
				on_res = false;
				current_statement.arg.offset = tokens.count;
				current_statement.arg.count = 0;
			case;
				if skip_equals {
					skip_equals = false;
					continue;
				}
				array_add(*tokens, it);
				if on_res current_statement.res.count += 1;
				else current_statement.arg.count += 1;
			}
		}
	}

	if !quiet_down {
		print("---------------- Given Rules ----------------\n");
		for statements print("% := %;\n", to_string(tokens, it.arg), to_string(tokens, it.res));
		print("------------ Queries and results ------------\n");
	}

	solutions: [..]Solution;
	for query: queries {
		array_add(*solutions, .{.NEW, query});
		keep_solving := true;
		while keep_solving {
			count_before := solutions.count;
			keep_solving = false;
			for 0..count_before-1 if solutions[it].state == .NEW {
				keep_solving = true;

				/* This is a seperate definition, because if you put it as function argument,
				   it never dereferences it from the solutions array, and keeps it as a pointer,
				   which is eventually invalidated by the solutions array re-allocating.
				   I don't know if this is an intended effect of read-only function arguments,
				   but it comes across as a codegen bug to me. It happens in bytecode, x64 and llvm. */
				expression_to_eval := solutions[it].expression;
				produced_results := eval_step(statements, *tokens, expression_to_eval, *solutions);
				if produced_results solutions[it].state = .ANALYZED;
				else solutions[it].state = .SOLVED;
			}
		}

		if !quiet_down print("%: % comparisons, % explored states, solutions:\n", to_string(tokens, query), cmp_counter, solutions.count);
		cmp_counter = 0;
		if print_all_intermediate_states for solutions print("%, state: %\n", to_string(tokens, it.expression), it.state);
		else for solutions if it.state == .SOLVED print("%\n", to_string(tokens, it.expression));
		array_reset(*solutions);
		print("\n");
	}
}

eval_step :: (statements: []Statement, arena: *[..]u8, query: Expression, solutions: *[..]Solution) -> bool {
	something_found := false;
	for statement: statements {
		width := statement.arg.count;
		if width <= query.count for l: 0..(query.count-width) {
			subex := Expression.{query.offset + l, width};
			if cmp(arena.*, statement.arg, subex) {
				before := Expression.{query.offset, l};
				after := Expression.{query.offset + l + width, max(0, query.count - (l+width))};

				start_of_result := arena.count;
				/* this can probably be sped up with an array resize and three copies) */
				array_reserve(arena, arena.count + before.count + statement.res.count + after.count);
				array_add(arena, ..to_array(arena.*, before));
				array_add(arena, ..to_array(arena.*, statement.res));
				array_add(arena, ..to_array(arena.*, after));

				result := Solution.{.NEW, Expression.{start_of_result, arena.count-start_of_result}};
				exist := false;
				something_found = true;
				for solutions.* if cmp(arena.*, it.expression, result.expression) {
					exist = true;
					break;
				}
//				print("%, %: %, %\n", to_string(arena.*, query), to_string(arena.*, statement.arg), to_string(arena.*, statement.res), to_string(arena.*, result.expression));
				if !exist array_add(solutions, result);
				else arena.count -= result.expression.count;
			}
		}
	}
	return something_found;
}

cmp_counter := 0;

cmp :: (arena: []u8, e1: Expression, e2: Expression) -> bool {
	s1 := to_string(arena, e1);
	s2 := to_string(arena, e2);
	cmp_counter += 1;
	return s1 == s2;
}

to_string :: inline (arena: []u8, expression: Expression) -> string {
	s: string;
	s.data = arena.data + expression.offset;
	s.count = expression.count;
	return s;
}

to_array :: inline (arena: []u8, expression: Expression) -> []u8 {
	a: []u8;
	a.data = arena.data + expression.offset;
	a.count = expression.count;
	return a;
}

cas :: inline (char: *u8) -> string {
	s: string;
	s.data = char;
	s.count = 1;
	return s;
}

#import "Basic";
#import "File";

explanation_message :: #string MARKDOWN
# Explanation
  Unfurl is really nothing more than an elaborate substitution machine.
  You input rules:
      a := b;
  And queries:
      bbb:
  And the evaluator applies the rule to the queries:
      aaa

  Interestingly enough, there is an enormous wealth of complexity that can be extracted
  from this simple paradigm.
  For example, some rules and inputs have multiple different combinations. The evaluator
  always evaluates every single possible combination.
  As an example:
      aa := b;
      aaa:
  Has two possible solutions:
      ba
      ab
  A more elaborate example:
      aa := u;
      aa := v;
      aaa:
  Results in four possible solutions:
      ua
      au
      va
      av

  The evaluation continues applying rules until no more rules can be applied. This has
  two implications:
  1) Infinite evaluation is possible (for example (n := nn; n:))
  2) The rules are applied to 'intermediate' results. This is where most of the real
   useful complexity of Unfurl comes from.
  As a basic example:
      N0 := 1;
      N1 := 2;
      N2 := 3;
      NN0:
  Results in:
      3
  When running the evaluator with -all-states, you can see all the intermediate steps.
      NNN0, state: ANALYZED
      NN1, state: ANALYZED
      N2, state: ANALYZED
      3, state: SOLVED

## Writing .furl files (aka my parser is not so smart so don't shake it too much it'll throw up)
  The only valid input is ascii.
  All whitespace is ignored and removed (so spaces will not show up in rules, queries, or solutions).
  Comments can be placed between parentheses (like so (also they can nest)).
  When calling the evaluator on multiple files at once, all their rules and queries are combined into
  one larger evaluation pool.

## What is this good for?
  I wanted to make a really simple language that I could practice non-trivial multithreading on.
  Unfurl is actually turing complete as well, so at some point I want to make a 'program searcher'
  for it, which is a type of symbolic artificial intelligence.

MARKDOWN
