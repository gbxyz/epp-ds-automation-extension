VERSION=00
DOC_NAME=draft-brown-epp-ds-automation-extension-$(VERSION)

pages: all

all: test

test:
	find examples -iname '*.xml' -exec xmllint --noout --schema xsd/test.xsd {} \;

all:
	gpp -x "-DDOC_NAME=$(DOC_NAME)" -o "$(DOC_NAME).md" draft.md
	kdrfc -ht "$(DOC_NAME).md"

pages:
	[ -d _site ] || mkdir -v _site
	cp -fv "$(DOC_NAME).html" _site/index.html
	cp -fv "$(DOC_NAME).xml" "$(DOC_NAME).txt" _site/

clean:
	rm -rfv $(DOC_NAME).* _site
