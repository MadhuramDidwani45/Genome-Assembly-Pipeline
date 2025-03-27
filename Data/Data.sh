#!/bin/bash
set -e

# Log file for data download output.
LOGFILE="data_download.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Define a logging function with a timestamp.
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

############################
# Start Data Download Script
############################
log "Data download script started."

############################
# Download SRA Data and Convert to FASTQ
############################
log "Step started: Prefetching SRR9620862..."
prefetch SRR9620862 --progress
log "Step complete: Prefetching done."

# Note: prefetch creates an SRR9620862 folder containing the SRR9620862.sra file.
log "Step started: Running fastq-dump to split FASTQ files..."
fastq-dump --split-files --outdir . SRR9620862/SRR9620862.sra
log "Step complete: fastq-dump finished."

############################
# Download Reference Genome and Annotation Files
############################
log "Step started: Downloading reference genome and annotation files..."
mkdir -p Reference_Genome
cd Reference_Genome
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_genomic.fna.gz -O reference_genome.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_genomic.gff.gz -O anno_reference_genome.gff.gz
cd ..
log "Step complete: Reference genome and annotation downloaded."

############################
# Data Download Script Complete
############################
log "Data download script complete."
