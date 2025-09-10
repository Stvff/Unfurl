
print_statement :: (tokens: []u8, statement: Statement, do_newline := true) {
	print_color("%", to_string(tokens, statement.arg), color = .GREEN);
	print_color(" := ", color = .MAGENTA);
	print_color("%", to_string(tokens, statement.res), color = .HI_CYAN);
	print_color(";", color = .MAGENTA);
	if do_newline print("\n");
}

print_query :: (tokens: []u8, query: Expression, do_newline := true) {
	print_color("%", to_string(tokens, query), color = .HI_GREEN);
	print_color(":", color = .MAGENTA);
	if do_newline print("\n");
}

print_solution :: (tokens: []u8, sol: Solution, be_elaborate := false, do_newline := true) {
	if sol.state == .SOLVED {
		print_color("%", to_string(tokens, sol.expression), color = .BLUE);
		if be_elaborate print(", %", ifx sol.state == .SOLVED then "solved" else "intermediate");
		if do_newline print("\n");
	} else if be_elaborate {
		print_color("%", to_string(tokens, sol.expression), color = .RED);
		print(", %", ifx sol.state == .SOLVED then "solved" else "intermediate");
		if do_newline print("\n");
	}
}

print_problem :: (tokens: []u8, problem: Res_Set, do_newline := true) {
	print_color("%", to_string(tokens, problem.arg), color = .HI_GREEN);
	print_color(" :: ", color = .MAGENTA);
	for sol: problem.sols {
		print_color("%", to_string(tokens, sol), color = .BLUE);
		if it_index < problem.sols.count-1 print_color(", ", color = .MAGENTA);
	}
	print_color(";", color = .MAGENTA);
	if do_newline print("\n");
}

#import "Print_Color";
