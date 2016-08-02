include config.mk

QC_LOGS=$(wildcard $(WORKING_DIR)/*.log)

## ls           : testing permissions
.phony : ls
ls : 
	ls $(DATA_DIR)$(BFILE).bed

## QC           : run QC checks

## sexcheck     : remove subjects with errors in gender assignment in data
.PHONY : sexcheck
sexcheck : $(DATA_DIR)$(BFILE).bed
	mkdir -p $(WORKING_DIR)
	$(PLINK_EXE) --bfile $(DATA_DIR)$(BFILE) --check-sex --out $(WORKING_DIR)/sexcheck 
	awk '$$5 == "PROBLEM" { print }' $(WORKING_DIR)/sexcheck.sexcheck > $(WORKING_DIR)/sexcheck_problem
	$(PLINK_EXE) --bfile $(DATA_DIR)$(BFILE) --remove $(WORKING_DIR)/sexcheck_problem --make-bed --out $(WORKING_DIR)$(BFILE)_genderCorrected

## missing      : remove subjects with > 10% missing genotypes 
.PHONY : missing
missing : $(WORKING_DIR)$(BFILE)_genderCorrected.bed
	$(PLINK_EXE) --bfile $(WORKING_DIR)$(BFILE)_genderCorrected --mind 0.1 --make-bed --out $(WORKING_DIR)$(BFILE)_clean

## mendel       : remove related individuals using the -founder flag
.PHONY : mendel
mendel : $(WORKING_DIR)$(BFILE)_clean.bed
	$(PLINK_EXE) --bfile $(WORKING_DIR)$(BFILE)_clean --filter-founders --make-bed --out $(WORKING_DIR)$(BFILE)_mendel

## snps_missing : remove SNPs with high rate of missing genotypes
.PHONY : snps_missing
snps_missing : $(WORKING_DIR)$(BFILE)_mendel.bed
	$(PLINK_EXE) --bfile $(WORKING_DIR)$(BFILE)_mendel --geno 0.05 --make-bed --out $(WORKING_DIR)$(BFILE)_snpsMissing

## snps_HW      : remove SNPs out of Hardy-Weinberg equilibrium
.PHONY : snps_HW
snps_HW : $(WORKING_DIR)$(BFILE)_snpsMissing.bed
	$(PLINK_EXE) --bfile $(WORKING_DIR)$(BFILE)_snpsMissing --hwe 1E-4 --make-bed --out $(WORKING_DIR)$(BFILE)_snpsHW 

## MAF          : filter by minimum minor allele frequency
.PHONY : MAF
MAF : $(WORKING_DIR)$(BFILE)_snpsHW.bed
	$(PLINK_EXE) --bfile $(WORKING_DIR)$(BFILE)_snpsHW --maf 0.05 --make-bed --out $(WORKING_DIR)$(BFILE)_clean

## QC_logs      : move the QC log files to the WORKING_DIR/logs directory
.PHONY : QC_logs
QC_logs : $(QC_LOGS)
	mkdir -p $(WORKING_DIR)/logs/
	mv $(QC_LOGS) $(WORKING_DIR)/logs/

## variables    : Print variables.
.PHONY: variables
variables:
	@echo DATA_DIR: $(DATA_DIR)
	@echo WORKING_DIR: $(WORKING_DIR)
	@echo BFILE: $(BFILE)
	@echo PLINK_EXE: $(PLINK_EXE)
	@echo QC_LOGS: $(QC_LOGS)

.PHONY: help
help : Makefile
	@sed -n 's/^##//p' $<
