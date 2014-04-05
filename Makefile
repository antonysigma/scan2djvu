pdf=$(wildcard *.pdf)
djvu=$(subst .pdf,.djvu,$(pdf))
dpi=600

all:$(djvu)

.INTERMEDIATE: %/*.tif

%.djvu:%.tif
	mkdir -p $*
	tiffsplit $< $*/p-
	$(MAKE) -f ../didjvu.mk -C $* dpi=$(dpi) ext=tif
	djvm -c $@ $*/*.djvu
	-ocrodjvu -etesseract -leng --in-place $@

%.tif:%.pdf
	gs -dNOPAUSE -q -r$(dpi) -dPDFFitPage -sPAPERSIZE=a4 -sDEVICE=tiff24nc -sCompression=lzw -dBATCH -sOutputFile=$@ $<


