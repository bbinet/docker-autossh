#!/bin/bash

if [ -z "$1" ]; then
    echo "Please provide the port to clean up as first argument. For example:"
    echo "$ $0 22000"
    exit 1
fi

echo "Port to clean up: $1."

pid=$(netstat -anp |grep $1 | grep autossh | sed "s/.*\s\([0-9]\+\)\/sshd: autossh.*/\1/")
if [ -z "$pid" ]; then
    echo "Nothing to clean up, port $1 is already free."
else
    echo "Cleaning up port $1."
    kill $pid
    echo "Done."
fi
