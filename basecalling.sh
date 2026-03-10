rm pod5*

wget https://raw.githubusercontent.com/samcaimingzhe/UCPH2025-Bioinformatics-Project-1/main/pod5_total.txt -O pod5_total.txt
wget https://raw.githubusercontent.com/samcaimingzhe/UCPH2025-Bioinformatics-Project-1/main/pod5_virion.txt -O pod5_virion.txt

export DORADO_MODELS_DIRECTORY="/home/vpm582/models"
fasta3="/home/vpm582/ref3.fa"
pod5_total="pod5_total.txt"
pod5_virion="pod5_virion.txt"
mod="inosine_m6A_2OmeA"
################### TOTAL ####################
pod5_total="pod5_total.txt"
while IFS= read -r pod5_total; do
    SAMPLE_NAME=$(dirname "$(dirname "$(dirname "$pod5_total")")")
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
################### VPM ####################
pod5_total="pod5_virion.txt"
while IFS= read -r pod5_total; do
    SAMPLE_NAME=$(dirname "$(dirname "$(dirname "$pod5_total")")")
    out_bam="calls_virion_${SAMPLE_NAME}.bam"

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
