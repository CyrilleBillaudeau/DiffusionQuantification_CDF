function visualize_patch_trackingClassificationDynamic_v190403(displayParams)

if nargin==0
    displayParams = struct( ...
        'statusPlot',{-2}, ...
        'cellID',{0}, ...
        'trajSpeed_selection',{0}, ...
        'trajSpeed_min',{0}, ...
        'trajSpeed_max',{1000}, ...
        'trajDiff_selection',{0}, ...
        'trajDiff_min',{0}, ...
        'trajDiff_max',{1000}, ...
        'trajDuration_selection',{0}, ...
        'trajDuration_min',{0}, ...
        'trajDuration_max',{1000});
end
%clear all;
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/IO_tools/');
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/Tracking_Dynamics_Classification_And_PatchDensity');

fileOut_tab_patchDensityDyn='tab_patchDensityDyn.txt';
fileOut_tab_patchDynamic='tab_patchDynamic.txt';
fileOut_cellDescription='cellDescription.txt';
fileOut_tabForBS='tabForBS.txt';
fileOut_paramMSDanalysis='paramMSDanalysis.txt';
fileOut_imgMask='cellMask_withLabelAndSpec.png';

[imgFilename,pathImg] = uigetfile('*.tif','Select only one file to visualize');

cd(pathImg)
path_resUTrack=strcat([imgFilename(1:end-4),filesep,'TrackingPackage',filesep,'tracks']);
if (exist(path_resUTrack,'dir')==7)
    
    % spec file has been generated using a simple fiji macros to return
    % pixel size and lagTime. In future, we should fixed how metadata are
    % set in raw acquisition to skip this operation
    specFile=strcat([imgFilename(1:end-4),'_spec.txt']);
    specAcq=load(specFile);
    nFrame=specAcq(1);
    lagTime=specAcq(2);
    pixSize=specAcq(3);
    
    %% Cells mask (area, positions, and others)
    [cellMask,nCell,cellDescription,tab_cellID_convert]=getCellMask_Specifications(imgFilename);
    
    %% Load tracks from uTrack
    cd(path_resUTrack)
    D=load('Channel_1_tracking_result.mat');
    lstTraj=D.tracksFinal;
    nTraj=numel(lstTraj);
    cd(pathImg)
    
    % associate traj to cell
    traj2Cell=trajCell_associate(lstTraj,nTraj,cellDescription,nCell,cellMask);
    
    path_resultMSDanalysis=strcat(['resultMSDanalysis',filesep,imgFilename(1:end-4)]);
    if exist(path_resultMSDanalysis,'dir')==7
        cd(path_resultMSDanalysis);
        if (exist(fileOut_tab_patchDensityDyn))
            patchDensityDyn=load(fileOut_tab_patchDensityDyn);
        end
        if (exist(fileOut_tab_patchDynamic))
            patchDynamic=load(fileOut_tab_patchDynamic);
        end
        if (exist(fileOut_tabForBS))
            tabForBS=load(fileOut_tabForBS);
            tabForBS_cellID=tabForBS(:,1);
            testCellID_BS=unique(tabForBS_cellID);
            if sum(testCellID_BS-tab_cellID_convert(cellDescription(:,7)>0,2))~=0
                nCell_convert=size(tab_cellID_convert,1);
                for iCell_convert=1:nCell_convert
                    tabForBS(tabForBS_cellID==tab_cellID_convert(iCell_convert,1),1)=tab_cellID_convert(iCell_convert,2);
                end
            end%if
            trajStatus=tabForBS(:,3);
            trajID=tabForBS(:,2);
        end
        cd(pathImg)
    end
    
    exportClassifiedTracksSelected4TrackMate(imgFilename,pathImg,lstTraj,traj2Cell,pixSize,lagTime,tabForBS,cellDescription,displayParams);
    
end%if

end%function


