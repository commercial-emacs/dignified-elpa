SHELL := /bin/bash
EMACS ?= emacs
FILES =
ifeq ($(FILES),)
$(error FILES must be specified, e.g., make FILES="foo.el foo-bar.el" dist)
endif
ELSRC := $(filter %.el,$(FILES))
FILES := $(ELSRC) $(filter-out $(ELSRC),$(FILES))
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
	$(EMACS) --batch -l package --eval "(setq package-user-dir (expand-file-name \"install\"))" \
	  -f package-initialize \
	  --eval "(ignore-errors (apply (function package-delete) (alist-get (quote $(NAME)) package-alist)))" \
	  -f package-refresh-contents \
	  --eval "(package-install-file \"$(NAME_VERSION).tar\")"
	cd install/$(NAME_VERSION) ; rm -f $(ELSRC)
	if [ -f "install/$(NAME_VERSION)/Makefile" ]; then \
	  GIT_DIR=`git rev-parse --show-toplevel`/.git $(MAKE) -C install/$(NAME_VERSION); \
	fi
	tar cf install/$(NAME_VERSION).tar install/$(NAME_VERSION)
	$(MAKE) -f $(MAKEFILE) dist-clean
