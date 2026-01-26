#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/readme_toc.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

work_dir=$(mktemp -d)
cleanup() {
  rm -rf "${work_dir}"
}
trap cleanup EXIT

missing_readme="${work_dir}/missing.md"
if FILE="${missing_readme}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected readme_toc to fail for missing README." >&2
  exit 1
fi

sample_readme="${work_dir}/README.md"
cat > "${sample_readme}" <<'MD'
# Title

## First Section
Text

## Second Section
More text

### Ignored Subsection

## Third Section!
MD

output=$(FILE="${sample_readme}" "${SCRIPT}")
if ! printf '%s' "${output}" | rg -q "# Table of contents"; then
  echo "Expected TOC header." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "\[First Section\]\(#first-section\)"; then
  echo "Expected First Section link." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "\[Second Section\]\(#second-section\)"; then
  echo "Expected Second Section link." >&2
  exit 1
fi
if printf '%s' "${output}" | rg -q "Ignored Subsection"; then
  echo "Did not expect subsection in TOC." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "\[Third Section!\]\(#third-section\)"; then
  echo "Expected Third Section link without punctuation." >&2
  exit 1
fi

echo "[ok] readme_toc tests passed"
