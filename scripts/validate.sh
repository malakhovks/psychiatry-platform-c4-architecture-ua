#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p qa
STATIC_ONLY=false
if [[ "${1:-}" == "--static-only" ]]; then
  STATIC_ONLY=true
fi

printf '1/5 Формування однофайлового workspace...\n'
python3 scripts/build-single-file.py workspace.dsl workspace-single-file.dsl --portable

printf '2/5 Статична узгодженість Structurizr DSL...\n'
python3 scripts/lint-workspace.py workspace-single-file.dsl | tee qa/lint-report.txt

printf '3/5 Перевірка JSON та YAML...\n'
python3 - <<'PY'
from pathlib import Path
import json
try:
    import yaml
except ImportError as exc:
    raise SystemExit("Потрібен PyYAML для перевірки прикладів YAML") from exc

for path in [Path("schemas/algorithm-definition.schema.json"), Path("diagram-catalog.json")]:
    json.loads(path.read_text(encoding="utf-8"))
    print(f"OK JSON: {path}")
for path in sorted(Path("examples").glob("*.yaml")):
    yaml.safe_load(path.read_text(encoding="utf-8"))
    print(f"OK YAML: {path}")
PY

printf '4/5 Перевірка графічних подань і розміщення тексту...\n'
png_count=$(find previews/png -type f -name '*.png' | wc -l | tr -d ' ')
svg_count=$(find previews/svg -type f -name '*.svg' | wc -l | tr -d ' ')
[[ "$png_count" == "41" && "$svg_count" == "41" ]] || {
  echo "Очікувалося 41 PNG і 41 SVG; отримано PNG=$png_count, SVG=$svg_count" >&2
  exit 1
}
printf 'OK previews: %s PNG, %s SVG\n' "$png_count" "$svg_count"
python3 scripts/render_c1_presentation.py --output-dir previews --report validation/c1-text-fit-validation.txt

if $STATIC_ONLY; then
  printf '5/5 Офіційну перевірку Structurizr пропущено (--static-only).\n'
  exit 0
fi

printf '5/5 Офіційна перевірка Structurizr...\n'
if command -v structurizr >/dev/null 2>&1; then
  structurizr validate -workspace workspace-single-file.dsl
elif command -v structurizr.sh >/dev/null 2>&1; then
  structurizr.sh validate -workspace workspace-single-file.dsl
elif command -v docker >/dev/null 2>&1; then
  docker run --rm \
    -v "$ROOT":/usr/local/structurizr \
    structurizr/structurizr \
    validate -workspace /usr/local/structurizr/workspace-single-file.dsl
else
  echo "Docker або Structurizr не знайдено. Статичні перевірки пройдено; офіційний parser не запускався." >&2
  exit 2
fi
