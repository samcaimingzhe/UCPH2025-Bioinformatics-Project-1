export DORADO_MODELS_DIRECTORY="/home/vpm582/models"
fasta3="/home/vpm582/ref3.fa"
pod5_total="pod5_total.txt"
pod5_virion="pod5_virion.txt"
mod="inosine_m6A_2OmeA"
##############################################
################### TOTAL ####################
##############################################
while IFS= read -r pod5_total; do
    SAMPLE_NAME=$(basename "$(dirname "$(dirname "$pod5_total")")")

    out_bam="calls_total_${SAMPLE_NAME}.bam"

    echo "Processing sample: ${SAMPLE_NAME}"
    echo "Input POD5 dir:   ${pod5_total}"
    echo "Output BAM:       ${out_bam}"
    echo

    dorado basecaller rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 "${pod5_total}/" \
      -x cuda:0,1,2 \
      --reference "${fasta3}" \
      --recursive \
      --verbose \
      --modified-bases ${mod} \
      > "${out_bam}"
done < "${pod5_total}"
##############################################
################## VIRION ####################
##############################################
while IFS= read -r pod5_virion; do
    SAMPLE_NAME=$(basename "$(dirname "$(dirname "$pod5_virion")")")

    out_bam="calls_virion_${SAMPLE_NAME}.bam"

    echo "Processing sample: ${SAMPLE_NAME}"
    echo "Input POD5 dir:   ${pod5_virion}"
    echo "Output BAM:       ${out_bam}"
    echo

    dorado basecaller rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 "${pod5_virion}/" \
      -x cuda:0,1,2 \
      --reference "${fasta3}" \
      --recursive \
      --verbose \
      --modified-bases ${mod} \
      > "${out_bam}"
done < "${pod5_virion}"

##############################################
############## MODKIT VIRION #################
##############################################
for bamfile in calls_virion_*.bam; do
    SAMPLE_NAME=$(basename "${bamfile}" .bam)
    SAMPLE_NAME=${SAMPLE_NAME#calls_virion_}

    SORTED_BAM="sorted_calls_virion_${SAMPLE_NAME}.bam"
    PILEUP_BED="pileup_virion_${SAMPLE_NAME}.bed"
    EXTRACT_BED="extract_virion_${SAMPLE_NAME}.bed"
    
    echo "Processing sample: ${SAMPLE_NAME}"
    echo "Input BAM:         ${bamfile}"
    echo "Sorted BAM:        ${SORTED_BAM}"
    echo "Pileup BED:        ${PILEUP_BED}"
    echo
    
    # 1. Get summary of reads
    #dorado summary "${bamfile}" > summary_reads_virion_${SAMPLE_NAME}.tsv
    # 2. Sort the BAM
    samtools sort "${bamfile}" -o "${SORTED_BAM}"
    # 3. Index the sorted BAM
    samtools index "${SORTED_BAM}"

    # 4. Run modkit pileup
    modkit pileup \
        "${SORTED_BAM}" \
        "${PILEUP_BED}" \
        --reference ${fasta3} \
        --modified-bases m6A \
        --log-filepath pileup.log

    echo "Finished sample: ${SAMPLE_NAME}"
    echo "----------------------------------------"
done
##############################################

##############################################
############## MODKIT TOTAL ##################
##############################################
for bamfile in calls_total_*.bam; do
    SAMPLE_NAME=$(basename "${bamfile}" .bam)
    SAMPLE_NAME=${SAMPLE_NAME#calls_total_}

    SORTED_BAM="sorted_calls_total_${SAMPLE_NAME}.bam"
    PILEUP_BED="pileup_total_${SAMPLE_NAME}.bed"
    EXTRACT_BED="extract_total_${SAMPLE_NAME}.bed"
    
    echo "Processing sample: ${SAMPLE_NAME}"
    echo "Input BAM:         ${bamfile}"
    echo "Sorted BAM:        ${SORTED_BAM}"
    echo "Pileup BED:        ${PILEUP_BED}"
    echo
    
    # 1. Get summary of reads
    # dorado summary "${bamfile}" > summary_reads_total_${SAMPLE_NAME}.tsv
    # 2. Sort the BAM
    samtools sort "${bamfile}" -o "${SORTED_BAM}"
    # 3. Index the sorted BAM
    samtools index "${SORTED_BAM}"

    # 4. Run modkit pileup
    modkit pileup \
        "${SORTED_BAM}" \
        "${PILEUP_BED}" \
        --modified-bases m6A \
	    --reference ${fasta3} \
        --log-filepath pileup.log

    echo "Finished sample: ${SAMPLE_NAME}"
    echo "----------------------------------------"
done
