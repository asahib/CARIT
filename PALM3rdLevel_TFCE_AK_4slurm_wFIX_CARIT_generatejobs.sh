#!/bin/bash

#SBATCH -J PALM_PPI
#SBATCH -o PALM_PPI


module unload fsl
module load fsl/6.0.1


hcpdir="/nafs/narr/HCP_OUTPUT"
maindir="/nafs/narr/asahib"
copeList="cope6"
#copeList="cope5"

#GroupList="KTP1_HC"
GroupList="RemitvsNonremit_base"

for g in ${GroupList}
do
	
	for con in ${copeList}
	do
    		echo "sbatch --nodes=1 --ntasks=1 --cpus-per-task=1 --mem=30G --time=7-00:00:00 \
--job-name=C${g} --output=/nafs/narr/asahib/Task_fmri/CARIT/PALM_${con}_${g}.log --export=COPE=${con},group=${g} /nafs/narr/asahib/Task_fmri/CARIT/PALM3rdLevel_TFCE_JL_4slurm_wFIX_CARIT.sh"
   
		sbatch --nodes=1 --ntasks=1 --cpus-per-task=1 --mem=30G --time=5-00:00:00 \
--job-name=C${g} --output=/nafs/narr/asahib/Task_fmri/CARIT/KTP1_KTP3/RemitvsNonremit_base/PALM_${con}_${g}.log --export=COPE=${con},group=${g} /nafs/narr/asahib/Task_fmri/CARIT/KTP1_KTP3/RemitvsNonremit_base/PALM_remission_base.sh
		
	done
done

echo "finished"
