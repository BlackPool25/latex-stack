# Docker-first: every gate runs in the pinned container unless local TeX is
# complete (fast path). USE_DOCKER=1 forces container, =0 forces local.
USE_DOCKER ?= auto
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/
LOCAL_OK := $(shell command -v lualatex chktex latexindent biber python3 >/dev/null 2>&1 && kpsewhich IEEEtran.cls >/dev/null 2>&1 && echo 1 || echo 0)
ifeq ($(USE_DOCKER),1)
  USE_CT := 1
else ifeq ($(USE_DOCKER),0)
  USE_CT := 0
else ifeq ($(LOCAL_OK),1)
  USE_CT := 0
else
  USE_CT := 1
endif
ifeq ($(USE_CT),1)
  CD :=
  TOOL = docker compose -f $(ROOT)docker-compose.toolchain.yml run --rm toolchain
else
  CD := cd paper &&
  TOOL :=
endif

.PHONY: up down logs update paper lint format format-check arxiv review final verify-refs check-engine pull

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

update:
	git pull --rebase --autostash
	docker compose pull && docker compose up -d

check-engine: ## Assert LuaLaTeX directive + IEEEtran conf mode
	grep -q '^%! TEX program = lualatex' paper/main.tex || (echo "engine directive missing" && exit 1)
	grep -q 'documentclass\[conference\]{IEEEtran}' paper/main.tex || (echo "IEEEtran conf mode missing" && exit 1)

paper: check-engine ## Compile paper/ -> paper/main.pdf
	$(CD) $(TOOL) latexmk -lualatex -interaction=nonstopmode -halt-on-error main.tex
	! grep -Ei "undefined (reference|citation)|multiply defined|rerun to get" paper/main.log || (echo "log gate failed" && exit 1)

review: ## Anonymous review build -> paper/review.pdf (sets anonymous.flag)
	cd paper && touch anonymous.flag && $(TOOL) latexmk -lualatex -interaction=nonstopmode -halt-on-error -jobname=review main.tex; rm -f paper/anonymous.flag

final: ## Camera-ready build -> paper/final.pdf (authors shown, no draft marks)
	cd paper && rm -f anonymous.flag && $(TOOL) latexmk -lualatex -interaction=nonstopmode -halt-on-error -jobname=final main.tex

lint: ## ChkTeX must-fail gate (config in paper/.chktexrc)
	$(CD) $(TOOL) sh -c 'chktex -wall -n22 -n30 -e16 -q main.tex sections/*.tex'

format: ## Normalize .tex in place
	$(CD) $(TOOL) sh -c 'for f in main.tex sections/*.tex; do latexindent -l latexindent.yaml -w "$$f"; done'

format-check: ## CI: fail if formatting drifts
	$(CD) $(TOOL) sh -c 'for f in main.tex sections/*.tex; do latexindent -l latexindent.yaml "$$f" | diff -u "$$f" - || exit 1; done'

verify-refs: ## Citation integrity: keys resolve, no dups, DOIs live
	python3 scripts/verify-refs.py

arxiv: paper ## Build arxiv.tar.gz (sources + .bbl, standalone-verified layout)
	rm -rf .arxiv-staging arxiv.tar.gz && mkdir -p .arxiv-staging/sections
	$(CD) $(TOOL) latexmk -lualatex -interaction=nonstopmode main.tex
	cp paper/main.tex paper/refs.bib paper/main.bbl .arxiv-staging/
	cp paper/sections/*.tex .arxiv-staging/sections/
	cp paper/figures/* .arxiv-staging/ 2>/dev/null || true
	tar -czf arxiv.tar.gz -C .arxiv-staging . && rm -rf .arxiv-staging
	@echo "wrote arxiv.tar.gz — extract to an empty dir and run latexmk to verify"

pull:
	git fetch --all --prune
	git pull --rebase --autostash
