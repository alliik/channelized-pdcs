#!/bin/bash 

rm *.LOG
rm *.RES
rm TOPO*
label=${PWD##*/}
subm=$(sbatch submission.sh)
jobid=${subm:20}

echo -e "$datum $label $subm" >> status.txt
echo -e "$datum $label $subm" >> ~/myprojects/channelized-pdcs/status_all.txt

#strigger --set --jobid=$jobid --time \
#       --program=/home/akubo/myprojects/channelized-pdcs/somescripts/trigger.sh

#sleep 25m
#runlength=$(wc -l run.out)
#length=${runlength:0:3}

#good=699
#echo $length

#if [ "$length" -lt 699  ]; then
#        scancel $jobid
#        echo "simulation not running correct. Paused at $length" | mail -s "$jobid stalled" akubo@uoregon.edu

#fi

