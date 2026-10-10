TARGET_PATH :: "bin";
TARGET_NAME :: "spaced";

#run,stallable build();

build :: () {
    w := compiler_create_workspace();
    args := get_build_options().compile_time_command_line;
    options := get_build_options(w);
    copy_commonly_propagated_fields(get_build_options(), *options);

    success, plugins_to_create := parse_plugin_arguments(args);
    if !success {
        log_error("Failed to parse plugin arguments.\n");
        exit(1);
    }

    success = init_plugins(plugins_to_create, *plugins, w);
    if !success {
        log_error("A plugin init() failed. Exiting.\n");
        exit(0);
    }

    memory_visualizer  := false;
    memory_leak_report := false;

    for args {
        if it == "-memory_visualizer" {
            memory_visualizer = true;
            break;
        } else if it == "-memory_leak_report" {
            memory_leak_report = true;
            break;
        }
    }

    options.output_path = TARGET_PATH;
    options.output_executable_name = TARGET_NAME;
    options.cpu_target = .ARM64;

    set_working_directory(#filepath);
    make_directory_if_it_does_not_exist(TARGET_PATH);
    set_build_options(options, w);
    set_build_options_dc(.{do_output=false});

    intercept_flags: Intercept_Flags;
    for plugins if it.before_intercept then it.before_intercept(it, *intercept_flags);

    compiler_begin_intercept(w, intercept_flags);

    for plugins if it.add_source then it.add_source(it);

    add_build_string(tprint("MEMORY_VISUALIZER  :: %;\n", memory_visualizer),  w);
    add_build_string(tprint("MEMORY_LEAK_REPORT :: %;\n", memory_leak_report), w);
    add_build_file("src/main.jai", w);

    message_loop(w);

    compiler_end_intercept(w);

    for plugins if it.finish   then it.finish  (it);
    for plugins if it.shutdown then it.shutdown(it);
}

message_loop :: (w: Workspace) {
    while true {
        message := compiler_wait_for_message();

        for plugins if it.message it.message(it, message);

        if message.kind == .COMPLETE break;
    }
}

plugins: [..] *Metaprogram_Plugin;

#import "Basic";
#import "Compiler";
#import "Metaprogram_Plugins";
#import "File";
