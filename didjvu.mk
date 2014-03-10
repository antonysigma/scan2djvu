SHELL:=/bin/bash

prefix=out
dpi=600

djvu_pages=$(subst .tif,.djvu,$(wildcard $(prefix)/*.tif))

all:$(prefix).djvu

$(prefix).djvu:$(djvu_pages)
	djvm -c $@ $^
#	ocrodjvu -j4 -etesseract -leng --in-place $@

$(djvu_pages):%.djvu:%.tif
	mogrify -trim -normalize -compress lzw $<
	didjvu encode --loss-level 200 -m djvu -d $(dpi) $< -o $@
