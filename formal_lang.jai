Expression_Index :: int;

Token :: struct {
	type: enum {OPERATOR; SET; EXPRESSION; NAME;};
	content: union {
		op: enum {COMMA; EQUALS;};
		set: [4]u64;
		expression: Expression_Index;
	};
	name: string;
}

Statement :: struct {
	arg: Expression_Index;
	res: Expression_Index;
}

tokenize :: (token_arena: *[..]Token, expression_arena: [..][]Token, code: string, is_res: bool) -> (expression_index: Expression_Index, parsed_token_amount: int) {
	expr: [..]Token;
	expr.allocator = temp;

	name_prev_token := false;
	index := 0;
	while true {
		if index > code.count-1 break;
		char := code[index];
		fp: string;
		fp.data = code.data + index;
		fp.count = 1;
		print("%\n", fp);
		if char == {
		case "(";
			new_code := code;
			new_code.data += index + 1;
			new_code.count -= index + 1;
			index_of_that, amount_parsed := tokenize(token_arena, expression_arena, new_code, is_res);
			index += amount_parsed;

			token := Token.{
				type = .EXPRESSION,
				content.expression = index_of_that,
			};
			array_add(*expr, token);
		case ")";
			index_of_this := token_arena.count;
			array_add(token_arena, ..expr);
			expression: []Token;
			expression.data = token_arena.data + index_of_this;
			return index_of_this, index;
		case "=";
			token := Token.{
				type = .OPERATOR,
				content.op = .EQUALS,
			};
			array_add(*expr, token);
		case ",";
			token := Token.{
				type = .OPERATOR,
				content.op = .COMMA,
			};
			array_add(*expr, token);
		case "_";
			if is_res {
				token := Token.{type = .NAME};
				array_add(*expr, token);
			}
			name_prev_token = true;
		case;
			if name_prev_token {
				expr[expr.count-1].name.data = code.data + index;
				expr[expr.count-1].name.count = 1;
			} else {
				stage_1 := char / 64;
				stage_2 := char % 64;
				set: [4]u64;
				set[stage_1] = cast(u64, 1 << stage_2);
				token := Token.{
					type = .SET,
					content.set = set,
				};
				array_add(*expr, token);
			}
		}
		index += 1;
	}
	index_of_this := token_arena.count;
	array_add(token_arena, ..expr);
	return index_of_this, index;
}

Code_Statement :: struct {
	arg, res: string;
}

main :: () {
	code := #string FORMAL_LANG

q       := 0, 1, 2, 3;
1 + 1   := 2;
1 + 2   := 3;
1 + 3   := 0;
0 + q_r := _r;
2 + q_r := 1 + (1 + _r);
3 + q_r := 1 + (2 + _r);
(1 + 2), (2 + 3):

p := 3, 4, 5, 6;
# (q = p)_n := 1 + _n;
v := 3;
# v:
0 1, 2 = 3, 4 5:
0 ((1, 2) = (3, 4)) 5:

FORMAL_LANG
	condensed_code: [..]u8; /* this is the backing character 'arena' */
	code_statements: [..]Code_Statement;
	code_queries: [..]string;

	{/* first grouping */
		raw_statements: [..][2][2]int;
		raw_queries: [..][2]int;
		defer array_reset(*raw_statements);
		defer array_reset(*raw_queries);

		arg_or_res := 0;
		current_statement: [2][2]int;
		skip_equals := false;
		for code if it > " " {
			if it == {
			case ":";
				if it_index < code.count-2 && code[it_index+1] == "=" {
					skip_equals = true;
					arg_or_res = 1;
					current_statement[1][0] = condensed_code.count;
					current_statement[1][1] = 0;
				} else {
					array_add(*raw_queries, current_statement[0]);
					arg_or_res = 0;
					current_statement[0][0] = condensed_code.count;
					current_statement[0][1] = 0;
				}
			case ";";
				array_add(*raw_statements, current_statement);
				arg_or_res = 0;
				current_statement[0][0] = condensed_code.count;
				current_statement[0][1] = 0;
			case;
				if skip_equals {
					skip_equals = false;
					continue;
				}
				array_add(*condensed_code, it);
				current_statement[arg_or_res][1] += 1;
			}
		}

		for raw_statements {
			cs: Code_Statement;
			cs.arg.data, cs.res.data = condensed_code.data;
			cs.arg.data += it[0][0];
			cs.arg.count = it[0][1];
			cs.res.data += it[1][0];
			cs.res.count = it[1][1];
			array_add(*code_statements, cs);
		}
		for raw_queries {
			q: string;
			q.data = condensed_code.data + it[0];
			q.count = it[1];
			array_add(*code_queries, q);
		}

	}
	for code_statements print("% := %;\n", it.arg, it.res);
	for code_queries print("%:\n", it);

	tokens: [..]Token;
	expressions: [..][]Token;
	statements: [..]Statement;
	for code_statements {
		statement: Statement;
		statement.res = tokenize(*tokens, it.res, true);
		statement.arg = tokenize(*tokens, it.arg, false);
		array_add(*statements, statement);
		reset_temporary_storage();
	}

	for code_statements {
		print_expression(tokens
	}
	print("%\n", tokens);
}

#import "Basic";
/*
------ First steps ---------
q       := 0, 1, 2, 3;
1 + 1   := 2;
1 + 2   := 3;
1 + 3   := 0;
0 + q_r := _r;
2 + q_r := 1 + (1 + _r);
3 + q_r := 1 + (2 + _r);
(1 + 2), (2 + 3):

------ Secondly ---------
p := 3, 4, 5, 6;
# (q = p)_n := 1 + _n;
v := 3;
# v:

*/
