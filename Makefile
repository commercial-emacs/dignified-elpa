SHELL := /bin/bash
EMACS ?= emacs
FILES =
EXCLUDE =
ifeq ($(FILES),)
$(error FILES must be specified, e.g., make FILES="README foo*.el" dist)
endif

# FILES cannot be reassigned without clumsy `override`.  Use FILEZ.
FILEZ := $(shell ls -d $(FILES) 2>/dev/null)
FILEZ := $(filter-out $(EXCLUDE),$(FILEZ))
ELSRC := $(filter %.el,$(FILEZ))
ifeq ($(ELSRC),)
$(error No .el files found in FILES)
endif
FILEZ := $(ELSRC) $(filter-out $(ELSRC),$(FILEZ))
MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
INCEPTION := -L $(dir $(MAKEFILE)) -l package-inception

MAIN_FILE := $(shell \
	for f in $(ELSRC); do \
		if $(EMACS) -batch -l package --visit $$f -f package-buffer-info >/dev/null 2>&1 ; then\
			echo "$$f";\
			exit 0;\
		fi; \
	done; \
	)

ifeq ($(MAIN_FILE),)
$(error No elisp file contains valid package headers)
endif

FILEZ := $(MAIN_FILE) $(filter-out $(MAIN_FILE),$(FILEZ))

NAME_VERSION := $(shell 2>/dev/null $(EMACS) -batch $(INCEPTION) --eval "(princ (package-versioned-name \"$(MAIN_FILE)\"))")
ifeq ($(NAME_VERSION),)
$(error package-versioned-name failed on $(MAIN_FILE))
endif

.PHONY: dist-clean
dist-clean:
	rm -rf $(NAME_VERSION) $(NAME_VERSION).tar

.PHONY: dist
dist: dist-clean
	$(EMACS) -batch $(INCEPTION) \
	  --eval "(package-inception $(patsubst %,\"%\",$(FILEZ)))"
	tar cf $(NAME_VERSION).tar $(NAME_VERSION)

.PHONY: install
install:
	$(MAKE) -f $(MAKEFILE) dist
	$(EMACS) --batch -l package \
	  --eval "(setq package-user-dir (expand-file-name \"install\"))" \
	  --eval "(setq package-check-signature nil)" \
	  --eval "(package-initialize)" \
	  --eval "(package-refresh-contents nil)" \
	  --eval "(package-install-file \"$(NAME_VERSION).tar\")"
	# cp dignified-elpa.el install/$(NAME_VERSION)
	cd install/$(NAME_VERSION) ; for f in $(ELSRC); do b=$$(basename "$$f"); mv "$$b" ".$$b"; done
	tar -C install -cf install/$(NAME_VERSION).tar $(NAME_VERSION)
	$(MAKE) -f $(MAKEFILE) dist-clean
