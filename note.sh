
mkdir -p fastq
samtools fastq processed_data/M1_COL0AMV/M1_COL0AMV.bam > fastq/M1_COL0AMV.fastq
samtools index -@ 16 processed_data/M1_COL0AMV/M1_COL0AMV.bam

mkdir -p split_bam_dir 
picard SplitSamByNumberOfReads \
      INPUT=processed_data/M1_COL0AMV/M1_COL0AMV.bam \
      SPLIT_TO_N_FILES=25 \
      OUTPUT=split_bam_dir \
      VALIDATION_STRINGENCY=LENIENT

for bam in split_bam_dir/*bam
do
{
samtools index $bam
} &
done

mkdir -p eventalign_output_dir
mkdir -p fast5_dir
pod5 convert to_fast5 /projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/M1_COL0AMV/M1_COL0_AMV/*/pod5/*.pod5 --output fast5_dir/ --threads 20 --force-overwrite


for file in split_bam_dir/*.bam
do
{
info=(${file//// })
f5c eventalign -r fastq/M1_COL0AMV.fastq -b $file \
               -g /home/vpm582/ref3.fa \
               -t 15 --pore rna004 --rna --scale-events --samples --signal-index \
               --summarcdy eventalign_output_dir/${info[-1]%%.bam}_summary.txt \
               --print-read-names > eventalign_output_dir/${info[-1]%%.bam}_eventalign.txt
} &
done

mkdir -p tmp_features  
mkdir -p features

cd split_bam_dir
#convert bam to bed to extract strand informationt
for file in shard*bam
do
{
bedtools bamtobed -i $file > ${file/.bam/.bed}
} &
done

wait

cd ..

#running parallelly
batch=(shard_0001 shard_0002 shard_0003 shard_0004 shard_0005 shard_0006 shard_0007 shard_0008 shard_0009 shard_0010 shard_0011 shard_0012 shard_0013 shard_0014 shard_0015 shard_0016 shard_0017 shard_0018 shard_0019 shard_0020 shard_0021 shard_0022 shard_0023 shard_0024 shard_0025)
for i in ${batch[@]}
do
{
python -u SingleMod/organize_from_eventalign.py -v 004 -b split_bam_dir/${i}.bed -e eventalign_output_dir/${i}_eventalign.txt -o tmp_features -p $i -s 500000
} &
done
wait
cd tmp_features #required step
wc -l *-extra_info.txt | sed 's/^ *//g' | sed '$d' | tr " " "\t"   > extra_info.txt

python -u SingleMod/merge_motif_npy.py -v 004 -d tmp_features -s 500000 -o features
