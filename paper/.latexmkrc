# latexmk defaults: LuaLaTeX, warnings are errors, force rebuild on demand.
$lualatex = 'lualatex -interaction=nonstopmode -halt-on-error -synctex=1 %O %S';
$pdf_mode = 4;
$warnings_as_errors = 1;
$bibtex_use = 2;
