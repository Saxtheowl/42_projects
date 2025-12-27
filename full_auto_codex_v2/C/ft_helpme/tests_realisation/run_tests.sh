#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make >/dev/null

BIN="$ROOT/ft_helpme"

output=$($BIN -p "libft" -q "Pourquoi segfault sur buffer vide ?" -c "Lecture stdin, calloc, write" )
md_output=$($BIN -m -p "libft" -q "Pourquoi segfault sur buffer vide ?" -c "Lecture stdin, calloc, write")
tmp_md_file=$(mktemp)
tmp_txt_file=$(mktemp)
$BIN -m -p "libft" -q "Pourquoi segfault sur buffer vide ?" -c "Lecture stdin, calloc, write" -o "$tmp_md_file"
$BIN -p "libft" -q "Pourquoi segfault sur buffer vide ?" -c "Lecture stdin, calloc, write" -o "$tmp_txt_file"

failures=0

if ! grep -q "Project   : libft" <<<"$output"; then
    echo "❌ project field wrong"
    failures=$((failures + 1))
else
    echo "✅ project field ok"
fi

if ! grep -q "Question  : Pourquoi segfault sur buffer vide ?" <<<"$output"; then
    echo "❌ question field wrong"
    failures=$((failures + 1))
else
    echo "✅ question field ok"
fi

if ! grep -q "Context   : Lecture stdin, calloc, write" <<<"$output"; then
    echo "❌ context field wrong"
    failures=$((failures + 1))
else
    echo "✅ context field ok"
fi

if ! grep -Fq -- "- Project  : libft" <<<"$md_output"; then
    echo "❌ markdown project field wrong"
    failures=$((failures + 1))
else
    echo "✅ markdown project field ok"
fi

if ! grep -q "## Help Request" "$tmp_md_file"; then
    echo "❌ markdown file output missing header"
    failures=$((failures + 1))
else
    echo "✅ markdown file output ok"
fi

if ! grep -q "Project   : libft" "$tmp_txt_file"; then
    echo "❌ text file output missing project"
    failures=$((failures + 1))
else
    echo "✅ text file output ok"
fi

if ! grep -q "What I tried" <<<"$output"; then
    echo "❌ template missing"
    failures=$((failures + 1))
else
    echo "✅ template present"
fi

if ! grep -q "Expected vs actual" <<<"$output"; then
    echo "❌ expected/actual section missing"
    failures=$((failures + 1))
else
    echo "✅ expected/actual section present"
fi

if ! grep -q "## Help Request" <<<"$md_output"; then
    echo "❌ markdown header missing"
    failures=$((failures + 1))
else
    echo "✅ markdown header present"
fi

if ! grep -q "### Expected vs Actual" <<<"$md_output"; then
    echo "❌ markdown expected/actual section missing"
    failures=$((failures + 1))
else
    echo "✅ markdown expected/actual section present"
fi

if ! grep -q "### Logs / Error / Repro" <<<"$md_output"; then
    echo "❌ markdown logs/repro section missing"
    failures=$((failures + 1))
else
    echo "✅ markdown logs/repro section present"
fi

echo
if [[ $failures -eq 0 ]]; then
    echo "All tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi

rm -f "$tmp_md_file" "$tmp_txt_file"
