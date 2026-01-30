#!/usr/bin/env python3
from pathlib import Path
import sys
import re

include = Path("include")
c64 = include / "c64.h"

if not c64.exists():
    print("Could not find include/c64.h", file=sys.stderr)
    exit(1)

pattern = re.compile(r"^extern\s+void\s+([^;]+)\[\];", re.MULTILINE)

with open(c64) as f:
    content = f.read()

new_content = pattern.sub(lambda m: f"extern void* {m.group(1)};", content)

if content == new_content:
    print("Failed to patch void arrays, content is the same", file=sys.stderr)
    exit(1)

with open(c64, "w") as f:
    f.write(new_content)
