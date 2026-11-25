#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

input_dir="/home/gwlcardoso/1.Projects/phi_rnaseq/4.ASM_manuscript/2.filtered/ZC03"
output_dir="/home/gwlcardoso/1.Projects/phi_rnaseq/4.ASM_manuscript/3.mapping/PA14_ZC03"
index="/home/gwlcardoso/1.Projects/phi_rnaseq/4.ASM_manuscript/3.mapping/PA14_ZC03_index/PA14_ZC03"

mkdir -p "$output_dir"
r1_files=("$input_dir"/*_R1_fastp.fq.gz)

if ((${#r1_files[@]} == 0)); then
    printf 'No R1 files found in %s\n' "$input_dir" >&2
    exit 1
fi

for R1 in "${r1_files[@]}"; do
    sample="${R1##*/}"
    sample="${sample%_R1_fastp.fq.gz}"
    R2="$input_dir/${sample}_R2_fastp.fq.gz"

    if [[ ! -f "$R2" ]]; then
        printf 'Missing R2 for %s: %s\n' "$sample" "$R2" >&2
        exit 1
    fi

    printf 'Processing %s\n' "$sample"

    bowtie2 \
        --very-sensitive-local \
        -p 8 \
        -x "$index" \
        -1 "$R1" \
        -2 "$R2" \
        2> "$output_dir/${sample}_bowtie2.log" \
      | samtools sort -@ 4 \
          -o "$output_dir/${sample}.sorted.bam" -

    samtools index "$output_dir/${sample}.sorted.bam"
    samtools quickcheck -v "$output_dir/${sample}.sorted.bam"
done
