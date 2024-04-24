#!/usr/bin/env bash

echo "Swift Codeserver"
echo "Based on coder/code-server: https://github.com/coder/code-server"
echo "-----------------------------------------------------------------------------------"
echo "For Uitsmijter - Swift ${SWIFT_VERSION}"
echo ""
echo "Setup system"
echo ${MAX_USER_INSTANCES} > /proc/sys/fs/inotify/max_user_instances

echo "Running commands"
"$@"

echo "Starting Code-Server"
code-server \
  --disable-telemetry \
  --extensions-dir /extensions

echo "-----------------------------------------------------------------------------------"
echo "Ready."
echo ""

