create_app_bundle :: (app_name: string, app_exe_path: string, resource_directory_to_copy := "") -> app_bundle_dir: string, resources_path: string {
    app_bundle_name := tprint("%.app", app_name);
    macos_path, resources_path, contents_path := make_app_bundle_subdirectories(app_bundle_name);

    if resource_directory_to_copy {
        source_folder_name := basename(resource_directory_to_copy);
        resource_output_path := tprint("%/%", resources_path, source_folder_name);
        make_directory_if_it_does_not_exist(resource_output_path);
        copy_files_recursively(resource_directory_to_copy, resource_output_path);
    }

    bundle_exe_path := tprint("%/%", macos_path, app_name);
    copy_file(app_exe_path, bundle_exe_path);
    chmod(temp_c_string(bundle_exe_path), 0x1FF);

    info_plist := builder_to_string(*plist_sb);
    if info_plist {
        bundle_info_plist_path := tprint("%/Info.plist", contents_path);
        write_entire_file(bundle_info_plist_path, info_plist);
    }

    return app_bundle_name, resources_path;
}

create_dmg :: (dmg_name: string, app_path: string) -> bool {
    DMG_PATH :: "./dmg_contents";
    DMG_APP  := tprint("%/%.app", DMG_PATH, dmg_name);
    DMG_EXE  := tprint("%/Contents/MacOS/%", DMG_APP, dmg_name);
    make_directory_if_it_does_not_exist(DMG_APP, recursive=true);
    copy_files_recursively(app_path, DMG_APP);
    chmod(temp_c_string(DMG_EXE), 0x1FF);
    symlink("/Applications", temp_c_string(tprint("%/%", DMG_PATH, "Applications")));
    process_result, output, error := run_command("hdiutil", "create", "-volname", dmg_name, "-srcfolder", DMG_PATH, tprint("%.dmg", dmg_name));
    delete_directory(DMG_PATH);
    return process_result.exit_code == 0;
}

codesign :: (name: string, certificate_name := "-") -> bool {
    process_result, output, error := run_command("codesign", "--force", "--options", "runtime", "--timestamp", "--sign", certificate_name, name);
    return process_result.exit_code == 0;
}

plist_start :: (app_identifier: string, app_name: string, app_version: string) {
    append(*plist_sb, tprint(PLIST_HEADER, app_identifier, app_name, app_version));
}

plist_write_key_value :: (key: string, value: Any) {
    plist_write_key(key);

    if value.type.type == Type_Info_Tag.BOOL {
        plist_write_bool((.*) cast(*bool) value.value_pointer);
    } else if value.type.type == Type_Info_Tag.STRING {
        plist_write_string((.*) cast(*string) value.value_pointer);
    }
}

plist_end :: () {
    append(*plist_sb, PLIST_FOOTER);
}

#scope_file

make_app_bundle_subdirectories :: (app_bundle_name: string) -> macos_folder_path: string, resources_path: string, contents_path: string {
    contents_path  := tprint("%/Contents", app_bundle_name);
    resources_path := tprint("%/Resources", contents_path);
    macos_path     := tprint("%/MacOS", contents_path);

    make_directory_if_it_does_not_exist(app_bundle_name);
    make_directory_if_it_does_not_exist(contents_path);
    make_directory_if_it_does_not_exist(macos_path);
    make_directory_if_it_does_not_exist(resources_path);

    return macos_path, resources_path, contents_path;
}

copy_files_recursively :: (source: string, dest: string) {
    paths: [2] string;
    paths[0] = source;
    paths[1] = dest;

    visitor :: (info: *File_Visit_Info, paths: [2] string) {
        relative_path := info.full_name;
        advance(*relative_path, paths[0].count);
        out_path := join(paths[1], "/", relative_path);
        make_directory_if_it_does_not_exist(path_strip_filename(out_path), recursive = true);
        copy_file(info.full_name, out_path);
    }

    res := visit_files(paths[0], true, paths, visitor);
    assert(res);
}

convert_image_to_icns :: (input_path: string, output_path: string) -> bool {
    process_result, output, error := run_command("sips", "-s", "format", "icns", input_path, "--out", output_path);
    return process_result.exit_code == 0;
}

plist_write_key :: (key: string) {
    for 0..plist_depth append(*plist_sb, "    ");
    append(*plist_sb, "<key>");
    append(*plist_sb, key);
    append(*plist_sb, "</key>\n");
}

plist_write_string :: (str: string) {
    for 0..plist_depth append(*plist_sb, "    ");
    append(*plist_sb, "<string>");
    append(*plist_sb, str);
    append(*plist_sb, "</string>\n");
}

plist_write_bool :: (value: bool) {
    for 0..plist_depth append(*plist_sb, "    ");
    print_to_builder(*plist_sb, "<%/>\n", value);
}

plist_sb: String_Builder;
plist_depth := 0;

PLIST_HEADER :: #string DONE
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>%1</string>
    <key>CFBundleName</key>
    <string>%2</string>
    <key>CFBundleExecutable</key>
    <string>%2</string>
    <key>CFBundleVersion</key>
    <string>%3</string>
    <key>CFBundleShortVersionString</key>
    <string>%3</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
DONE

PLIST_FOOTER :: #string DONE
</dict>
</plist>
DONE

#import "Basic";
#import "Process";
#import "File";
#import "File_Utilities";
#import "String";
#import "POSIX";
