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
	ddjvu -mode=black -format=tif $< $(tmp)/$*-fore.tif
	ddjvu -mode=background -format=tif $< $(tmp)/$*-back.tif
#	Compress layers
	convert $(tmp)/$*-fore.tif -transparent white -compress zip -format pdfa $(tmp)/$*-fore.pdf
	convert $(tmp)/$*-back.tif -compress jpeg2000 -define jp2:rate=0.001 -format pdfa $(tmp)/$*-back.pdf
#	jbig2 -s -p -b $(tmp)/$*-fore $(tmp)/$*-fore.tif
#	pdf.py $(tmp)/$*-fore | pdftk $(tmp)/$*-back.pdf multistamp - output $@
#	Merge layers
	pdftk $(tmp)/$*-back.pdf multistamp $(tmp)/$*-fore.pdf output $@
	rm $(tmp)/$*-
