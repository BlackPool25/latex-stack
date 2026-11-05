# Local build/lint without Aldine (uses TeX Live on this machine).
.PHONY: up down logs update paper lint format pull push-sync

up:           ## Start Aldine (http://localhost:8080)
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

update:       ## Pull images + paper updates, rebase-safe
	git pull --rebase --autostash
	docker compose pull && docker compose up -d

paper:        ## Compile paper/ -> paper/main.pdf (LuaLaTeX, warnings are errors)
	cd paper && latexmk -lualatex -interaction=nonstopmode -halt-on-error main.tex

lint:         ## ChkTeX must-fail gate (exit != 0 blocks)
	cd paper && chktex -wall -n22 -n30 -e16 -q main.tex sections/*.tex

format:       ## Normalize .tex formatting in place
	cd paper && latexindent -w main.tex sections/*.tex

pull:         ## Fetch + rebase paper branches (safe for 2nd machine)
	git fetch --all --prune
	git pull --rebase --autostash
