function [data_in,data_File,paramMSDanalysis_File,nTrajMax,filename_label,tab_patchDensityDyn,tab_patchDynamic]=combine_getData_CellAvg(lstFiles)

fileOut_tab_patchDensityDyn='tab_patchDensityDyn.txt';
fileOut_tab_patchDynamic='tab_patchDynamic.txt';
fileOut_cellDescription='cellDescription.txt';
%fileOut_tabForBS='tabForBS.txt';
fileOut_paramMSDanalysis='paramMSDanalysis.txt';
%fileOut_imgMask='cellMask_withLabelAndSpec.png';

nFile=numel(lstFiles);
data_File=[];
%data_in=[];

paramMSDanalysis_File=[];
nTrajMax=0;

tab_patchDensityDyn=[]; % sum along dim2 to get ptach densiry per cell
tab_patchDynamic=[]; % per cell: speed and diff (avg + std); dyn_percentage_cell 
cellArea_File=[];
for iFile=1:nFile
    curPath=lstFiles{iFile};
    %cd(curPath)
    
    pathImg=curPath(1:max(strfind(curPath,filesep)));
    imgFilename=curPath(1+max(strfind(curPath,filesep)):end);
    filename_label{iFile}=strcat([num2str(iFile),'-',imgFilename]);
    cd(pathImg)   
    
    path_resultMSDanalysis=strcat(['resultMSDanalysis',filesep,imgFilename(1:end-4)]);
    if exist(path_resultMSDanalysis,'dir')==7
        cd(path_resultMSDanalysis);
        if (exist(fileOut_tab_patchDensityDyn))
            patchDensityDyn=load(fileOut_tab_patchDensityDyn);
            tab_patchDensityDyn=[tab_patchDensityDyn;patchDensityDyn];
        end
        if (exist(fileOut_tab_patchDynamic))
            patchDynamic=load(fileOut_tab_patchDynamic);
            tab_patchDynamic=[tab_patchDynamic;patchDynamic];
        end
        if (exist(fileOut_paramMSDanalysis))            
            paramMSDanalysis=load('paramMSDanalysis.txt');
            paramMSDanalysis_File=[paramMSDanalysis_File;paramMSDanalysis];
        end%if
        if (exist(fileOut_cellDescription))
            cellDescription=load(fileOut_cellDescription);
            cellArea_File=[cellArea_File;cellDescription(:,4)*paramMSDanalysis(1)^2];
        end
    end
    data_File=[data_File;iFile*ones(size(patchDynamic,1),1)];

end%for iFile

data_in=[sum(tab_patchDensityDyn,2),tab_patchDynamic(:,[10,6:9,2:5]),cellArea_File];% duration?
% each row is a cell, and each column correspond to the quantif on the cell
% 1: patch density 
% 2: totalTraj
% 3:6: % of directed, diffusing, constrained, unclassified
% 7:8: velocity (avg & std)
% 9:10: diffusion (avg & std)
% 11: cellArea
end%function