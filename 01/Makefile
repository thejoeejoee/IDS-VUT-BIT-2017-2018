all:
	- dia -t eps -e assets/uc.eps assets/uc.dia
	- dia -t eps -e assets/er.eps assets/er.dia
	- inkscape --export-pdf=assets/er.pdf assets/er.eps 
	- inkscape --export-pdf=assets/uc.pdf assets/uc.eps 
	- pdflatex -shell-escape docs.tex
	- pdflatex -shell-escape docs.tex
	- pdflatex -shell-escape docs.tex
	- evince docs.pdf &2> /dev/null &