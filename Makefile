SHELL := /bin/bash
EMACS ?= emacs
FILES =
ifeq ($(FILES),)
$(error FILES must be specified, e.g., make FILES="foo.el foo-bar.el" dist)
endif
ELSRC := $(filter %.el,$(FILES))
FILES := $(ELSRC) $(filter-out $(ELSRC),$(FILES))

NAME_VERSION := $(shell $(EMACS) -batch -L . -l package-inception --eval "(princ (package-versioned-name \"$(firstword $(ELSRC))\"))")
ifeq ($(NAME_VERSION),)
$(error Failed to get package version from $(firstword $(ELSRC)))
endif

NAME := $(shell NAME_VERSION='$(NAME_VERSION)'; echo "$${NAME_VERSION%-*}")

.PHONY: dist-clean
dist-clean:
	rm -rf $(NAME_VERSION) $(NAME_VERSION).tar

.PHONY: dist
dist: dist-clean
	$(EMACS) -batch -L . -l package-inception \
	  --eval "(package-inception $(patsubst %,\"%\",$(FILES)))"
	tar cf $(NAME_VERSION).tar $(NAME_VERSION)

define install-recipe
	$(MAKE) dist
	( \
	set -e; \
	INSTALL_PATH=$(1); \
	if [[ "$${INSTALL_PATH}" == /* ]]; then INSTALL_PATH=\"$${INSTALL_PATH}\"; fi; \
	$(EMACS) --batch -l package --eval "(setq package-user-dir (expand-file-name $${INSTALL_PATH}))" \
	  -f package-initialize \
	  --eval "(ignore-errors (apply (function package-delete) (alist-get (quote $(NAME)) package-alist)))" \
	  -f package-refresh-contents \
	  --eval "(package-install-file \"$(NAME_VERSION).tar\")"; \
	PKG_DIR=`$(EMACS) -batch -l package --eval "(setq package-user-dir (expand-file-name $${INSTALL_PATH}))" -f package-initialize --eval "(princ (package-desc-dir (car (alist-get (quote $(NAME)) package-alist))))"`; \
	if [ -f "$${PKG_DIR}/Makefile" ]; then \
	  GIT_DIR=`git rev-parse --show-toplevel`/.git $(MAKE) -C $${PKG_DIR}; \
	fi; \
	)
	$(MAKE) dist-clean
endef

deps/archives/gnu/archive-contents: gnus-summarize.el
	$(call install-recipe,$(CURDIR)/deps)
	rm -rf deps/$(NAME)* # just keep deps

.PHONY: compile
compile: deps/archives/gnu/archive-contents
	$(EMACS) -batch --eval "(setq package-user-dir (expand-file-name \"deps\"))" \
	  -f package-initialize -L . -f batch-byte-compile $(ELSRC); \
	  (ret=$$? ; rm -f $(ELSRC:.el=.elc) && exit $$ret)
