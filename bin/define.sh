#!/bin/sh
termite --name="dict-lookup" --geometry 700x1000 -e "bash -c 'dict $1| less'"
