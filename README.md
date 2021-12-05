# Electimon's Kernel Build Script
## Configuration
Copy config.example to config like so,

```cp config.example config```

Edit config to suit your device.

## Building
To build run ```./build/build.sh```, by default it builds with AOSP clang-r383902

### Options
Use ```-g``` for building with configured GCC (default is AOSP 4.9)

Use ```-s``` to skip defconfig generation
