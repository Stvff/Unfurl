// statements: [..]Statement;
// expression_arena: [..][]Token;
// token_arena: [..]Token;

// Token :: struct {
// 	type: enum {OPERATOR; SUMSET; EXPRESSION;};
// 	content: union {
// 		op: enum {COMMA, EQUALS};
// 		set: u64;
// 		expression: int;
// 	};
// }

// Statement :: struct {
// 	arg: int;
// 	res: int;
// }

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

FORMAL_LANG
	condensed_code: [..]u8;
	raw_statements: [..][2][2]int;
	raw_queries: [..][2]int;

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

	code_statements: [..]Code_Statement;
	for raw_statements {
		cs: Code_Statement;
		cs.arg.data, cs.res.data = condensed_code.data;
		cs.arg.data += it[0][0];
		cs.arg.count = it[0][1];
		cs.res.data += it[1][0];
		cs.res.count = it[1][1];
		array_add(*code_statements, cs);
	}
	code_queries: [..]string;
	for raw_queries {
		q: string;
		q.data = condensed_code.data + it[0];
		q.count = it[1];
		array_add(*code_queries, q);
	}

	for code_statements {
		print("% := %;\n", it.arg, it.res);
	}
	for code_queries {
		print("%:\n", it);
	}
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
