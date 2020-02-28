#!/bin/bash -l
cd ~/tidyverse-tweets
module load R rstan
R --vanilla -f submit-job.R
