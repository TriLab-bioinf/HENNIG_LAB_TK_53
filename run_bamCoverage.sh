#!/usr/bin/bash
#SBATCH --partition=quick --cpus-per-task=16 --mem=32g 

set -o errexit

USAGE='$0 <BAM file > [<bamCoverage normailzation method, default=None>]' 

if [[ -z $1 ]]; then
    echo
    echo ${USAGE}
    echo
fi

source run_bamCoverage.config

BAM=$1
NORMALIZATION=${NORM}
FILENAME=$(basename ${BAM})
SAMPLE=$(basename "${FILENAME%_L0*}")
OUTDIR=deepTools_${NORMALIZATION}
LOG=./${OUTDIR}/${SAMPLE}.RPKM.bamCoverage.log
BEDGRAPH=./${OUTDIR}/${SAMPLE}.${NORMALIZATION}.bedGraph

# Check if black list was provided
if [[ ${BLACKLIST} != "None" ]]; then
    BL_OPTION="--blackListFileName ${BLACKLIST}"
else
    BL_OPTION=""    
fi        

if [[ ! -d ${OUTDIR} ]]; then
    mkdir -m 777 ${OUTDIR}
fi    

module load deeptools

echo "### Running bam Coverage ###" 
bamCoverage -b ${BAM} \
         -o ${BEDGRAPH} \
         --outFileFormat bedgraph \
         --normalizeUsing ${NORMALIZATION} \
         --binSize 5 \
         --smoothLength 15 \
         -p 14 ${BL_OPTION} \
         --effectiveGenomeSize 2150570000 > ${LOG} 2>&1

# Calculate top-1000 mean peak height
echo "### Estimating mean peak height ###"
MEAN=$(cut -f 4 ${BEDGRAPH} | \
        sort -n | \
        tail -1000 | \
        perl -e 'while(<>){chomp;$c++; $s+=$_}; $m=$s/$c; print "$m\n"')

# Calculate relative peak height based on MEAN
echo "### Normalizing based on mean peak height ###"
cat ${BEDGRAPH}|perl -ne 'chomp;@x=split /\t/;$x[3]=$x[3]*100/'${MEAN}';print join("\t",@x)."\n"' > ./${OUTDIR}/${SAMPLE}.${NORMALIZATION}.1000Mean.bedGraph

echo "### DONE!! ###"



