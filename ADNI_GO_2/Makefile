include config.mk

QC_LOGS=$(wildcard $(QC_DIR)/*.log)

## QC            : run QC checks
.PHONY : QC
QC : sexcheck missing mendel snps_missing snps_HW MAF

## sexcheck      : remove subjects with errors in gender assignment in data
.PHONY : sexcheck
sexcheck : $(DATA_DIR)$(BFILE).bed
	mkdir -p $(QC_DIR)
	$(PLINK_EXE) --bfile $(DATA_DIR)$(BFILE) --check-sex --out $(QC_DIR)/sexcheck 
	awk '$$5 == "PROBLEM" { print }' $(QC_DIR)/sexcheck.sexcheck > $(QC_DIR)/sexcheck_problem
	$(PLINK_EXE) --bfile $(DATA_DIR)$(BFILE) --remove $(QC_DIR)/sexcheck_problem --make-bed --out $(QC_DIR)$(BFILE)_genderCorrected

## missing       : remove subjects with > 10% missing genotypes 
.PHONY : missing
missing : $(QC_DIR)$(BFILE)_genderCorrected.bed
	$(PLINK_EXE) --bfile $(QC_DIR)$(BFILE)_genderCorrected --mind 0.1 --make-bed --out $(QC_DIR)$(BFILE)_clean

## mendel        : remove related individuals using the -founder flag
.PHONY : mendel
mendel : $(QC_DIR)$(BFILE)_clean.bed
	$(PLINK_EXE) --bfile $(QC_DIR)$(BFILE)_clean --filter-founders --make-bed --out $(QC_DIR)$(BFILE)_mendel

## snps_missing  : remove SNPs with high rate of missing genotypes
.PHONY : snps_missing
snps_missing : $(QC_DIR)$(BFILE)_mendel.bed
	$(PLINK_EXE) --bfile $(QC_DIR)$(BFILE)_mendel --geno 0.05 --make-bed --out $(QC_DIR)$(BFILE)_snpsMissing

## snps_HW       : remove SNPs out of Hardy-Weinberg equilibrium
.PHONY : snps_HW
snps_HW : $(QC_DIR)$(BFILE)_snpsMissing.bed
	$(PLINK_EXE) --bfile $(QC_DIR)$(BFILE)_snpsMissing --hwe 1E-4 --make-bed --out $(QC_DIR)$(BFILE)_snpsHW 

## MAF           : filter by minimum minor allele frequency
.PHONY : MAF
MAF : $(QC_DIR)$(BFILE)_snpsHW.bed
	$(PLINK_EXE) --bfile $(QC_DIR)$(BFILE)_snpsHW --maf 0.05 --make-bed --out $(QC_DIR)$(BFILE)_clean

## QC_logs       : move the QC log files to the QC_DIR/logs directory
.PHONY : QC_logs
QC_logs : $(QC_LOGS)
	mkdir -p $(QC_DIR)/logs/
	mv $(QC_LOGS) $(QC_DIR)/logs/

## split         : split snp data by chromosome for prephasing
.PHONY : split
split : $(QC_DIR)$(BFILE)_clean.bed
	mkdir -p $(PREPHASE_DIR)
	./split_by_chromosome.sh $(PLINK_EXE) $(QC_DIR)$(BFILE)_clean $(PREPHASE_DIR)$(BFILE)_clean.chr

## test_prephase : prephase chromosome 21
.PHONY : test_prephase
test_prephase : $(PREPHASE_DIR)$(BFILE)_clean.chr21.ped
	$(SHAPEIT_EXE) -P $(PREPHASE_DIR)$(BFILE)_clean.chr21 \
	-M $(MAPFILE)21_combined_b37.txt \
	-O $(PREPHASE_DIR)$(BFILE)_clean.chr21.Phased.Output \
	-T 20 \
	-L $(PREPHASE_DIR)$(BFILE)_clean.chr21.Phased.Output.log

## test_vcf      : make .vcf file from prephased chromosome 21 data
.PHONY : test_vcf
test_vcf : $(PREPHASE_DIR)$(BFILE)_clean.chr21.Phased.Output.haps
	$(SHAPEIT_EXE) -convert \
	--input-haps $(PREPHASE_DIR)$(BFILE)_clean.chr21.Phased.Output \
	--output-vcf $(PREPHASE_DIR)$(BFILE)_clean.chr21.Phased.Output.vcf \
	-L $(PREPHASE_DIR)$(BFILE)_clean.chr21.Phased.Output.convert.log

## test_impute   : impute with Minimac3 NOTE: CHROMOSOME 21
.PHONY : test_impute
test_impute : $(PREPHASE_DIR)$(BFILE)_clean.chr21.Phased.Output.vcf
	mkdir -p $(IMPUTE_DIR)
	$(MINIMAC3_EXE) --refHaps $(REFHAP_PATH)1$(REFHAP_SUFFIX) \
	--haps $(PREPHASE_DIR)$(BFILE)_clean.chr21.Phased.Output.vcf \
	--prefix $(IMPUTE_DIR)$(BFILE)_clean.chr21.Imputed \
	--log \
	--chr 21

## prephase      : prephase a single chromosome -- requires CHR=## argument ("make prephase CHR=1")
.PHONY: prephase
prephase : $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).ped
	$(SHAPEIT_EXE) -P $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR) \
	-M $(MAPFILE)$(CHR)_combined_b37.txt \
	-O $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).Phased.Output \
	-T 20 \
	-L $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).Phased.Output.log \
	--exclude-snp $(EXCLUDE_FILE)

## vcf           : make .vcf file from prephased data -- requires CHR=## argument
.PHONY : vcf
vcf : $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).Phased.Output.haps
	$(SHAPEIT_EXE) -convert \
	--input-haps $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).Phased.Output \
	--output-vcf $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).Phased.Output.vcf \
	-L $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).Phased.Output.convert.log

## minimac       : impute with Minimac3 -- requires CHR=## argument
.PHONY : minimac
minimac : $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).Phased.Output.vcf
	mkdir -p $(IMPUTE_DIR)
	$(MINIMAC3_EXE) --refHaps $(REFHAP_PATH)$(CHR)$(REFHAP_SUFFIX) \
	--haps $(PREPHASE_DIR)$(BFILE)_clean.chr$(CHR).Phased.Output.vcf \
	--prefix $(IMPUTE_DIR)$(BFILE)_clean.chr$(CHR).Imputed \
	--log \
	--chr $(CHR)
	echo "Chromosome $(CHR) imputation finished" | mail -s "imputation done" $(EMAIL)



## impute        : prephase and impute for chromosome -- requires CHR=## argument (make impute CHR=1)
.PHONY : impute
impute : prephase vcf minimac

## variables     : Print variables.
.PHONY: variables
variables:
	@echo PLINK_EXE: $(PLINK_EXE)
	@echo SHAPEIT_EXE: $(SHAPEIT_EXE)
	@echo MINIMAC3_EXE: $(MINIMAC3_EXE)
	@echo BFILE: $(BFILE)
	@echo MAPFILE: $(MAPFILE)
	@echo REFHAPS: $(REFHAPS)
	@echo DATA_DIR: $(DATA_DIR)
	@echo QC_DIR: $(QC_DIR)
	@echo PREPHASE_DIR: $(PREPHASE_DIR)
	@echo IMPUTE_DIR: $(IMPUTE_DIR)
	@echo QC_LOGS: $(QC_LOGS)

.PHONY: help
help : Makefile
	@sed -n 's/^##//p' $<
