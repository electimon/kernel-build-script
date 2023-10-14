#!/bin/bash
# Reset to script path and load the configuration file
scriptDir=$(dirname "$0")

# Load all variables and keep them in a readable format.
function loadVariables {
	for var in "$@"
	do
		export "$var"
	done
}

source "$scriptDir"/config
# Enter the kernel
cd "$scriptDir"/.. || exitGracefully

# Argument handling
while getopts "ghs" opt; do
	case "$opt" in
	  g) gcc=1
		;;
	  s) skip=1
		;;
	  h|*) # Help
		echo "-g for GCC compliation"
		echo "-s for skipping defconfig copying"
		echo "-h for help"
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
	make "$DEFCONFIG" || exitGracefully
fi

# Build the kernel!
if [ ! $gcc ]; then
	make CC=clang "$@" || exitGracefully
else
	make "$@" || exitGracefully
fi
