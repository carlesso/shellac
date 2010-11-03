target = relazione
DEPS =  relazione.tex 00-introduzione.tex 10-workflow.tex 20-conclusioni.tex 99-appendice.tex

all: ${target}.pdf

${target}.pdf: ${target}.tex $(DEPS)
	pdflatex ${target}.tex
	pdflatex ${target}.tex

clean:
	rm -rf ${target}.{aux,dvi,log,out,toc,lof,pdf,nav,snm,vrb}

view: ${target}.pdf
	xpdf ${target}.pdf 

kview: ${target}.pdf
	kpdf ${target}.pdf
