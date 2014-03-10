pdf=$(wildcard *.pdf)
djvu=$(subst .pdf,.djvu,$(pdf))
dpi=600

all:$(djvu)

%.djvu:%.pdf
	mkdir -p $*
	gs -dNOPAUSE -q -r$(dpi) -dPDFFitPage -sPAPERSIZE=a4 -sDEVICE=tiff24nc -sCompression=lzw -dBATCH -sOutputFile=$*/$<.tif $<
	tiffsplit $*/$<.tif $*/p-
	rm $*/$<.tif
	$(MAKE) -f didjvu.mk prefix=$* dpi=$(dpi)
	rm -r $*

