#!/usr/bin/env python3
import sys
import os
import re

def generate(tag):
    v = tag.lstrip('v')
    notes = ''
    readme_path = 'README.md'
    if os.path.exists(readme_path):
        with open(readme_path, 'r', encoding='utf-8') as f:
            content = f.read()
        pattern = rf'## Release Notes[^\n]*{re.escape(v)}[\s\S]*?(?=\n---\n|\n## Release Notes|\Z)'
        match = re.search(pattern, content)
        if match:
            notes = match.group(0).strip()

    body = f"## APEX Horizon Digital Instrument Cluster HMI - {tag}\n\n"
    body += "### Downloadable Prebuilt Archives\n"
    body += "| Platform | File | Architecture |\n"
    body += "| :--- | :--- | :--- |\n"
    body += "| Ubuntu Linux | `ApexCluster-Ubuntu-x86_64.zip` | x86_64 (glibc / X11 / OpenGL) |\n"
    body += "| macOS | `ApexCluster-macOS.zip` | Universal (Apple Silicon & Intel) |\n"
    body += "| Windows | `ApexCluster-Windows-x64.zip` | x64 (Standalone with Qt DLLs) |\n\n"

    if notes:
        body += "---\n\n" + notes + "\n"
    else:
        body += "See [README.md](README.md) for full project documentation and build instructions.\n"

    with open('release_body.md', 'w', encoding='utf-8') as out:
        out.write(body)
    print(f"Generated release_body.md for {tag}")

if __name__ == '__main__':
    tag_arg = sys.argv[1] if len(sys.argv) > 1 else 'v2.2.0'
    generate(tag_arg)
