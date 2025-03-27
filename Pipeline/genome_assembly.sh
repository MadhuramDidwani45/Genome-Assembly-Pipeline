#!/bin/bash
set -e

# Log file for pipeline output.
LOGFILE="genome_assembly.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Define a logging function with a timestamp.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

###########################
# Start Genome Assembly Pipeline
###########################
log "Pipeline started: Genome assembly pipeline initiated."

###########################
# Prefetch and Fastq-dump
###########################
log "Step started: Prefetching SRR9620862..."
prefetch SRR9620862 --progress
log "Step complete: Prefetching done."

# Note: prefetch creates an SRR9620862 folder containing the file SRR9620862.sra.
log "Step started: Running fastq-dump to split FASTQ files..."
fastq-dump --split-files --outdir . SRR9620862/SRR9620862.sra
log "Step complete: fastq-dump finished."

###########################
# Quality Check: FastQC on Raw FASTQ Files
###########################
log "Step started: Running FastQC on raw FASTQ files..."
fastqc SRR9620862_1.fastq SRR9620862_2.fastq
log "Step complete: FastQC on raw files finished."

###########################
# Trimming Reads with Trimmomatic (Standard)
###########################
log "Step started: Creating directory for trimmed reads and running Trimmomatic (standard trimming)..."
mkdir Trimmed
cd Trimmed
trimmomatic PE ../SRR9620862_1.fastq ../SRR9620862_2.fastq \
    SRR9620862_1_paired.fastq SRR9620862_1_unpaired.fastq \
    SRR9620862_2_paired.fastq SRR9620862_2_unpaired.fastq \
    LEADING:10 TRAILING:10 SLIDINGWINDOW:5:20 MINLEN:250
log "Step complete: Standard Trimmomatic processing finished."

log "Step started: Running FastQC on trimmed FASTQ files (standard)..."
fastqc SRR9620862_1_paired.fastq SRR9620862_2_paired.fastq \
    SRR9620862_1_unpaired.fastq SRR9620862_2_unpaired.fastq
log "Step complete: FastQC on standard trimmed files finished."
cd ..

###########################
# Trimming Reads with Trimmomatic (Crop to 250bp)
###########################
log "Step started: Creating directory for cropped trimmed reads and running Trimmomatic..."
mkdir Trimmed_crop
cd Trimmed_crop
trimmomatic PE ../SRR9620862_1.fastq ../SRR9620862_2.fastq \
    SRR9620862_1_paired.fastq SRR9620862_1_unpaired.fastq \
    SRR9620862_2_paired.fastq SRR9620862_2_unpaired.fastq \
    CROP:250 LEADING:10 TRAILING:10 SLIDINGWINDOW:5:20 MINLEN:250
log "Step complete: Cropped Trimmomatic processing finished."

log "Step started: Running FastQC on cropped trimmed FASTQ files..."
fastqc SRR9620862_1_paired.fastq SRR9620862_2_paired.fastq \
    SRR9620862_1_unpaired.fastq SRR9620862_2_unpaired.fastq
log "Step complete: FastQC on cropped trimmed files finished."
cd ..


###########################
# SPAdes Error Correction
###########################
log "Step started: Running SPAdes error correction on FASTQ files..."
spades.py -1 SRR9620862_1.fastq -2 SRR9620862_2.fastq \
    -o spades_corrected --only-error-correction
log "Step complete: SPAdes error correction finished."


###########################
# SPAdes Assembly: Default Settings
###########################
log "Step started: Running SPAdes Assembly (default run)..."
spades.py -1 spades_corrected/corrected/SRR9620862_100.0_0.cor.fastq.gz \
    -2 spades_corrected/corrected/SRR9620862_200.0_0.cor.fastq.gz \
    -o spades_default_assembly -t 4 --only-assembler
log "Step complete: SPAdes default assembly finished."

###########################
# SPAdes Assembly: Careful Run with Specified k-mers
###########################
log "Step started: Running SPAdes Assembly (careful run with specified k-mers)..."
spades.py -k 21,33,55,77,99,127 --careful --only-assembler \
    -1 spades_corrected/corrected/SRR9620862_100.0_0.cor.fastq.gz \
    -2 spades_corrected/corrected/SRR9620862_200.0_0.cor.fastq.gz \
    -o spades_careful_assembly
log "Step complete: SPAdes careful assembly finished."

###########################
# Download Reference and Annotated Genomes
###########################
log "Step started: Downloading reference genome and annotation files..."
mkdir Reference_Genome
cd Reference_Genome
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_genomic.fna.gz -O reference_genome.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_genomic.gff.gz -O anno_reference_genome.gff.gz
cd ..
log "Step complete: Reference genome and annotation downloaded."

###########################
# Evaluate Assemblies with QUAST
###########################
log "Step started: Running QUAST evaluation..."
quast -o quast_SRR9620862_out \
    -R Reference_Genome/reference_genome.fna.gz \
    -g Reference_Genome/anno_reference_genome.gff.gz \
    --labels Spades_Default,Spades_Careful \
    spades_default_assembly/contigs.fasta \
    spades_careful_assembly/contigs.fasta
log "Step complete: QUAST evaluation finished."

###########################
# Annotate Assembly with Prokka
###########################
log "Step started: Annotating SPAdes default assembly using Prokka..."

# Create an output directory for Prokka annotations.
prokka_out="prokka_annotation"
mkdir -p ${prokka_out}

# Run Prokka on the SPAdes default assembly contigs with force option.
prokka --force --outdir ${prokka_out} --prefix annotation spades_default_assembly/contigs.fasta

log "Step complete: Prokka annotation finished."

###########################
# Pipeline Complete
###########################
log "Pipeline complete: Genome assembly pipeline finished successfully."
