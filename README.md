# Genome Assembly Pipeline

This pipeline provides a comprehensive workflow for genome assembly and analysis, leveraging multiple bioinformatics tools to process raw sequencing data from the Sequence Read Archive (SRA).

## Pipeline Workflow

### 1. Data Retrieval
- Download sequencing data from SRA.
- Prefetch and convert SRA files to FASTQ format.

### 2. Quality Control
- Perform initial quality assessment using FastQC.
- Trim low-quality reads with Trimmomatic:
  - Standard trimming.
  - Crop reads to a specific length (250bp).
- Rerun quality control on trimmed reads.

### 3. Read Error Correction
- Use SPAdes for error correction of raw reads.

### 4. Genome Assembly
- Perform genome assembly using SPAdes:
  - Default assembly settings.
  - Careful mode with custom k-mer sizes.

### 5. Reference Genome
- Download reference genome and annotation files.

### 6. Assembly Evaluation
- Use QUAST to evaluate assembly quality.
- Compare different assembly strategies.

### 7. Genome Annotation
- Annotate assembled genome using Prokka.

## System Requirements

### Operating System
- Linux (Ubuntu recommended)

### Required Tools
- Bash
- SRA Toolkit
- FastQC
- Trimmomatic
- SPAdes
- QUAST
- Prokka
- wget

## Repository Structure
```
├── Data
│   ├── Data.sh
│   └── Readme.pdf
├── Docs
│   └── toolsandsteps.pdf
├── Environment
│   ├── Environment.yml
│   ├── Prokka_Environment.yml
│   └── Readme.pdf
├── Fastqc Analysis
│   ├── SRR9620862_1_fastqc.pdf
│   ├── SRR9620862_1_paired_fastqc.pdf
│   ├── SRR9620862_1_unpaired_fastqc.pdf
│   ├── SRR9620862_2_fastqc.pdf
│   ├── SRR9620862_2_paired_fastqc.pdf
│   └── SRR9620862_2_unpaired_fastqc.pdf
├── Pipeline
│   └── genome_assembly.sh
└── Result
    ├── annotation.tsv
    ├── annotation.txt
    ├── QUAST_full_report.pdf
    └── report.pdf
```


## Installation

### Dependencies
```bash
# Example installation commands using Conda
data
conda create -n genome_assembly -y
conda activate genome_assembly
conda install -c bioconda sra-tools fastqc trimmomatic spades quast prokka -y
```

## Usage

### Clone the Repository
```bash
git clone https://github.com/yourusername/genome-assembly-pipeline.git
cd genome-assembly-pipeline
```

### Run the Pipeline
```bash
chmod +x genome_assembly.sh
./genome_assembly.sh
```

## Pipeline Configuration
- Customize the SRA accession number in the script.
- Modify trimming parameters as needed.
- Adjust SPAdes assembly parameters for your specific use case.
