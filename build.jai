TARGET_PATH  :: "bin";
TARGET_NAME  :: "spaced";
TARGET_CERT  :: "spaced-cert";
TARGET_MAJOR ::  0;
TARGET_MINOR ::  0;
TARGET_PATCH ::  0;
MIN_OS_MAJOR :: 26;
MIN_OS_MINOR ::  0;
BUNDLE_ID    :: #run tprint("com.asmvik.%", TARGET_NAME);
BUNDLE_VS    :: #run tprint("%.%.%", TARGET_MAJOR, TARGET_MINOR, TARGET_PATCH);

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
    create_app_bundle  := false;

    for args {
        if it == "-memory_visualizer" {
            memory_visualizer = true;
            break;
        } else if it == "-memory_leak_report" {
            memory_leak_report = true;
            break;
        } else if it == "-create_app_bundle" {
            create_app_bundle = true;
            break;
        }
    }

    options.output_path = TARGET_PATH;
    options.output_executable_name = TARGET_NAME;
    options.minimum_os_version = .{ MIN_OS_MAJOR, MIN_OS_MINOR };
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

    if create_app_bundle {
        macOS_Bundler :: #import "macOS_Bundler";
        BUNDLE_PATH   :: "bundle";

        delete_directory(BUNDLE_PATH);
        make_directory_if_it_does_not_exist(BUNDLE_PATH);
        set_working_directory(BUNDLE_PATH);

        macOS_Bundler.plist_start(BUNDLE_ID, TARGET_NAME, BUNDLE_VS);
        macOS_Bundler.plist_write_key_value("LSMinimumSystemVersion", tprint("%.%", MIN_OS_MAJOR, MIN_OS_MINOR));
        macOS_Bundler.plist_write_key_value("LSBackgroundOnly", true);
        macOS_Bundler.plist_write_key_value("NSScreenCaptureUsageDescription", "Requires Screen Capture access to display space thumbnails in overview mode.");
        macOS_Bundler.plist_write_key_value("NSHumanReadableCopyright", "Copyright © 2026 Åsmund Vikane. All rights reserved.");
        macOS_Bundler.plist_end();

        macOS_Bundler.create_app_bundle(TARGET_NAME, tprint("../%/%", TARGET_PATH, TARGET_NAME));
        macOS_Bundler.codesign(tprint("%.app", TARGET_NAME), TARGET_CERT);

        macOS_Bundler.create_dmg(TARGET_NAME, tprint("%.app", TARGET_NAME));
        macOS_Bundler.codesign(tprint("%.dmg", TARGET_NAME), TARGET_CERT);
    } else {
        macOS_Bundler :: #import "macOS_Bundler";
        macOS_Bundler.codesign(tprint("%/%", TARGET_PATH, TARGET_NAME), TARGET_CERT);
    }
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
