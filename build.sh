#!/bin/bash

mkdir -p build

if [ -d "build/linux" ]; then
    echo "Removing old linux folder..."
    rm -rf build/linux
fi

echo "Creating new linux folder..."
mkdir -p build/linux

echo "Compiling parser..."
dart compile exe bin/parser.dart -o build/linux/stacklog_parser

echo "Compiling highlighter..."
dart compile exe bin/highlighter.dart -o build/linux/stacklog_highlighter

echo "Copying input.json..."
if [ -f "example/input.json" ]; then
    cp example/input.json build/linux/
    echo "File input.json successfully copied"
else
    echo "WARNING: File example/input.json not found!"
fi

echo "Creating cfg directory..."
mkdir -p build/linux/cfg

echo "Copying config.yaml..."
if [ -f "example/config.yaml" ]; then
    cp example/config.yaml build/linux/cfg/
    echo "File config.yaml successfully copied to cfg/"
else
    echo "WARNING: File example/config.yaml not found!"
fi

echo "Copying filters.txt..."
if [ -f "example/filters.txt" ]; then
    cp example/filters.txt build/linux/cfg/
    echo "File filters.txt successfully copied to cfg/"
else
    echo "WARNING: File example/filters.txt not found!"
fi

echo "Done!"
echo
echo "Contents of build/linux folder:"
ls -la build/linux/
echo
echo "Contents of build/linux/cfg folder:"
ls -la build/linux/cfg/