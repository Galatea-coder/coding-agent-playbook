#!/usr/bin/env python3
"""Tiny code map. Usage: codemap.py where|callers NAME [ROOT]

where   -> path:start-end of every def/class named NAME (feed the range to a sliced read)
callers -> path:line of every call to NAME (plain or attribute call)
"""
import ast
import pathlib
import sys

if len(sys.argv) < 3 or sys.argv[1] not in ("where", "callers"):
    sys.exit(__doc__)

cmd, name = sys.argv[1], sys.argv[2]
root = pathlib.Path(sys.argv[3] if len(sys.argv) > 3 else ".")
SKIP = {".git", ".venv", "venv", "node_modules", "__pycache__", "build", "dist"}
DEFS = (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)

for path in sorted(root.rglob("*.py")):
    if SKIP & set(path.parts):
        continue
    try:
        tree = ast.parse(path.read_text(encoding="utf-8"), str(path))
    except (SyntaxError, UnicodeDecodeError):
        continue
    for node in ast.walk(tree):
        if cmd == "where" and isinstance(node, DEFS) and node.name == name:
            kind = "class" if isinstance(node, ast.ClassDef) else "def"
            print(f"{path}:{node.lineno}-{node.end_lineno}  {kind} {name}")
        elif cmd == "callers" and isinstance(node, ast.Call):
            f = node.func
            called = getattr(f, "id", None) or getattr(f, "attr", None)
            if called == name:
                print(f"{path}:{node.lineno}")
