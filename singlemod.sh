dorado basecaller rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1 /projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/CONTROL_COLD_COL0MOCK/*/*/pod5 \
        -x 'cuda:0,1,2' > basecall_output_dir/CONTROL_COLD_COL0MOCK.bam
        
samtools sort basecall_output_dir/CONTROL_COLD_COL0MOCK.bam -o basecall_output_dir/sorted_CONTROL_COLD_COL0MOCK.bam
dorado summary basecall_output_dir/sorted_CONTROL_COLD_COL0MOCK.bam > basecall_output_dir/CONTROL_COLD_COL0MOCK.summary
samtools fastq basecall_output_dir/sorted_CONTROL_COLD_COL0MOCK.bam  > basecall_output_dir/CONTROL_COLD_COL0MOCK.fastq

mkdir -p newbam
minimap2 -ax splice -k 14 ref3.fa -t 25 --secondary=no basecall_output_dir/CONTROL_COLD_COL0MOCK.fastq -o newbam/CONTROL_COLD_COL0MOCK.sam

samtools view -@ 30 -F 2048 -F 4 -b newbam/CONTROL_COLD_COL0MOCK.sam | samtools sort -O BAM -@ 20  -o newbam/CONTROL_COLD_COL0MOCK.bam
samtools index -@ 16 newbam/CONTROL_COLD_COL0MOCK.bam

mkdir -p split_bam_dir
picard SplitSamByNumberOfReads INPUT=newbam/CONTROL_COLD_COL0MOCK.bam SPLIT_TO_N_FILES=25 OUTPUT=split_bam_dir

for bam in split_bam_dir/*bam
do
{
samtools index $bam
} &
done

mkdir -p eventalign_output_dir
mkdir -p fast5_dir

pod5 convert to_fast5 /projects/renlab/data/projects/projects_with_PB/AMV/nanopore_data/CONTROL_COLD_COL0MOCK/*/*/pod5/ --output fast5_dir/ --force-overwrite
f5c index --iop 10 -t 10 -d fast5_dir basecall_output_dir/CONTROL_COLD_COL0MOCK.fastq

for file in split_bam_dir/*.bam
do
{
info=(${file//// })
f5c eventalign -r basecall_output_dir/CONTROL_COLD_COL0MOCK.fastq -b $file -g ref3.fa -t 15 --pore rna002 --rna --scale-events --samples --signal-index --summary eventalign_output_dir/${info[-1]%%.bam}_summary.txt --print-read-names > eventalign_output_dir/${info[-1]%%.bam}_eventalign.txt
} &
done

mkdir -p tmp_features  
mkdir -p features
cd split_bam_dir

for file in shard*bam
do
{
bedtools bamtobed -i $file > ${file/.bam/.bed}
} &
done
wait
cd ..

batch=(shard_0001 shard_0002 shard_0003 shard_0004 shard_0005 shard_0006 shard_0007 shard_0008 shard_0009 shard_0010 shard_0011 shard_0012 shard_0013 shard_0014 shard_0015 shard_0016 shard_0017 shard_0018 shard_0019 shard_0020 shard_0021 shard_0022 shard_0023 shard_0024 shard_0025)
for i in ${batch[@]}
do
{
python3 -u /home/vpm582/SingleMod/organize_from_eventalign.py -v 002 -b split_bam_dir/${i}.bed -e eventalign_output_dir/${i}_eventalign.txt -o tmp_features -p $i -s 500000
} &
done
wait

cd tmp_features
wc -l *-extra_info.txt | sed 's/^ *//g' | sed '$d' | tr " " "\t"   > extra_info.txt
cd ..
mkdir -p prediction
for motif in AAACA AAACC AAACG AAACT AAATA AAATT AGACA AGACC AGACG AGACT AGATT ATACT CAACT CGACT CTACT GAACA GAACC GAACT GAATA GAATG GAATT GGACA GGACC GGACG GGACT GGATA GGATC GGATG GGATT GTACT TAACA TAACT TGACA TGACC TGACT TTACT
do
python -u SingleMod/SingleMod_m6A_prediction.py -v 002 -d features -k $motif -m models/RNA002/model_${motif}.pth.tar -g 0 -b 30000 -o prediction/${motif}_prediction.txt
done



