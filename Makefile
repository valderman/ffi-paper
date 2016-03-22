SOURCES=ifl15.tex macros.tex sigplanconf.cls lsthaskell.tex litterature.bib

dev: ifl15.pdf

camera: ifl15.ps ifl15.pdf ifl15.zip

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

ifl15.zip: $(SOURCES)
	mkdir -p ifl15
	cp -f $(SOURCES) ifl15/
	zip -r ifl15 ifl15

clean:
	rm ifl15.log ifl15.aux *~
