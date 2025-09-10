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
		HEADER3;
		HEADER4;
	};
	text: string;
}

print_lines_to_terminal :: (lines: []Line) {
	indentation_level := 2;
	for line: lines if #complete line.type == {
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
			print_color("%\n", line.text, color = .HI_YELLOW, .UNDERLINE);
		case .HEADER3;
			print("  ");
			print_color("%\n", line.text, color = .YELLOW, .UNDERLINE);
		case .HEADER4;
			print("   ");
			print_color("%\n", line.text, color = .YELLOW, .UNDERLINE);
	}
}

print_lines_to_markdown :: (sb: *String_Builder, lines: []Line) {
	for line: lines if #complete line.type == {
		case .LINE; print(sb, "%\\\n", line.text);
		case .TEXT; print(sb, "%\n", line.text);
		case .START_CODE_BLOCK; print(sb, "```%\n", line.text);
		case .END_CODE_BLOCK; print(sb, "```\n");
		case .RULE_ARG; print(sb, "% := ", line.text);
		case .RULE_RES; print(sb, "%;\n", line.text);
		case .QUERY; print(sb, "%:\n", line.text);
		case .RESULT_SOLVED; print(sb, "%\n", line.text);
		case .RESULT_INTERM; print(sb, "%, intermediate\n", line.text);
		case .RESULT_SOLVED_VERBOSE; print(sb, "%, solved\n", line.text);
		case .HEADER1; print(sb, "# %\n", line.text);
		case .HEADER2; print(sb, "## %\n", line.text);
		case .HEADER3; print(sb, "### %\n", line.text);
		case .HEADER4; print(sb, "#### %\n", line.text);
	}
}

installation_guide :: Line.[
	.{.HEADER1, "Installation"}
,	.{.TEXT, "Unfurl is just one executable, `unfurl` (`unfurl.exe` on windows)."}
,	.{.LINE, "It can be downloaded [here](https://github.com/Stvff/Unfurl/releases)."}
,	.{.TEXT, "You may need to give it executable permissions on linux:"}, SCB
,	.{.TEXT, "chmod +x ./unfurl"}, ECB
,	.{.TEXT, "After that, and after adding it to your path in some way,"}
,	.{.TEXT, "you can just run the executable in a terminal and it will tell you what to do."}
,	EML
,	.{.TEXT, "The executable contains explainers on every subject, under various `-explain` flags."}
,	.{.TEXT, "The rest of this readme consists of those explainers (generated by unfurl itself!),"}
,	.{.TEXT, "in case you're not near your computer at the moment."}
,	EML
];

#run {
	#import "Compiler";
	options := get_build_options();
	if options.backend != .LLVM return;
	sb: String_Builder;
	print_lines_to_markdown(*sb, installation_guide);
	print_lines_to_markdown(*sb, explanation);
	print_lines_to_markdown(*sb, explain_turing);
	print_lines_to_markdown(*sb, explain_usefulness);
	write_entire_file("readme.md", *sb);
}

#import "Print_Color";
