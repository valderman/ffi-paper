SOURCES=ifl15.tex macros.tex sigplanconf.cls lsthaskell.tex

dev: ifl15.pdf

all: ifl15.ps ifl15.pdf ifl15.zip

ifl15.ps: ifl15.dvi
	dvips -o ifl15.ps ifl15.dvi
	dvips -o ifl15.ps ifl15.dvi

ifl15.dvi: $(SOURCES)
	pslatex ifl15.tex
	pslatex ifl15.tex

ifl15.pdf: $(SOURCES)
	pdflatex ifl15.tex
	pdflatex ifl15.tex

ifl15.zip: $(SOURCES)
	mkdir -p ifl15
	cp -f $(SOURCES) ifl15/
	zip -r ifl15 ifl15

clean:
	rm ifl15.log ifl15.aux *~
