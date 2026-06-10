DOC_NAME=draft-brown-epp-ds-automation-extension-00

all: test

test:
	@find examples -iname '*.xml' -exec xmllint --noout --schema xsd/test.xsd {} \;

all:
	@gpp -x "-DDOC_NAME=$(DOC_NAME)" draft.md -o "$(DOC_NAME).md"
	@kdrfc -ht $(DOC_NAME).md
