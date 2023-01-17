#!/usr/bin/env bash

clear

bin_path="Contents/MacOS/Xcode"
prompt="FALSE"
xcode_path=""

function print_help () {
    echo "usage: Start-Xcode.command [-h] [-p] [-x PATH]"
    echo ""
    echo "Start-Xcode - a bash script to directly launch Xcode via its binary"
    echo ""
    echo "optional arguments:"
    echo "  -h, --help              show this help message and exit"
    echo "  -p, --prompt            override xcode-select detection and prmopt for the"
    echo "                          Xcode.app path"
    echo "  -x PATH, --xcode PATH   provide an explicit path to the target Xcode.app"
    echo "                          - overrides -p"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) print_help; exit 0 ;;
        -p|--prompt) prompt="TRUE" ;;
        -x|--xcode) xcode_path="$2"; prompt="FALSE"; shift ;;
        *) echo "Unknown parameter passed: $1"; print_help; exit 1 ;;
    esac
    shift
done

if [ "$prompt" == "FALSE" ] && [ -z "$xcode_path" ]; then
    echo "Checking current xcode-select path..."
    xcode_path="$(xcode-select -p)"
elif [ ! -z "$xcode_path" ]; then
    echo "xcode-select detection overridden via --xcode arg"
else
    echo "xcode-select detection overridden via --prompt arg"
fi
if [ ! -z "$xcode_path" ] && [[ "$xcode_path" == *".app"* ]]; then
    echo " - Located "$xcode_path""
    if [[ "$xcode_path" == *"/Contents/Developer" ]]; then
        # Strip the last 2 path components as they're /Contents/Developer
        echo " - Normalizing path to .app..."
        xcode_path="${xcode_path%/*}"
        xcode_path="${xcode_path%/*}"
    fi
else
    # No .app path was found via xcode-select - or we're prompting
    if [ "$prompt" == "FALSE" ]; then
        echo " - Not located, or doesn't point to Xcode.app"
        echo
    fi
    echo "Please drag and drop your Xcode.app here: "
    read xcode_path
    if [ ! -d "$xcode_path" ]; then
        echo " - That path does not exist!"
        exit 1
    fi
fi
echo " - Verifying..."
if [ ! -f "$xcode_path/$bin_path" ]; then
    echo " --> The target Xcode binary does not exist!"
    echo
    echo "$xcode_path/$bin_path"
    exit 1
fi
echo " - Starting..."
"$xcode_path/$bin_path"