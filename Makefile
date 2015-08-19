pdf=$(wildcard *.pdf)
djvu=$(subst .pdf,.djvu,$(pdf))
dpi=300
ocrodjvu_options=-leng -j4 --in-place --on-error=resume

all:$(djvu)

.INTERMEDIATE: %/*.tif

%.djvu:%.tif
	mkdir -p $*
	tiffsplit $< $*/p-
	$(MAKE) -f ../didjvu.mk -C $* dpi=$(dpi) ext=tif
	didjvu bundle -p 20 -o $@ $*/*.djvu
	-ocrodjvu -etesseract $(ocrodjvu_options) $@ #|| ocrodjvu -egocr $(ocrodjvu_options) $@

%.tif:%.pdf
	gs -dNOPAUSE -q -r$(dpi) -dPDFFitPage -sPAPERSIZE=a4 -sDEVICE=tiff24nc -sCompression=lzw -dBATCH -sOutputFile=$@ $<


