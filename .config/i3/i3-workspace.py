#!/usr/bin/python
import json
import sys
from subprocess import check_output

arg = sys.argv
workspaces = json.loads(check_output(["i3-msg", "-t", "get_workspaces"]))
workspace_nums = [ws["num"] for ws in workspaces]
f = next(ws["num"] for ws in workspaces if ws["focused"])
n, d = 10, 1

if arg[1] == "next":
    d = 1
    f += 1
    n = f+10
elif arg[1] == "prev":
    d = -1
    f -= 1
    n = f-10


for num in range(f, n, d):
    if num%10 not in workspace_nums or arg[2] == "all":  # delete "not" for "Move window to next (existing) workspace"
        print(num%10)
        break
