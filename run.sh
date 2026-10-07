#!/bin/bash
# Topsvision / Xiongmai CCTV VMS Gateway & Console
cd "$(dirname "$0")"
python3 camera_viewer.py "$@"
