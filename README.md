## Universal Squirrel Project Template

A universal Squirrel project template for structured scripting

## Requirements

- Python 3

## File Structure

- `build.bat` / `build.sh`: Build entire project
- `vkzlib.config.nut`: configuration file of vkzlib, also serve as project config
- `lib/`: Libraries
    - `vkzlib/`: My library, provides essentials for the project
        - `build.bat` / `build.sh`: Build vkzlib
        - `build.py`: Python script used to build
        - `setup.build.json`: Build configuration for module setup scripts
        - `vkzlib.build.json`: Build configuration for vkzlib
        - `module/`: Scripts related to module system
        - `setup/`: Module setup scripts
- `<project_name>/`: Main project directory
    - `build.bat` / `build.sh`: Build project
    - `*.build.json`: Build configurations for project

## File Naming Convention

- `.in.nut`: Script that requires a build to become a `.nut` with same name
- `.entry.nut`: Script designed to be run directly
- `.test.nut`: Script contains tests, can be run directly
- `.setup.nut`: Setup script that will be prepend to other scripts

## vkzlib Configuration

```squirrel
/**
 * @desc Configuration
 *
 * You can modify this variable in `vkzlib.config.nut`
 * e.g. ::VKZLIB_CONFIG.DEBUG = true
 */
::VKZLIB_CONFIG <- {

    /**
     * @desc Path to library storage
     * @type {string}
     */
    LIB_DIR = "lib/",

    /**
     * @desc Path to vkzlib
     *
     * Defaults to `LIB_DIR + "vkzlib/"`
     */
    VKZLIB_DIR = null,

    /**
     * @desc Main project directory
     * @type {string}
     *
     * Used for setting default `require` path
     */
    PROJECT_DIR = "",

    /**
     * @desc Debug flag
     * @type {bool}
     *
     * Enable this should print additional messages for debugging
     */
    DEBUG = false,

    /**
     * @desc A function runs after setup script executed
     * @type {() => void}
     */
    ON_LOADED = null,

}
```

## Build script

Run `build.py` with no argument

```shell
python lib/vkzlib/build.py
```

will print help message

```txt
Usage: python build.py <config_path>

Configuration is a json file with following properties:

    root: string
    Path to the root directory for scanning, e.g. ".", "src/"

    setup: string
    Path to setup script, e.g. "setup/minimal.setup.nut", "../lib/vkzlib/setup/full.setup.nut"

    exclude?: string[]
    A list of path to exclude from scanning, e.g. ["setup/", "src/exclude.in.nut"]

    target_suffix?: string
    suffix of input files to be processed
    Defaults to ".in.nut"

    output_suffix?: string
    suffix of output files
    Defaults to ".nut"
    
! All path are relative to the directory of build configuration file
```

## Compatibility Notice

You can create scripts that can be run in both squirrel interpreter and Source games with VScript implementation for squirrel. However, if you have VScript-specific codes in your script, it can't be run with squirrel interpreter. Conversely, if you used Squirrel things disabled by VScript, it can't be run inside Source games.

So I created `vkzlib.compat` module that contains a collection of functions and classes from specific environment, but can be used in any supported environment.

If you only want to create scripts for specific environment, say, VScript, you can use VScript project template instead. One advantage is that you don't need to build your code in order to use the module system. Instead, you can just write `IncludeScript("lib/vkzlib/setup/full.setup.nut")` at the top of your scripts and you are good to go.

## Guide

### Using Module System

I've written a simple module system similar to `Lua`'s. You can utilize it to organize your code.

Module is basically a table with the item exported. For example, if you want to export something, say, `add` in a file, you can use `export`:

```squirrel
// MyProject/math.in.nut
local function add(a, b) {
    return a + b
}

// Recommended way to export a module
return export({
    // Export local function `add`
    add = add,
    // Export same `add` with the name `add2`
    add2 = add,
})
```

For pure squirrel, you can just return a table. But, it won't work if you are writing VScript. In contrast, `export` works for both.

Note that all scripts uses module system should have the suffix `.in.nut`. Those files needs to be built to a `.nut` before they can be run.

Import the module with `require` so that you can use the items it exported:

```squirrel
// MyProject/main.entry.in.nut

// Import from project
local math = require("math.nut")

print("2 + 3 = " + math.add(2, 3)) // 5
print("4 + 2 = " + math.add2(4, 2)) // 6

// Import from vkzlib
local inspect = require.vkzlib("utils/inspect.nut").inspect

print(inspect({ x = 114, y = 5.14 }))
/*
 * {
 *    "x": 114,
 *    "y": 5.14,
 * }
 */
```

### Configure vkzlib

In order to make `require` relative to your project directory, create a file named `vkzlib.config.nut` in root with `PROJECT_DIR` set. For example:

```squirrel
// The trailing `/` is necessary
::VKZLIB_CONFIG.PROJECT_DIR = "MyProject/"
```

For other properties, see [vkzlib Configuration](#vkzlib-configuration).

### Build

Run `build.bat` or `build.sh` in project directory based on your OS. This will build all `.in.nut` to `.nut`. You build again after editing `.in.nut` files to get update-to-date `.nut` file.

To understand how to use `build.py` to build your files, see [Build Script](#build-script).

### Run with Squirrel Interpreter

Get a copy of Squirrel interpreter `sq`, make sure it is on `PATH`.

Open a shell and `cd` to this (root) directory.

You can run files with suffix `.entry.nut`.

To run `project/main.entry.nut`:

```shell
sq project/main.entry.nut
```

To run tests, for example, `project/plant/test/testPlant.entry.nut`:

```shell
sq project/plant/test/testPlant.entry.nut
```

### Run as VScript

Tested on Mapbase 8.0.

Load a map and open the console, execute:

```shell
script_execute "project/main.entry.nut"
```

As you can see, just replace `sq` with `script_execute` and it'll works.

TODO: Add steps for other methods like Hammer Inputs.

### Advanced

#### If you don't want to build

At the moment, build only prepend setup script to input files. If you don't want to build, you can simply create an empty `.in.nut` file, prepend setup script manually, then write your code below. Remember to delete `.in.nut` to avoid unintentional overwrites.

I recommended also adding seperators to setup script similar to build script. The benefit is, you can just delete setup script and make the file a `.in.nut` if you want to build. Or if you want to update setup script, just replace the outdated setup scripts with the update-to-date ones.
