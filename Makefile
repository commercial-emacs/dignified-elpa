SHELL := /bin/bash
EMACS ?= emacs
FILES =
ifeq ($(FILES),)
$(error FILES must be specified, e.g., make FILES="README foo.el" dist)
endif
ELSRC := $(filter %.el,$(FILES))
override FILES := $(ELSRC) $(filter-out $(ELSRC),$(FILES))
MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
INCEPTION := -L $(dir $(MAKEFILE)) -l package-inception

NAME_VERSION := $(shell $(EMACS) -batch $(INCEPTION) --eval "(princ (package-versioned-name \"$(firstword $(ELSRC))\"))" || { echo "ERROR" >&2; exit 1; })
ifeq ($(NAME_VERSION),)
$(error First elisp file must contain package headers)
endif

NAME := $(shell NAME_VERSION='$(NAME_VERSION)'; echo "$${NAME_VERSION%-*}")

.PHONY: dist-clean
dist-clean:
	rm -rf $(NAME_VERSION) $(NAME_VERSION).tar

.PHONY: dist
dist: dist-clean
	$(EMACS) -batch $(INCEPTION) \
	  --eval "(package-inception $(patsubst %,\"%\",$(FILES)))"
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
