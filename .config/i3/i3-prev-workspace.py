#!/usr/bin/python
import json
from subprocess import check_output

workspaces = json.loads(check_output(["i3-msg", "-t", "get_workspaces"]))
workspace_nums = [ws["num"] for ws in workspaces]
f = next(ws["num"] for ws in workspaces if ws["focused"])

for prev_num in range(f - 1, -1, -1):
    if prev_num not in workspace_nums:  # delete "not" for "Move window to next (existing) workspace"
        print(prev_num)
        break
