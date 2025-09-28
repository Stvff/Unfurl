release :: true;
make_readme :: release || true;

#run {
	defer set_build_options_dc(.{do_output = false});

	w := compiler_create_workspace("Unfurl");
	options := get_build_options();
	options.output_executable_name = "unfurl";
	if release {
		options.backend = .LLVM;
		set_optimization(*options, .VERY_OPTIMIZED);
	}

	/* this does not work */
	if array_find(options.compile_time_command_line, "-arm64") {
		options.output_executable_name = "unfurl-arm64";
		options.backend = .LLVM;
		options.cpu_target = .ARM64;
		options.llvm_options.target_system_triple = "aarch64-linux-gnu";
		options.use_custom_link_command = true;
		print("Compiling for ARM64\n");
	}

	set_build_options(options, w);
	add_build_string(tprint("make_readme :: %;", make_readme), w);
	add_build_file("unfurl.jai", w);
}

#import "Compiler";
#import "Basic";
