export DORADO_MODELS_DIRECTORY="/home/vpm582/models"
ref_seq="/home/vpm582/ref3.fa"
################### TOTAL ####################
pod5="pod5_total.txt"
while IFS= read -r pod5; 
do
    SAMPLE_NAME=$(dirname "$(dirname "$(dirname "$pod5")")")")
    out_bam="total_${SAMPLE_NAME}.bam"
    echo "POD5 Dir:    ${pod5}"
    echo "Sample Name: ${SAMPLE_NAME}"
    echo "Output BAM:  ${out_bam}"
    dorado basecaller rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 "${pod5}/" \
      -x cuda:0,1,2 \
      --reference "${ref_seq}" \
      --recursive \
      --verbose \
      > "${out_bam}"
done < "${pod5}"

################## VIRION ####################
pod5="pod5_virion.txt"
while IFS= read -r pod5; 
do
    SAMPLE_NAME=$(dirname "$(dirname "$(dirname "$pod5")")")")
    out_bam="vp_${SAMPLE_NAME}.bam"
    echo "POD5 Dir:    ${pod5}"
    echo "Sample Name: ${SAMPLE_NAME}"
    echo "Output BAM:  ${out_bam}"
    dorado basecaller rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 "${pod5}/" \
      -x cuda:0,1,2 \
      --reference "${ref_seq}" \
      --recursive \
      --verbose \
      > "${out_bam}"
done < "${pod5}"

############## MODKIT TOTAL ##################
for bamfile in total_*.bam; do
    SAMPLE_NAME=$(basename "${bamfile}".bam)
	
    SORTED_BAM="sorted_${SAMPLE_NAME}.bam"
    PILEUP_BED="pileup_${SAMPLE_NAME}.bed"

    echo "Input BAM:  ${bamfile}"
    echo "Sorted BAM: ${SORTED_BAM}"
    echo "Pileup BED: ${PILEUP_BED}"
    
    dorado summary "${bamfile}" > summary_${SAMPLE_NAME}.tsv
    samtools sort "${bamfile}" -o "${SORTED_BAM}"
    samtools index "${SORTED_BAM}"

    modkit pileup \
        "${SORTED_BAM}" \
        "${PILEUP_BED}" \
        --reference ${ref_seq} \
        --modified-bases m6A \
        --log-filepath pileup.log \

    echo "Finished sample: ${SAMPLE_NAME}"
    echo "----------------------------------------"
done

############## MODKIT VIRION #################
for bamfile in vp_*.bam; do
    SAMPLE_NAME=$(basename "${bamfile}".bam)
	
    SORTED_BAM="sorted_${SAMPLE_NAME}.bam"
    PILEUP_BED="pileup_${SAMPLE_NAME}.bed"

    echo "Input BAM:  ${bamfile}"
    echo "Sorted BAM: ${SORTED_BAM}"
    echo "Pileup BED: ${PILEUP_BED}"
    
    dorado summary "${bamfile}" > summary_${SAMPLE_NAME}.tsv
    samtools sort "${bamfile}" -o "${SORTED_BAM}"
    samtools index "${SORTED_BAM}"

    modkit pileup \
        "${SORTED_BAM}" \
        "${PILEUP_BED}" \
        --reference ${ref_seq} \
        --modified-bases m6A \
        --log-filepath pileup.log \

    echo "Finished sample: ${SAMPLE_NAME}"
    echo "----------------------------------------"
done

