#!/bin/bash
VERSION=12
wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$VERSION/wasi-sdk-$VERSION.0-linux.tar.gz
tar xvf wasi-sdk-$VERSION.0-linux.tar.gz
rm wasi-sdk-$VERSION.0-linux.tar.gz
