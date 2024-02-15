#!/usr/bin/env bash

echo "Swift Codeserver"
echo "-----------------------------------------------------------------------------------"
echo "From Uitsmijter"
echo ""
echo "Starting Code-Server"

"$@"

code-server \
  --disable-telemetry \
  --extensions-dir /extensions

echo "-----------------------------------------------------------------------------------"
echo "Ready."
echo ""

