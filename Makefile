.PHONY: build-tool-contracts

emit-tool-contracts:
	rm -rf tool-contracts/*.json
	Rscript bin/exampleHelloWorld.R  emit-tc tool-contracts
	Rscript bin/exampleReseqConditions.R emit-tc tool-contracts
	Rscript bin/exampleAccuracyDensityPlot.R emit-tc tool-contracts
