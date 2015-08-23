.PHONY: build-tool-contracts

build-tool-contracts:
	Rscript bin/exampleHelloWorld.R  emit-tc tool-contracts/
