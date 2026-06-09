DOC_NAME=draft-brown-epp-ds-automation-extension-00

all:
	gpp draft.md > $(DOC_NAME).md
	kdrfc -ht $(DOC_NAME).md