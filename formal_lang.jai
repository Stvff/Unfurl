Expression :: struct {
	offset: int; /* offset into a token arena */
	count: int;
}

Statement :: struct {
	arg: Expression;
	res: Expression;
}

main :: () {
	code := #string FORMAL_LANG

q + 0 := 1;
q + 1 := 2;
q + 2 := 3;
q + 3 := 0;
0 +   := ;
1 +   := q + ;
2 +   := 1 + q + ;
3 +   := 2 + q + ;
1 + 2:
2 + 3:
2 + 1:

O + := ;
SO - S := O - ;
O - O := O;

SSO + SSSO:
SSO - SO:
SSO - SSSO:

FORMAL_LANG
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
	for queries print("%:\n", to_string(tokens, it));
	print("---------------------\n");

	for query: queries {
		for stage: 1..query.count {
			width := query.count - stage;
			for l: 0..width {
				//print("[% %]", l, stage);
				subex := Expression.{query.offset + l, stage};
				print("% ", to_string(tokens, subex));
				for statements {
					if cmp(tokens, it.arg, subex) print("T ");
				}
			}
			print("\n");
		}
		print("\n");
	}
	print("---------------------\n");

	for query: queries {
		for statement: statements {
			width := statement.arg.count;
			if width <= query.count for l: 0..(query.count-width) {
				subex := Expression.{query.offset + l, width};
				if cmp(tokens, statement.arg, subex) print("% ", to_string(tokens, subex));
			}
		}
		print("\n");
	}

}

cmp :: (arena: []u8, e1: Expression, e2: Expression) -> bool {
	s1 := to_string(arena, e1);
	s2 := to_string(arena, e2);
	return s1 == s2;
}

to_string :: inline (arena: []u8, expression: Expression) -> string {
	s: string;
	s.data = arena.data + expression.offset;
	s.count = expression.count;
	return s;
}

cas :: inline (char: *u8) -> string {
	s: string;
	s.data = char;
	s.count = 1;
	return s;
}

#import "Basic";
