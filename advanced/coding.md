---
parent: Advanced topics
---

# Coding

## Documentation
Man pages for ltsp tools are maintained in markdown format in `$SRC/man. The go-md2man tool is used at build time to convert them to man format.

The short usage, `$TOOL --help`, comes from `man $TOOL | extract_usage` or something similar; if we assume that man isn't available at run time, then we can also do that at build time.

## PEP8
Since shell doesn't have something like PEP8, let's apply whatever makes sense from PEP8. For example, 4 spaces indentation.

TODO: heredocs <<\- use tabs, and also see: https://www.kernel.org/doc/html/v4.10/process/coding-style.html#indentation.

Other remarks:
* Don't use periods for single sentence comments or commit messages. Do use periods for multiple sentences. Start with a capital letter. It's like chatting on IRC.

## Symlinks
If possible, put everything in /usr/share/ltsp and symlink binaries etc to appropriate places in FHS.

## Shell script coding
Shell scripts should be able to run on `bash`, `dash`, and `busybox ash`, and they should produce no output when checked with [shellcheck](https://www.shellcheck.net/) like `shellcheck -e SC2039 script.sh`. Occasionally, [checkbashisms](https://manpages.ubuntu.com/checkbashisms) can also be used, but ignore its warnings about "local" and "command -v"; we want these.

### Shell script extensions
Use the .sh extension for all shell scripts. Symlink the *public* binaries in /usr/[s]bin without extensions.

### Variable case and visibility
Almost all the code should be inside functions. Most of the variables should be local and lowercase. Global variables that can be defined in the command line or in configuration files should be UPPERCASE, while global variables for internal use should start with an _UNDERSCORE. When subprocesses are spawned, make sure they only have the environment variables they need.

### Functions
Applets start with a_cmdline (applet command line) and a_name_main (applet "name" main) functions for readability. The rest of the functions should be alphabetically sorted. Complex functions should be preceded by a comment.

### Script directories
Most scripts are organized in directories, and numbered as follows:
* [0-9][09]|[09][0-9]: site and local admins
* [1-8][18]|[18][1-8]: distributions, their derivatives and third part programs (sch-scripts, epoptes)
* [2-7][2-7]: upstream

Example for upstream init-ltsp:
* 2x: nothing
* 3x: 00-overlay to 05-getltsconffile
* 4x: config.d
* 5x: 09-hostname to 45-update-kernels
* 6x: all 50's
* 7x: nothing

`sort -V` is used for ordering, so 44-upstream~distro could be a distro override that runs exactly before 44-upstream, while 44-upstream-distro would run afterwards. Extra numbering can be appended when necessary, e.g. 42-0-config-first, 42-1-config-second. Distro or local scripts in /etc with the same name completely override the respective upstream scripts.

Each NN-script is expected to have a main function derived from the script name: `main_script`. All scripts are first sourced before their main functions are executed. This allows for shell function overriding, e.g. a 8x-distro `install_package()` function would override a 5x-upstream `install_package()` function.

One of the scripts, ideally the 55-tool-name, is supposed to provide a function named `a_cmdline()`. This should call getopts to parse the command line and convert it to "$@" with `eval set`, and then call the `run_main_functions() "$@"` function, so that all main functions get the correct parameters.
