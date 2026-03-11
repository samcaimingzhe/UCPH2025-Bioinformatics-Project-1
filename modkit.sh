fasta3='/home/vpm582/ref3.fa' 
############## MODKIT VIRION #################
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
    
    samtools sort "${bamfile}" -o "${SORTED_BAM}"
    samtools index "${SORTED_BAM}"

    modkit pileup \
        "${SORTED_BAM}" \
        "${PILEUP_BED}" \
        --reference ${fasta3} \
        --modified-bases m6A \
        --log-filepath pileup.log

    echo "Finished sample: ${SAMPLE_NAME}"
    echo "----------------------------------------"
done

############## MODKIT TOTAL ##################
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
  
    samtools sort "${bamfile}" -o "${SORTED_BAM}"
    samtools index "${SORTED_BAM}"

    modkit pileup \
        "${SORTED_BAM}" \
        "${PILEUP_BED}" \
        --modified-bases m6A \
	    --reference ${fasta3} \
        --log-filepath pileup.log

    echo "Finished sample: ${SAMPLE_NAME}"
    echo "----------------------------------------"
done

for bamfile in sorted_calls*.bam; do
    SAMPLE_NAME=$(basename "${bamfile}" .bam)
	OUT_BAM="filtered_${SAMPLE_NAME}.bam"

	modkit modbam call-mods ${bamfile} ${OUT_BAM} --filter-threshold A:0.9 --mod-threshold a:0.95
	
	modkit pileup \
        "${SORTED_BAM}" \
        "${PILEUP_BED}" \
        --modified-bases m6A \
	    --reference /home/vpm582/ref3.fa \
        --log-filepath pileup.log \
		--bgzf

    echo "Finished sample: ${SAMPLE_NAME}"
    echo "----------------------------------------"
done

for bamfile in filtered_*.bam; do
    SAMPLE_NAME=$(basename "${bamfile}" .bam)
	PILEUP_BED="pileup_${SAMPLE_NAME}.bed"

	OUT_BAM="${SAMPLE_NAME}.bam"
	SORTED_BAM="sorted_${SAMPLE_NAME}.bam"
    
    echo "Processing sample: ${SAMPLE_NAME}"
    echo "Input BAM:         ${bamfile}"
    echo "Sorted BAM:        ${SORTED_BAM}"
    echo "Pileup BED:        ${PILEUP_BED}"
  
    samtools sort "${bamfile}" -o "${SORTED_BAM}"
    samtools index "${SORTED_BAM}"

	modkit pileup \
        "${SORTED_BAM}" \
        "${PILEUP_BED}" \
        --modified-bases m6A \
	    --reference /home/vpm582/ref3.fa \
        --log-filepath pileup.log \
		--bgzf

    echo "Finished sample: ${SAMPLE_NAME}"
    echo "----------------------------------------"
done


