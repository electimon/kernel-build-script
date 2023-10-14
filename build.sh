#!/bin/bash

# Store script path
scriptDir=$(realpath $(dirname "$0"))

# Setup Functions
# Load all variables and keep them in a readable format.
function loadVariables {
	for var in "$@"
	do
		export "$var"
	done
}
# This exits the script.
function exitGracefully {
	echo "Well well well, looks like something went wrong..."
	exit 0
}

# Load configuration file
source "$scriptDir"/config

# Enter the kernel directory
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
