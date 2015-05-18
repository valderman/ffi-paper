SOURCES=haskell15.tex macros.tex sigplanconf.cls lsthaskell.tex

dev: haskell15.pdf

all: haskell15.ps haskell15.pdf haskell15.zip

haskell15.ps: haskell15.dvi
	dvips -o haskell15.ps haskell15.dvi
	dvips -o haskell15.ps haskell15.dvi

haskell15.dvi: $(SOURCES)
	pslatex haskell15.tex
	pslatex haskell15.tex

haskell15.pdf: $(SOURCES)
	pdflatex haskell15.tex
	pdflatex haskell15.tex

haskell15.zip: $(SOURCES)
	mkdir -p haskell15
	cp -f $(SOURCES) haskell15/
	zip -r haskell15 haskell15
