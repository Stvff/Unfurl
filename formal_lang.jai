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
	os_args := get_command_line_arguments();
	os_args.data += 1; os_args.count -= 1;
	code: [..]u8;
	for os_args {
		file, ok := read_entire_file(it);
		if !ok return;
		array_add(*code, .. cast([]u8, file));
	}

	tokens: [..]u8; /* this is the backing character 'arena' */
	statements: [..]Statement;
	queries: [..]Expression;

	{/* first grouping */
		current_statement: Statement;
		on_res, skip_equals := false;
		for code if it > " " {
			if it == {
			case ":";
				if it_index < code.count-2 && code[it_index+1] == "=" {
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
				array_add(*statements, current_statement);
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
	for statements print("% := %;\n", to_string(tokens, it.arg), to_string(tokens, it.res));
//	for queries print("%:\n", to_string(tokens, it));
	print("---------------------\n");

	solutions: [..]Solution;
	for query: queries {
		array_add(*solutions, .{.NEW, query});
		keep_solving := true;
		while keep_solving {
			count_before := solutions.count;
			keep_solving = false;
			for 0..count_before-1 if solutions[it].state == .NEW {
				keep_solving = true;

				produced_results := eval_step(statements, *tokens, solutions[it].expression, *solutions);
				if produced_results solutions[it].state = .ANALYZED;
				else solutions[it].state = .SOLVED;

				// for solutions print("% ", to_string(tokens, it.expression));
				// print("\n");
			}
		}

		print("%: % comparisons, solutions:\n", to_string(tokens, query), cmp_counter);
		cmp_counter = 0;
		for solutions if it.state == .SOLVED print("%\n", to_string(tokens, it.expression));
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
