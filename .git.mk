ifndef .git.mk
.git.mk := $(abspath $(lastword $(MAKEFILE_LIST)))

include $(dir $(.git.mk))/.config.mk

gpg := $(shell which gpg || /bin/gpg)
$(gpg):
	$(if $(gpg),,$(error "please install gpg: https://blog.ghostinthemachines.com/2015/03/01/how-to-use-gpg-command-line/"))

git.secret := $(shell which git-secret || /bin/git-secret)
$(git.secret): $(gpg)
	$(if $(git.secret),,$(error "please install git-secret: https://git-secret.io/installation"))

.PHONY: git.hooks
git.hooks := $(shell cat .git/config | grep 'hooksPath' 1>/dev/null || ls .githooks)
ifdef git.hooks
git.hooks:
	git config --local core.hooksPath .githooks
$(git.hooks): git.hooks
endif

.PHONY: git.submodule
git.submodule := $(shell cat .gitmodules | grep path | cut -d '=' -f 2)
ifdef git.submodule
git.submodule:
	git submodule update --init --recursive
$(git.submodule): git.submodule
endif

.PHONY: git.deps
git.deps := $(git.secret) $(git.hooks) $(git.submodule)
git.deps: $(git.deps)

.PHONY: git.secret.hide
git.secret.hide: git.deps
	git secret hide -Pm || true
	git add $$(git secret list | sed 's/\(.*\)/\1.secret/g')

.PHONY: git.secret.reveal
git.secret.reveal := $(shell find . -type f -name '*.secret')
ifdef git.secret.reveal
$(git.secret.reveal): git.deps
	rm -rf $@
	git secret reveal $@
	chmod 400 $@
endif
git.secret.reveal: $(git.secret.reveal)

.PHONY: git.all
git.all: git.deps git.secret.reveal

endif # .git.mk
