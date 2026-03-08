# 创建临时目录
mkdir -p fast5_temp

# 运行转换（修正了 COLD 拼写，并使用星号匹配）
pod5 convert to_fast5 \
    /projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/CONTROL_COLD_COL0MOCK/CONTROL_COLD_COL0MOCK/*/pod5/ \
    --output fast5_temp/

samtools fastq processed_data/CONTROL_COLD_COL0MOCK/CONTROL_COLD_COL0MOCK.bam > fastq/CONTROL_COLD_COL0MOCK.fastq

f5c index --iop 10 -d fast5_temp/ fastq/CONTROL_COLD_COL0MOCK.fastq

# 1. 确保输出目录存在
mkdir -p eventalign_output_dir

# 2. 运行 f5c eventalign
# 注意：我们使用的是你之前确定的参考基因组路径 /home/vpm582/ref3.fa
f5c eventalign \
    --iop 64 \
    -r fastq/CONTROL_COLD_COL0MOCK.fastq \
    -b processed_data/CONTROL_COLD_COL0MOCK/CONTROL_COLD_COL0MOCK.bam \
    -g /home/vpm582/ref3.fa \
    -t 15 \
    --rna --scale-events --samples --signal-index \
    --summary eventalign_output_dir/CONTROL_COLD_COL0MOCK_summary.txt \
    --print-read-names \
    > eventalign_output_dir/CONTROL_COLD_COL0MOCK_eventalign.txt

mkdir tmp_features  
mkdir features
cd split_bam_dir

#convert bam to bed to extract strand informationt
for file in shard*bam
do
{
bedtools bamtobed -i $file > ${file/.bam/.bed}
} &
done
wait

#running parallelly
batch=(shard_0001 shard_0002 shard_0003 shard_0004 shard_0005 shard_0006 shard_0007 shard_0008 shard_0009 shard_0010 shard_0011 shard_0012 shard_0013 shard_0014 shard_0015 shard_0016 shard_0017 shard_0018 shard_0019 shard_0020 shard_0021 shard_0022 shard_0023 shard_0024 shard_0025)
for i in ${batch[@]}
do
{
python -u SingleMod/organize_from_eventalign.py -v 002|004 -b split_bam_dir/${i}.bed -e eventalign_output_dir/${i}_eventalign.txt -o tmp_features -p $i -s 500000
} &
done
wait

cd tmp_features #required step
wc -l *-extra_info.txt | sed 's/^ *//g' | sed '$d' | tr " " "\t"   > extra_info.txt

python -u SingleMod/merge_motif_npy.py -v 002|004 -d tmp_features -s 500000 -o features
