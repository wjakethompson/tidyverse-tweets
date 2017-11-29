#!/bin/bash
#MSUB -N tidytweet
#MSUB -l nodes=1:ppn=1:ib,walltime=00:00:2:00
#MSUB -l pmem=1gb
#MSUB -M tidytweet@gmail.com
#MSUB -m a
#MSUB -j oe
#MSUB -o tidytweet.log
#MSUB -q sixhour

cd $PBS_O_WORKDIR

R --vanilla -f tidyversetweets.R
