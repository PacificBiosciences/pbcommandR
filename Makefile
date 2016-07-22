.PHONY: build-tool-contracts

install:
	R -e "library(devtools); install()"

test:
	R -e "library(devtools); install(); test()"

doc:
	R -e "library(devtools); install(); document()"


emit-tool-contracts:
	#rm -rf tool-contracts/*.json
	Rscript bin/exampleHelloWorld.R  emit-tc tool-contracts
	Rscript bin/exampleReseqConditions.R emit-tc tool-contracts
