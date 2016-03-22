SOURCES=ifl15.tex macros.tex sigplanconf.cls lsthaskell.tex bibliography.bib acmcopyright.sty

dev: ifl15.pdf

camera: ifl15.ps ifl15.pdf paper4.zip
	mv ifl15.ps paper4.ps
	mv ifl15.pdf paper4.pdf

spellcheck:
	ispell -t ifl15.tex

ifl15.ps: ifl15.dvi
	dvips -o ifl15.ps ifl15.dvi
	dvips -o ifl15.ps ifl15.dvi

ifl15.dvi: $(SOURCES)
	latex ifl15
	bibtex ifl15
	latex ifl15
	latex ifl15

ifl15.pdf: ifl15.dvi
	pdflatex ifl15.tex
	pdflatex ifl15.tex

paper4.zip: $(SOURCES)
	mkdir -p paper4
	cp -f $(SOURCES) paper4/
	zip -r paper4 paper4

clean:
	rm *.bbl *.aux ifl15.log
