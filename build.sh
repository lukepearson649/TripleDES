#!/bin/bash

SOURCE_FILE="des.c"
CFLAGS="-Wall -O2"

# === Detect OS ===
case "$(uname -s)" in
    Linux*)
        COMPILER="x86_64-w64-mingw32-gcc"
        EXT=".elf"
        ;;
    Darwin*)
        COMPILER="x86_64-w64-mingw32-gcc"
        EXT=".mach-o"
        ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
        COMPILER="gcc"
        EXT=".exe"
        ;;
    *)
        echo "Unsupported OS: $(uname -s)"
        exit 1
        ;;
esac
BASENAME=$(basename "$SOURCE_FILE" .c)
OUTPUT_FILE="${BASENAME}${EXT}"
if ! command -v $COMPILER >/dev/null 2>&1; then
    echo "Compiler '$COMPILER' not found. Please install MinGW-w64 or ensure it's in your PATH."
    exit 1
fi

# === Compile ===
echo "Compiling $SOURCE_FILE with $COMPILER..."
$COMPILER $CFLAGS -o "$OUTPUT_FILE" "$SOURCE_FILE"
if [ $? -eq 0 ]; then
    echo "Build successful: $OUTPUT_FILE"
else
    echo "Build failed."
    exit 1
fi
