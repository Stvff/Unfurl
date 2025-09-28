RULE_ARG_COLOR :: Console_Color.HI_GREEN;
RULE_RES_COLOR :: Console_Color.HI_CYAN;
QUERY_COLOR :: Console_Color.HI_RED;
SOL_COLOR_SOLVED :: Console_Color.HI_BLUE;
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
	print_color("%", to_string(tokens, query), color = QUERY_COLOR);
	print_color(":", color = SYNTAX_COLOR);
	if do_newline print("\n");
}

print_solution :: (tokens: []u8, sol: Solution, be_elaborate := false, do_newline := true) {
	if sol.state == .SOLVED {
		print_color("%", to_string(tokens, sol.expression), color = SOL_COLOR_SOLVED);
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
		Line;
		Text;
		Start_Code_Block;
		End_Code_Block;
		Rule_Arg;
		Rule_Res;
		Query;
		Result_Solved;
		Result_Interm;
		Result_Solved_Verbose;
		Header1;
		Header2;
		Header3;
		Header4;
	};
	text: string;
}

print_lines_to_terminal :: (lines: []Line) {
	indentation_level := 2;
	for line: lines if #complete line.type == {
		case .Line;
			for 1..indentation_level print(" ");
			print("%\n", line.text);
		case .Text;
			for 1..indentation_level print(" ");
			print("%\n", line.text);
		case .Start_Code_Block; indentation_level += 4;
		case .End_Code_Block; indentation_level -= 4;
		case .Rule_Arg;
			for 1..indentation_level print(" ");
			print_color("%", line.text, color = RULE_ARG_COLOR);
			print_color(" := ", color = SYNTAX_COLOR);
		case .Rule_Res;
			print_color("%", line.text, color = RULE_RES_COLOR);
			print_color(";\n", color = SYNTAX_COLOR);
		case .Query;
			for 1..indentation_level print(" ");
			print_color("%", line.text, color = QUERY_COLOR);
			print_color(":\n", color = SYNTAX_COLOR);
		case .Result_Solved;
			for 1..indentation_level print(" ");
			print_color("%\n", line.text, color = SOL_COLOR_SOLVED);
		case .Result_Interm;
			for 1..indentation_level print(" ");
			print_color("%", line.text, color = SOL_COLOR_INTERM);
			print(", intermediate\n");
		case .Result_Solved_Verbose;
			for 1..indentation_level print(" ");
			print_color("%", line.text, color = SOL_COLOR_SOLVED);
			print(", solved\n");
		case .Header1;
			print_color("%\n", line.text, color = .HI_YELLOW, .UNDERLINE);
		case .Header2;
			print(" ");
			print_color("%\n", line.text, color = .HI_YELLOW, .UNDERLINE);
		case .Header3;
			print("  ");
			print_color("%\n", line.text, color = .YELLOW, .UNDERLINE);
		case .Header4;
			print("   ");
			print_color("%\n", line.text, color = .YELLOW, .UNDERLINE);
	}
}

print_lines_to_markdown :: (sb: *String_Builder, lines: []Line) {
	for line: lines if #complete line.type == {
		case .Line; print(sb, "%\\\n", line.text);
		case .Text; print(sb, "%\n", line.text);
		case .Start_Code_Block; print(sb, "```%\n", line.text);
		case .End_Code_Block; print(sb, "```\n");
		case .Rule_Arg; print(sb, "% := ", line.text);
		case .Rule_Res; print(sb, "%;\n", line.text);
		case .Query; print(sb, "%:\n", line.text);
		case .Result_Solved; print(sb, "%\n", line.text);
		case .Result_Interm; print(sb, "%, intermediate\n", line.text);
		case .Result_Solved_Verbose; print(sb, "%, solved\n", line.text);
		case .Header1; print(sb, "# %\n", line.text);
		case .Header2; print(sb, "## %\n", line.text);
		case .Header3; print(sb, "### %\n", line.text);
		case .Header4; print(sb, "#### %\n", line.text);
	}
}

installation_guide :: Line.[
	.{.Header1, "Installation"}
,	.{.Text, "Unfurl is just one executable, `unfurl` (`unfurl.exe` on windows)."}
,	.{.Line, "It can be downloaded [here](https://github.com/Stvff/Unfurl/releases/latest)."}
,	.{.Text, "You may need to give it executable permissions on linux:"}, SCB
,	.{.Text, "chmod +x ./unfurl"}, ECB
,	.{.Text, "After that, and after adding it to your `PATH` in some way,"}
,	.{.Text, "you can just run the executable in a terminal and it will tell you what to do."}
,	EML
,	.{.Text, "The executable contains explainers on every subject, under various `-explain` flags."}
,	.{.Text, "The rest of this readme consists of those explainers (generated by unfurl itself!),"}
,	.{.Text, "in case you're not near your computer at the moment."}
,	EML
];

#run {
	#import "Compiler";
	options := get_build_options();
	if !make_readme return; /* this variable is defined in first.jai and added as a build_string at comptime */
	sb: String_Builder;
	print_lines_to_markdown(*sb, installation_guide);
	print_lines_to_markdown(*sb, explanation);
	print_lines_to_markdown(*sb, explain_turing);
	print_lines_to_markdown(*sb, explain_usefulness);
	write_entire_file("readme.md", *sb);
}

#import "Print_Color";
