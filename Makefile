#
# Neotonic Source Kit
#
# Copyright (C) 2001 Neotonic and Brandon Long
#
#

NEOTONIC_ROOT = ./

include rules.mk

SUBDIRS = util cs cgi $(BUILD_WRAPPERS)

OUTDIRS = bin libs

# These are blank here... but populated under automated build
VERSION =
RELEASE =

all: cs $(BUILD_WRAPPERS)

rules.mk: configure
	./configure

configure: configure.in
	./autogen.sh

cs: output_dir
	@for mdir in $(SUBDIRS); do \
	  if test -d $$mdir; then \
	    if test -f $$mdir/Makefile.PL -a ! -f $$mdir/Makefile; then \
	      cd $$mdir; $(PERL) Makefile.PL; cd ..; \
	    fi; \
	    $(MAKE) -C $$mdir; \
	  fi; \
	done

depend:
	@for mdir in $(SUBDIRS); do \
	  if test ! -f $$mdir/Makefile.PL; then \
	    $(MAKE) -C $$mdir depend; \
	  fi; \
	done

newdepend: killdepend
	@echo "*******************************************"
	@echo "** Building dependencies..."
	@for mdir in $(SUBDIRS); \
		do $(MAKE) -C $$mdir depend; \
	done

killdepend:
	@echo "*******************************************"
	@echo "** Removing Old dependencies..."
	@find . -name "Makefile.depends" -print | $(XARGS) rm %

.PHONY: man
man:
	@mkdir -p man/man3
	@for mdir in $(SUBDIRS); do \
		scripts/document.py --owner "Neotonic, Inc." --outdir man/man3/ $$mdir/*.h; \
	done

.PHONY: hdf
hdf:
	@mkdir -p docs/hdf
	@for mdir in $(SUBDIRS); do \
		scripts/document.py --hdf --owner "Neotonic, Inc." --outdir docs/hdf/ $$mdir/*.h; \
	done

changelog:
	rcs2log -v | cat - ChangeLog | sed -e "s/\/b2\/src\/cvsroot\/neotonic\///g" > ChangeLog.$$$$ && mv ChangeLog.$$$$ ChangeLog

clean:
	@for mdir in $(SUBDIRS); do \
	  $(MAKE) -C $$mdir clean; \
	done

distclean:
	@for mdir in $(SUBDIRS); do \
	  $(MAKE) -C $$mdir distclean; \
	done
	@for mdir in $(OUTDIRS); do \
		rm -rf $$mdir/*; \
	done
	rm -f config.cache config.log config.status rules.mk cs_config.h

output_dir:
	@for mdir in $(OUTDIRS); do \
		mkdir -p $$mdir; \
	done

CS_DISTDIR = clearsilver-0.8.0
CS_LABEL = CLEARSILVER-0_8_0
CS_FILES = LICENSE CS_LICENSE rules.mk Makefile util cs cgi python scripts mod_ecs imd java-jni perl
cs_dist:
	rm -rf $(CS_DISTDIR)
	cvs -q tag -F $(CS_LABEL) $(CS_FILES)
	mkdir -p $(CS_DISTDIR)
	cvs -z3 -q export -r $(CS_LABEL) -d $(CS_DISTDIR) neotonic
	-rm -rf $(CS_DISTDIR)/CVS
	$(MAKE) -C $(CS_DISTDIR) man
	tar chozf $(CS_DISTDIR).tar.gz $(CS_DISTDIR)

TRAKKEN_DISTDIR = trakken-0.55
TRAKKEN_LABEL = TRAKKEN_0_55
trakken_dist:
	rm -rf $(TRAKKEN_DISTDIR)
	cvs -q tag -F $(TRAKKEN_LABEL)
	mkdir -p $(TRAKKEN_DISTDIR)
	cvs -z3 -q export -r $(TRAKKEN_LABEL) -d $(TRAKKEN_DISTDIR) neotonic
	tar chozf $(TRAKKEN_DISTDIR).tar.gz $(TRAKKEN_DISTDIR)

trakken: cs
	$(MAKE) -C retrieve
	$(MAKE) VERSION=$(VERSION) RELEASE=$(RELEASE) -C trakken
