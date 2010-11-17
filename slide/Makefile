#document name:
NAME = slides

help:
	@echo Uso:
	@echo make all - per compilare il documento e vederne il risultato
	@echo make doc - per compilare il documento
	@echo make clean - pulisce da files temporanei
	@echo make deepclean - pulisce il directory corrente
	@echo make view - per vedere il documento
all:
	pdflatex $(NAME).tex
	pdflatex $(NAME).tex
	#@evince -fullscreen $(NAME).pdf

doc:
	pdflatex $(NAME).tex
	pdflatex $(NAME).tex

clean:
	@echo pulizia dai files temporanei in corso...
	rm -f *.{aux,dvi,log,out,toc,lof,blg,nav,snm}
	@echo pulizia completata

deepclean:
	@echo pulizia in corso...
	rm -f *.{aux,dvi,log,out,toc,lof,blg,nav,snm,pdf}
	@echo pulizia completata

view:
	@evince -fullscreen $(NAME).pdf

love:
	@echo not war?
