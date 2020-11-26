#!/bin/sh

hcpdir="/nafs/narr/HCP_OUTPUT"
maindir="/nafs/narr/asahib/Task_fmri/CARIT"
maindir_jl="/nafs/narr/jloureiro"
txtfile4analysis="/nafs/narr/Task_fmri/CARIT"
#FSLDIR="/usr/local/fsl-5.0.9"
HCPPIPEDIR="${maindir_jl}/scripts/Pipelines-3.22.0"
#CARET7DIR="/usr/local/workbench-1.2.3/bin_rh_linux64"

StudyFolder="${hcpdir}" #Location of Subject folders (named by subjectID)
Subjlist=$(<$maindir/logstxt/Sublist_all.txt) #Space delimited list of subject IDs
#Subjlist="k000801 k000802"
#Subjlist=$(<$maindir/logstxt/test.txt)
echo "$Subjlist" 
#Subjlist4masks=$(<$maindir/logstxt/Subs4CombinedMasks.txt)
#Subjlist4masks=$(<$maindir/logstxt/Subs4ROIAnalysis2.txt)
#Subjlist4masks="k006602"
Subjlist4masks=${Subjlist}
mainfreesurferMasksdir="${maindir}/Masks/freesurferSeg/cifti"

EnvironmentScript="${maindir_jl}/scripts/Pipelines-3.22.0/Examples/Scripts/SetUpHCPPipeline_JL_4slurm.sh"

source ${EnvironmentScript}

module unload workbench/1.2.3
module unload workbench/1.3.2

module load workbench/1.3.2

templatesdir="${maindir_jl}/scripts/Pipelines-3.22.0/global/templates/91282_Greyordinates" 
AverageDatadir="${maindir_jl}/AverageData/HC_n34/MNINonLinear/fsaverage_LR32k"





#VARIABLES TO BE CHANGED##################################################################################


groupzstatdir="${maindir}/KTP1_KTP3/cope6"
#groupzstatdir="${maindir}/PALM3rdLevel/FM/HC_KTP1/ALLSubs/noFuncMask/age_sex_reg2_v2"
#groupzstatdir="${maindir}/PALM3rdLevel/FM/ECT_Ket/EffectsTreatmentECT+Ket"
#groupzstatdir="${maindir}/PALM3rdLevel/FM/ECT_Ket/age_sex_hamd_reg"
#groupzstatdir="${maindir}/PALM3rdLevel/FM/KTP1_KTP2_KTP3"
#groupzstatdir="${maindir}/PALM3rdLevel/FM/ECT_Ket/ChangeHamdCorr"

groupzstat="KTP1_KTP3"
#groupzstat="EffectsTreatmentECT+Ket"
#groupzstat="ECT_Ket_age_sex_hamd_reg"
#groupzstat="KTP1_KTP2"
#groupzstat="ECT+Ket_ChangeHamdCorr"

#CopeMask="cope15"
#CopeMask="cope13"
#ConMask="c2"
#ConMask="c1"
#Copes4extraction="cope11 cope13 cope1 cope2 cope3 cope4 cope5 cope10"
corrp="fwep" #"fwep" if corrected
pvalue="005" #"oo5" if corrected
FuncMasksdir="${maindir}/Masks/FuncMasks/paper/${groupzstat}"
mainCombinedMasksdir="${maindir}/Masks/CombinedMasks/paper/${groupzstat}_cifti"
#FuncMaskname="${groupzstat}_${CopeMask}${ConMask}mask${corrp}${pvalue}"
FuncMaskname="${groupzstat}_mask_tfce_${corrp}${pvalue}"
mkdir ${FuncMasksdir}
mkdir ${mainCombinedMasksdir}

Subcortical_ROI="LR_CEREBELLUM_FUNMASK"

logdir="${maindir}/logstxt/ROIAnalysis/paper/${Subcortical_ROI}"
mkdir ${logdir}

SubcorticalROI="YES" #"NO" if cortical ROI

#Subcortical ROIs:
#ROIlist="CEREBELLUM_LEFT"
#ROIlist="PALLIDUM_RIGHT"
#ROIlist="AMYGDALA_RIGHT AMYGDALA_LEFT"
#ROIlist="THALAMUS_LEFT"
#ROIlist="AMYGDALA_RIGHT"
#ROIlist="THALAMUS_RIGHT THALAMUS_LEFT HIPPOCAMPUS_RIGHT HIPPOCAMPUS_LEFT"
#ROIlist="THALAMUS_LEFT"
#ROIlist="ACCUMBENS_RIGHT"

#ROIlist="AMYGDALA_RIGHT AMYGDALA_LEFT THALAMUS_RIGHT CAUDATE_RIGHT CEREBELLUM_RIGHT CEREBELLUM_LEFT"

#Cortical ROIs:
ROIlist="CEREBELLUM_RIGHT CEREBELLUM_LEFT"  


MergeROIs="YES" #"YES" if more than one ROI to merge at the end

FuncMasks="YES"
MakeMasks="YES" #YES if we want to isolate freesurfer masks
createPercChange="YES"
createFreesurferMasks="NO"




#Get clusters from crossectional analysis - functional masks #####################################################################
if [ ${FuncMasks} = "YES" ]
then 

#for fearful > neutral c2 (MDD > HC) vol min= 800mm3 (100 voxels)##############################
echo "${FuncMasks}"
wb_command -cifti-math 'x > 1.3' ${FuncMasksdir}/${FuncMaskname}.dscalar.nii -var 'x' ${groupzstatdir}/results_dense_tfce_ztstat_fwep_c1.dscalar.nii
wb_command -cifti-create-dense-from-template ${templatesdir}/Atlas_ROIs_labels.2.dlabel.nii ${FuncMasksdir}/${FuncMaskname}.dscalar.nii -cifti ${FuncMasksdir}/${FuncMaskname}.dscalar.nii
fi



#1- Isolate ROI masks from aparc+aseg image and combine structural and functional rois#############################################

if [ ${MakeMasks} = "YES" ]
then 
templatesdir="${maindir_jl}/scripts/Pipelines-3.22.0/global/templates/91282_Greyordinates"
echo "${templatesdir}"
	
	
	
	for sub in ${Subjlist4masks}
	do
		echo "Generating masks from aparc+aseg for ${sub}"
	
		freesurferMasksdir="${mainfreesurferMasksdir}/${sub}"
		CombinedMasksdir="${mainCombinedMasksdir}/${sub}"
		mkdir ${CombinedMasksdir}
		mkdir ${freesurferMasksdir}
		
		if [ ${SubcorticalROI} = "YES" ]; then
				
				for mask in $ROIlist
				do
					i=$((${i} + 1))
					#echo $i
					if [ ${createFreesurferMasks} = "YES" ]; then
						wb_command -cifti-label-to-roi ${templatesdir}/Atlas_ROIs_labels.2.dlabel.nii ${freesurferMasksdir}/cifti_${mask}_aparcaseg.dscalar.nii -name ${mask}
					fi

					wb_command -cifti-math 'x * y' ${CombinedMasksdir}/combined_${mask}_${FuncMaskname}.dscalar.nii -var 'x' ${freesurferMasksdir}/cifti_${mask}_aparcaseg.dscalar.nii -var 'y' ${FuncMasksdir}/${FuncMaskname}.dscalar.nii
					
				done

		else

				for mask in $ROIlist
				do
					echo "creating combined mask with ${mask}"
					if [ ${createFreesurferMasks} = "YES" ]; then
						wb_command -cifti-label-to-roi ${templatesdir}/Atlas_ROIs_labels.2.dlabel.nii ${freesurferMasksdir}/cifti_${mask}_aparcaseg.dscalar.nii -name ${mask}
					fi
					wb_command -cifti-math 'x * y' ${CombinedMasksdir}/combined_${mask}_${FuncMaskname}.dscalar.nii -var 'x' ${freesurferMasksdir}/cifti_${mask}_aparcaseg.dscalar.nii -var 'y' ${FuncMasksdir}/${FuncMaskname}.dscalar.nii

				done

		fi
	done

fi


rm ${logdir}/MERGEDROIs_percent_${FuncMaskname}.txt
#generate one file with all ROIs################################################################################################

#for cope in ${Copes4extraction}
#do

#mkdir ${logdir}/${cope}
#rm ${logdir}/${cope}/${cope}_${FuncMaskname}.txt

#done

for sub in ${Subjlist}
do

	CombinedMasksdir="${mainCombinedMasksdir}/${sub}"
	imagesdir="${hcpdir}/${sub}/MNINonLinear/Results/task-carit_acq-PA_run-01/task-carit_acq-PA_run-01_JL_clean_hp200_s5_level1.feat/GrayordinatesStats"
	#betaimgsdir="${imagesdir}/Results/task-facematching_JL_level2_20cons_clean/task-facematching_JL_20cons_clean_hp200_s5_level2.feat"
	
	if [ ${MergeROIs} = "YES" ]
	then
		args=""
		for mask in ${ROIlist}
		do
			args="${args} -cifti ${CombinedMasksdir}/combined_${mask}_${FuncMaskname}.dscalar.nii "
		done
	
			wb_command -cifti-merge ${CombinedMasksdir}/MERGEDROIs_${FuncMaskname}.dscalar.nii ${args}
	
			wb_command -cifti-create-dense-from-template ${imagesdir}/cope6.dtseries.nii ${CombinedMasksdir}/MERGEDROIs_${FuncMaskname}.dscalar.nii -cifti ${CombinedMasksdir}/MERGEDROIs_${FuncMaskname}.dscalar.nii
			
			
	else
		wb_command -cifti-create-dense-from-template ${imagesdir}/cope6.dtseries.nii ${CombinedMasksdir}/combined_${ROIlist}_${FuncMaskname}.dscalar.nii -cifti ${CombinedMasksdir}/combined_${ROIlist}_${FuncMaskname}.dscalar.nii
		
	fi
	if [ ${createPercChange} = "YES" ]
	then
	wb_command -cifti-reduce ${hcpdir}/${sub}/MNINonLinear/Results/task-carit_acq-PA_run-01/task-carit_acq-PA_run-01_Atlas_clean.dtseries.nii MEAN ${hcpdir}/${sub}/MNINonLinear/Results/task-carit_acq-PA_run-01/mean_cleanfMRI.dscalar.nii -direction 'ROW'
	wb_command -cifti-math 'x / y' ${imagesdir}/cope6_percentchange.dtseries.nii -var 'x' ${imagesdir}/cope6.dtseries.nii -var 'y' ${hcpdir}/${sub}/MNINonLinear/Results/task-carit_acq-PA_run-01/mean_cleanfMRI.dscalar.nii
	fi
	
		if [ ${MergeROIs} = "YES" ]
		then
			wb_command -cifti-stats ${imagesdir}/cope6_percentchange.dtseries.nii -reduce MEAN -roi ${CombinedMasksdir}/MERGEDROIs_${FuncMaskname}.dscalar.nii >> ${logdir}/MERGEDROIs_percent_${FuncMaskname}.txt
	
		else
			wb_command -cifti-stats ${imagesdir}/cope6_percentchange.dtseries.nii -reduce MEAN -roi ${CombinedMasksdir}/combined_${ROIlist}_${FuncMaskname}.dscalar.nii >> ${logdir}/${ROIlist}_${FuncMaskname}.txt
		
		fi

	

	
done


echo "finished"


