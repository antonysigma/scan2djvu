SHELL:=/bin/bash

prefix=out
dpi=600

tmp=/dev/shm
ext=tif

djvu_pages=$(subst .$(ext),.djvu,$(wildcard $(prefix)/*.$(ext)))
pdf_pages=$(subst .djvu,.pdf,$(djvu_pages))

all:$(prefix).djvu

$(prefix).djvu:$(djvu_pages)
	djvm -c $@ $^
	ocrodjvu -j4 -etesseract -leng --in-place $@

$(djvu_pages):%.djvu:%.$(ext)
	mogrify -trim -normalize -compress lzw $<
	didjvu encode --loss-level 200 -m djvu -d $(dpi) $< -o $@
	
###############################################################
pdf:$(prefix)-converted.pdf

$(prefix)-converted.pdf:$(pdf_pages)
	gs -dNOPAUSE -dBATCH -sOUTPUTFILE=$@ -sDEVICE=pdfwrite $^

$(pdf_pages):%.pdf:%.djvu
#	Extract layers
	ddjvu -mode=background -format=tiff $< $(tmp)/$(notdir $*)-bg.tif
	ddjvu -mode=mask -page=1 -format=pbm $< $(tmp)/$(notdir $*)-bw.pbm
#	ddjvu -mode=foreground -page=1 -format=pdf $< $*-ft.pdf
#	Convert foreground to best format
	convert $(tmp)/$(notdir $*)-bw.pbm -threshold 1 -transparent white -compress jbig2 $(tmp)/$(notdir $*)-bw.pdf
	convert $(tmp)/$(notdir $*)-bg.tif -compress jpeg2000 $(tmp)/$(notdir $*)-bg.pdf
#	Merge layers
	pdftk $(tmp)/$(notdir $*)-bw.pdf multibackground $(tmp)/$(notdir $*)-bg.pdf $@
	rm $(tmp)/$(notdir $*)-*
