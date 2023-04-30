#!/bin/bash

# Store script path
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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
# Export some more variables
export DEVICE=$(basename "${DEFCONFIG}" | sed 's/_defconfig//g')
export GEN_OUT="$PWD/android_device_$OEM_$DEVICE-kernel"

# Enter the kernel directory
cd "$scriptDir"/.. || exitGracefully

# Argument handling
while getopts "gsmh" opt; do
	case "$opt" in
	  g) gcc=1
		;;
	  s) skip=1
		;;
	  m) gen=1
		;;
	  h|*) # Help
		echo "-g for GCC compliation"
		echo "-s for skipping defconfig copying"
		echo "-m for making device-kernel folder"
		echo "-h for help"
		exit 0
		;;
	esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# Clean modules
# want fresh modules for gen'd folder
if [ $gen ]; then
	for i in `find out -name *.ko`; do
		rm -rf $i
	done
fi

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

# Generate device-kernel dir
if [ $gen ]; then
	mkdir -p $GEN_OUT/dtbs
	mkdir -p $GEN_OUT/modules
	if [ -f out/arch/arm64/boot/dtbo.img ]; then
		cp out/arch/arm64/boot/dtbo.img $GEN_OUT/
	fi
	if [ -d out/arch/arm64/boot/dts/vendor ]; then
		cp out/arch/arm64/boot/dts/vendor/*/*.dtb $GEN_OUT/dtbs/
	else
		cp out/arch/arm64/boot/dts/*/*.dtb $GEN_OUT/dtbs/
	fi
	for i in `find out -name *.ko`; do cp $i $GEN_OUT/modules/; done
	if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
		cp out/arch/arm64/boot/Image.gz-dtb $GEN_OUT/
	elif [ -f out/arch/arm64/boot/Image.gz ]; then
		cp out/arch/arm64/boot/Image.gz $GEN_OUT/
	elif [ -f out/arch/arm64/boot/Image ]; then
		cp out/arch/arm64/boot/Image $GEN_OUT/
	fi
fi
