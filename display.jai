RULE_ARG_COLOR :: Console_Color.GREEN;
RULE_RES_COLOR :: Console_Color.HI_CYAN;
QUERY_COLOR :: Console_Color.BLUE;
SOL_COLOR_SOLVED :: Console_Color.HI_GREEN;
SOL_COLOR_INTERM :: Console_Color.RED;

SYNTAX_COLOR :: Console_Color.MAGENTA;

print_statement :: (tokens: []u8, statement: Statement, do_newline := true) {
	print_color("%", to_string(tokens, statement.arg), color = RULE_ARG_COLOR);
	print_color(" := ", color = SYNTAX_COLOR);
	print_color("%", to_string(tokens, statement.res), color = RULE_RES_COLOR);
	print_color(";", color = SYNTAX_COLOR);
	if do_newline print("\n");
}

print_query :: (tokens: []u8, query: Expression, do_newline := true) {
	print_color("%", to_string(tokens, query), color = SOL_COLOR_SOLVED);
	print_color(":", color = SYNTAX_COLOR);
	if do_newline print("\n");
}

print_solution :: (tokens: []u8, sol: Solution, be_elaborate := false, do_newline := true) {
	if sol.state == .SOLVED {
		print_color("%", to_string(tokens, sol.expression), color = QUERY_COLOR);
		if be_elaborate print(", %", ifx sol.state == .SOLVED then "solved" else "intermediate");
		if do_newline print("\n");
	} else if be_elaborate {
		print_color("%", to_string(tokens, sol.expression), color = SOL_COLOR_INTERM);
		print(", %", ifx sol.state == .SOLVED then "solved" else "intermediate");
		if do_newline print("\n");
	}
}

print_problem :: (tokens: []u8, problem: Res_Set, do_newline := true) {
	print_color("%", to_string(tokens, problem.arg), color = SOL_COLOR_SOLVED);
	print_color(" :: ", color = SYNTAX_COLOR);
	for sol: problem.sols {
		print_color("%", to_string(tokens, sol), color = QUERY_COLOR);
		if it_index < problem.sols.count-1 print_color(", ", color = SYNTAX_COLOR);
	}
	print_color(";", color = SYNTAX_COLOR);
	if do_newline print("\n");
}

Line :: struct {
	type: enum {
		LINE;
		TEXT;
		START_CODE_BLOCK;
		END_CODE_BLOCK;
		RULE_ARG;
		RULE_RES;
		QUERY;
		RESULT_SOLVED;
		RESULT_INTERM;
		RESULT_SOLVED_VERBOSE;
		HEADER1;
		HEADER2;
	};
	text: string;
}

print_lines_to_terminal :: (lines: []Line) {
	indentation_level := 2;
	for line: lines {
		if #complete line.type == {
		case .LINE;
			for 1..indentation_level print(" ");
			print("%\n", line.text);
		case .TEXT;
			for 1..indentation_level print(" ");
			print("%\n", line.text);
		case .START_CODE_BLOCK; indentation_level += 4;
		case .END_CODE_BLOCK; indentation_level -= 4;
		case .RULE_ARG;
			for 1..indentation_level print(" ");
			print_color("%", line.text, color = RULE_ARG_COLOR);
			print_color(" := ", color = SYNTAX_COLOR);
		case .RULE_RES;
			print_color("%", line.text, color = RULE_RES_COLOR);
			print_color(";\n", color = SYNTAX_COLOR);
		case .QUERY;
			for 1..indentation_level print(" ");
			print_color("%", line.text, color = QUERY_COLOR);
			print_color(":\n", color = SYNTAX_COLOR);
		case .RESULT_SOLVED;
			for 1..indentation_level print(" ");
			print_color("%\n", line.text, color = SOL_COLOR_SOLVED);
		case .RESULT_INTERM;
			for 1..indentation_level print(" ");
			print_color("%", line.text, color = SOL_COLOR_INTERM);
			print(", intermediate\n");
		case .RESULT_SOLVED_VERBOSE;
			for 1..indentation_level print(" ");
			print_color("%", line.text, color = SOL_COLOR_SOLVED);
			print(", solved\n");
		case .HEADER1;
			print_color("%\n", line.text, color = .HI_YELLOW, .UNDERLINE);
		case .HEADER2;
			print(" ");
			print_color("%\n", line.text, color = .YELLOW, .UNDERLINE);
		}
	}
}

#import "Print_Color";
