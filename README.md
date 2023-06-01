### Scripts for generating normalized bedgraph files for the IGV plots displayed with the same scale.
 
mm10-blacklist.v2.bed : a bed file with black list regions for mm10

run_bamCoverage.config : a configuration file where you can set the normalization strategy as described for bamCoverage tool (default is “None”)

run_bamCoverage.sh: The actual script. It can be run like this:
```
sbatch ./run_bamCoverage.sh  /path/to/the/bam/file
```

