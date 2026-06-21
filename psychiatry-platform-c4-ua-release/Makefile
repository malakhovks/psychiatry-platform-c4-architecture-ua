.PHONY: build validate validate-static previews c1-previews presentation docs report clean

build:
	python3 scripts/build-single-file.py workspace.dsl workspace-single-file.dsl --portable

validate-static: build
	./scripts/validate.sh --static-only

validate: build
	./scripts/validate.sh

previews: build
	./scripts/export.sh graphviz

c1-previews: build
	python3 scripts/render_c1_presentation.py --output-dir previews --report validation/c1-text-fit-validation.txt

presentation: c1-previews
	node scripts/create-c1-presentation.js

docs: build
	python3 scripts/generate-architecture-docs.py

report: docs c1-previews presentation
	python3 scripts/create-docx-report.py

clean:
	rm -rf exports qa/docx-render
