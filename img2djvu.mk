SHELL:=/bin/bash

prefix=out
dpi=600
pages=$(notdir $(wildcard $(prefix)/*.tif))

djvu_pages=$(subst .tif,.djvu,$(pages))
pdf_pages=$(subst .tif,.djvu,$(pages))

tmp=/dev/shm

VPATH=$(prefix)

all:$(prefix).djvu

$(prefix).djvu:$(djvu_pages)
	djvm -c $@ $^ &&\
#	ocrodjvu -j4 -etesseract -leng --in-place $@

$(djvu_pages):%.djvu:%.tif
#	Image segmentation
	convert $< -threshold 1 $(tmp)/$*.pbm
	convert $< $(tmp)/$*.pgm
#	Convert to djvu
	cjb2 -losslevel 200 -dpi $(dpi) $(tmp)/$*.pbm $(tmp)/$*-bw.djvu
	c44 -slice 76+15 -dpi $(dpi) -mask $(tmp)/$*.pbm $(tmp)/$*.pgm $(tmp)/$*-c.djvu
	rm $(tmp)/$*.p??
#	Merge layers	
	djvuextract $(tmp)/$*-c.djvu BG44=$(tmp)/$*.c44 >/dev/null 2>&1
	djvuextract $(tmp)/$*-bw.djvu Sjbz=$(tmp)/$*.cjb2 >/dev/null 2>&1
	djvumake $@ INFO=,,"$(dpi)" Sjbz=$(tmp)/$*.cjb2 FGbz="#black" BG44=$(tmp)/$*.c44
	rm -f $(tmp)/$*.c*
	
################################################################################
pdf:$(prefix).pdf

$(prefix).pdf:$(pdf_pages)
	gs -dNOPAUSE -dBATCH -sOUTPUTFILE=$@ -sDEVICE=pdfwrite $^

$(pdf_pages):%.pdf:%.tif
#	Image segmentation
	convert $< -threshold 1 -transparent white -compress jbig2 $(tmp)/$*-bw.pdf
	convert $< -white-threshold 1 -compress jpeg $(tmp)/$*-c.pdf
#	Merge layers	
	pdftk $(tmp)/$*-bw.pdf multibackground $(tmp)/$*-c.pdf $@
	rm $(tmp)/$*.pdf
