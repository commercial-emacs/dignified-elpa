SHELL := /bin/bash
EMACS ?= emacs
FILES =
ifeq ($(FILES),)
$(error FILES must be specified, e.g., make FILES="README foo.el" dist)
endif
ELSRC := $(filter %.el,$(FILES))
override FILES := $(ELSRC) $(filter-out $(ELSRC),$(FILES))
# The readme set used by package--get-description
README_SET := README-elpa README-elpa.md README README.rst README.org
README_FILES := $(filter $(README_SET),$(FILES))
ifeq ($(README_FILES),)
$(error FILES must include one of: $(README_SET))
endif
MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
INCEPTION := -L $(dir $(MAKEFILE)) -l package-inception

NAME_VERSION := $(shell $(EMACS) -batch $(INCEPTION) --eval "(princ (package-versioned-name \"$(firstword $(ELSRC))\"))")
ifeq ($(NAME_VERSION),)
$(error Failed to get package version from $(firstword $(ELSRC)))
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
	if [ -f "install/$(NAME_VERSION)/Makefile" ]; then \
	  GIT_DIR=`git rev-parse --show-toplevel`/.git $(MAKE) -C install/$(NAME_VERSION); \
	fi
	cd install/$(NAME_VERSION) ; for f in $(ELSRC); do mv "$$f" ".$$f"; done
	tar -C install -cf install/$(NAME_VERSION).tar $(NAME_VERSION)
	$(MAKE) -f $(MAKEFILE) dist-clean
