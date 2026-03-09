#!/bin/bash

# ==========================================
# 1. 只需要在这里修改样本名称
# ==========================================
SAMPLE_NAME="M4_9BEAMV"

# 定义基础路径（方便管理）
DATA_PATH="/projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/${SAMPLE_NAME}/*/*/pod5"
OUT_DIR="basecall_output_dir"

# ==========================================
# 2. 开始分析流程
# ==========================================

# Dorado Basecalling
dorado basecaller rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 ${DATA_PATH} \
        -x 'cuda:0,1,2' > ${OUT_DIR}/${SAMPLE_NAME}.bam

# 排序与索引
samtools sort ${OUT_DIR}/${SAMPLE_NAME}.bam -o ${OUT_DIR}/sorted_${SAMPLE_NAME}.bam
dorado summary ${OUT_DIR}/sorted_${SAMPLE_NAME}.bam > ${OUT_DIR}/${SAMPLE_NAME}.summary
samtools fastq ${OUT_DIR}/sorted_${SAMPLE_NAME}.bam > ${OUT_DIR}/${SAMPLE_NAME}.fastq

# 比对 (Minimap2)
mkdir -p newbam
minimap2 -ax splice -k 14 ref3.fa -t 25 --secondary=no ${OUT_DIR}/${SAMPLE_NAME}.fastq -o newbam/${SAMPLE_NAME}.sam

# SAM转BAM并过滤
samtools view -@ 30 -F 2048 -F 4 -b newbam/${SAMPLE_NAME}.sam | samtools sort -O BAM -@ 20 -o newbam/${SAMPLE_NAME}.bam
samtools index -@ 16 newbam/${SAMPLE_NAME}.bam

# 切分 BAM (Picard)
mkdir -p split_bam_dir
picard SplitSamByNumberOfReads INPUT=newbam/${SAMPLE_NAME}.bam SPLIT_TO_N_FILES=25 OUTPUT=split_bam_dir

# 为切分后的文件建立索引
for bam in split_bam_dir/*.bam; do
    samtools index "$bam" &
done
wait

# f5c 预处理
mkdir -p eventalign_output_dir
mkdir -p fast5_dir

pod5 convert to_fast5 ${DATA_PATH}/ --output fast5_dir/ --force-overwrite
f5c index --iop 10 -t 10 -d fast5_dir ${OUT_DIR}/${SAMPLE_NAME}.fastq

# Eventalign 并行处理
for file in split_bam_dir/*.bam; do
    filename=$(basename "$file" .bam)
    f5c eventalign -r ${OUT_DIR}/${SAMPLE_NAME}.fastq -b "$file" -g ref3.fa -t 15 \
        --pore rna002 --rna --scale-events --samples --signal-index \
        --summary eventalign_output_dir/${filename}_summary.txt \
        --print-read-names > eventalign_output_dir/${filename}_eventalign.txt &
done
wait

# 特征提取准备
mkdir -p tmp_features
mkdir -p features

for file in split_bam_dir/shard*bam; do
    bedtools bamtobed -i "$file" > "${file/.bam/.bed}" &
done
wait

# SingleMod 组织特征
# 注意：这里假设你的 shard 命名格式是固定的
for i in {0001..0025}; do
    shard_id="shard_${i}"
    python3 -u /home/vpm582/SingleMod/organize_from_eventalign.py -v 002 \
        -b split_bam_dir/${shard_id}.bed \
        -e eventalign_output_dir/${shard_id}_eventalign.txt \
        -o tmp_features -p ${shard_id} -s 500000 &
done
wait

# 汇总信息
cd tmp_features
wc -l *-extra_info.txt | sed 's/^ *//g' | sed '$d' | tr " " "\t" > extra_info.txt
cd ..

# m6A 预测
mkdir -p prediction
motifs=(AAACA AAACC AAACG AAACT AAATA AAATT AGACA AGACC AGACG AGACT AGATT ATACT CAACT CGACT CTACT GAACA GAACC GAACT GAATA GAATG GAATT GGACA GGACC GGACG GGACT GGATA GGATC GGATG GGATT GTACT TAACA TAACT TGACA TGACC TGACT TTACT)

for motif in "${motifs[@]}"; do
    python -u SingleMod/SingleMod_m6A_prediction.py -v 002 -d features -k $motif \
        -m models/RNA002/model_${motif}.pth.tar -g 0 -b 30000 -o prediction/${motif}_prediction.txt
done
