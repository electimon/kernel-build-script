#!/bin/bash
# Reset to script path and load the configuration file
scriptDir=$(dirname "$0")
source "$scriptDir"/config
# Enter the kernel
cd "$scriptDir"/.. || exitGracefully

# Argument handling
while getopts "hs" opt; do
	case "$opt" in
	  s) skip=1
		;;
	  h|*) # Help
		echo "-s for skipping defconfig copying"
		exit 0
		;;
	esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# Setup Functions
# This exits the script.
exitGracefully () {
	echo "Well well well, looks like something went wrong..."
	exit 0
}
# Generate defconfig
if [ ! $skip ]; then
	make CC=clang LLVM=1 "$DEFCONFIG" || exitGracefully
fi

# Build the kernel!
make CC=clang LLVM=1 "$@" || exitGracefully
