#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
MODE="${1:-graphviz}"

case "$MODE" in
  graphviz)
    python3 scripts/build-single-file.py workspace.dsl workspace-single-file.dsl --portable
    python3 scripts/render-previews.py workspace-single-file.dsl previews
    python3 scripts/render_c1_presentation.py --output-dir previews --report validation/c1-text-fit-validation.txt
    if command -v node >/dev/null 2>&1 && node -e "require('pptxgenjs')" >/dev/null 2>&1; then
      node scripts/create-c1-presentation.js
    else
      echo "Попередження: PPTX не перебудовано, оскільки Node.js або pptxgenjs недоступні." >&2
    fi
    echo "Створено попередні перегляди та перевірені презентаційні C1-діаграми в previews/."
    ;;
  mermaid|static|svg|png)
    command -v docker >/dev/null 2>&1 || { echo "Потрібен Docker." >&2; exit 2; }
    mkdir -p "exports/$MODE"
    image="structurizr/structurizr"
    if [[ "$MODE" == "svg" || "$MODE" == "png" ]]; then
      image="structurizr/structurizr:2026.05.22-playwright"
    fi
    docker run --rm -v "$ROOT":/usr/local/structurizr "$image" \
      export -workspace /usr/local/structurizr/workspace-single-file.dsl \
      -format "$MODE" -output "/usr/local/structurizr/exports/$MODE"
    ;;
  c4plantuml)
    command -v docker >/dev/null 2>&1 || { echo "Потрібен Docker." >&2; exit 2; }
    mkdir -p exports/c4plantuml
    docker run --rm -v "$ROOT":/usr/local/structurizr structurizr/structurizr \
      export -workspace /usr/local/structurizr/workspace-single-file.dsl \
      -format plantuml/c4plantuml -output /usr/local/structurizr/exports/c4plantuml
    ;;
  *)
    echo "Використання: $0 {graphviz|mermaid|c4plantuml|static|svg|png}" >&2
    exit 2
    ;;
esac
