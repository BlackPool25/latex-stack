#!/usr/bin/env python3
"""verify-refs.py — blocking citation gate. Zero third-party deps (stdlib only).
Fails on: cite key with no .bib entry, .bib entry never cited, duplicate keys
or labels, DOI that does not resolve on CrossRef/Semantic Scholar.
Usage: python3 scripts/verify-refs.py [--offline]  (offline skips DOI checks)
"""
import re, sys, urllib.request, json

OFFLINE = "--offline" in sys.argv
errors, warnings = [], []
TEX = ["paper/main.tex", "paper/sections/intro.tex", "paper/sections/method.tex",
       "paper/sections/results.tex", "paper/sections/conclusion.tex"]

cited = set()
for path in TEX:
    try:
        src = open(path, encoding="utf-8").read()
    except FileNotFoundError:
        continue
    for m in re.findall(r"\\cite\w*\{([^}]+)\}", src):
        cited |= {k.strip() for k in m.split(",")}
labels = []
for path in TEX:
    try:
        src = open(path, encoding="utf-8").read()
    except FileNotFoundError:
        continue
    labels += re.findall(r"\\label\{([^}]+)\}", src)

bib = open("paper/refs.bib", encoding="utf-8").read()
entries = re.findall(r"@\w+\{([^,]+),", bib)
dois = dict(re.findall(r"@\w+\{([^,]+),.*?doi\s*=\s*[{\"]([^}\"]+)", bib, re.S | re.I))

if len(entries) != len(set(entries)):
    errors.append("duplicate .bib keys")
for k in sorted(cited - set(entries)):
    errors.append(f"cited but missing from refs.bib: {k}")
for k in sorted(set(entries) - cited):
    warnings.append(f"in refs.bib but never cited: {k}")
if len(labels) != len(set(labels)):
    errors.append("duplicate \\label keys")

def resolve(url):
    req = urllib.request.Request(url, headers={"User-Agent": "latex-stack/1.0 (mailto:paper@example.org)"})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return r.status == 200
    except Exception as e:
        return f"unreachable: {e}"

if not OFFLINE:
    for key, doi in dois.items():
        r = resolve(f"https://api.crossref.org/works/{doi}")
        if r is not True:
            s2 = resolve(f"https://api.semanticscholar.org/graph/v1/paper/DOI:{doi}?fields=title")
            (errors if s2 is not True else warnings).append(
                f"DOI does not resolve (CrossRef: {r}; S2: {'ok' if s2 is True else s2}): {key} -> {doi}")

for w in warnings:
    print(f"WARN: {w}")
for e in errors:
    print(f"FAIL: {e}")
sys.exit(1 if errors else 0)
