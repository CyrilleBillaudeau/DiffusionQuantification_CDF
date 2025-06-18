function run_patch_trackingClassificationDynamic_v210721(lstFiles,trackingMethod,doTrackMateExport)
%clear all
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/IO_tools/');
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/Tracking_Dynamics_Classification_And_PatchDensity');

askForListFile=0;
if nargin==0
    askForListFile=1;
    trackingMethod=1;
    doTrackMateExport=0;
    disp('no input parameter: ');
    disp('user will be asked for files,')
    disp('tracks are supposed to be obtained using UTrack,');
    disp('and results will not be export for Trackmate');
end
    
fileOut_tab_patchDensityDyn='tab_patchDensityDyn.txt';
fileOut_tab_patchDynamic='tab_patchDynamic.txt';
fileOut_cellDescription='cellDescription.txt';
fileOut_tabForBS='tabForBS.txt';
fileOut_paramMSDanalysis='paramMSDanalysis.txt';
fileOut_imgMask='cellMask_withLabelAndSpec.png';

unitTrcLgth=1;
minTrcLgth_undefinedUnit=6;
thldR2dir=0.8;
thldR2diff=0.8;
doPlotMSD=0;

%prompt = {'Minimal track duration (unit: frame)','Minimal threshold for classification as directed motion (R2)','Minimal threshold for classification as random diffusion (R2)','Show MSD plot: Yes (1) or No (0)'};
prompt = {'Define unit for minimal duration (1=sec, 2: frame)','Minimum duration of the trajectory (using unit defined above)','Minimal threshold for classification as directed motion (R2)','Minimal threshold for classification as random diffusion (R2)','Show MSD plot: Yes (1) or No (0)'};
dlg_title = 'Parameters for automatic classification of trajectory dynamics';
num_lines = 1;
defaultans = {num2str(unitTrcLgth),num2str(minTrcLgth_undefinedUnit),num2str(thldR2dir),num2str(thldR2diff),num2str(doPlotMSD)};
%defaultans = {'3','1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
unitTrcLgth=str2double(answer{1});
minTrcLgth_undefinedUnit=str2double(answer{2});
thldR2dir=str2double(answer{3});
thldR2diff=str2double(answer{4});
doPlotMSD=str2double(answer{5});
paramMSDanalysis_0=[minTrcLgth_undefinedUnit,thldR2dir,thldR2diff];

if (askForListFile)
    lstFiles=uipickfiles('FilterSpec','*.tif');
end%if
nFile=numel(lstFiles);

for iFile=1:nFile
    
    curPath=lstFiles{iFile};
    pathImg=curPath(1:max(strfind(curPath,filesep)));
    imgFilename=curPath(1+max(strfind(curPath,filesep)):end);
    cd(pathImg)
    
    % spec file has been generated using a simple fiji macros to return
    % pixel size and lagTime. In future, we should fixed how metadata are
    % set in raw acquisition to skip this operation
    specFile=strcat([imgFilename(1:end-4),'_spec.txt']);
    specAcq=load(specFile);
    lagTime=specAcq(2);
    pixSize=specAcq(3);
    paramMSDanalysis=paramMSDanalysis_0;
    if (unitTrcLgth == 1)
        paramMSDanalysis(1)=paramMSDanalysis(1)/lagTime;
    end
    %% Load tracks
    %trackingMethod=1;
    [all_tr,nTraj,importDone]=importTrack(imgFilename,pathImg,trackingMethod,lagTime,pixSize);
    
%    path_resUTrack=strcat([imgFilename(1:end-4),filesep,'TrackingPackage',filesep,'tracks']);
%    if (exist(path_resUTrack,'dir')==7)        
    if (importDone)                
        %% Cells mask (area, positions, and others)
        [cellMask,nCell,cellDescription]=getCellMask_Specifications(imgFilename,pixSize);
 
        %% associate traj to cell        
        traj2Cell=trajCell_associate(all_tr,nTraj,cellDescription,nCell,cellMask);        
        
        %% Dynamic classification and characteristics of each tracks        
        %doPlotMSD=1;
        [tab_patchDensityDyn,tab_patchDynamic,tabForBS]=classify_trajDynamics_singleCell(all_tr,traj2Cell,nCell,cellDescription,pixSize,lagTime,paramMSDanalysis,doPlotMSD);
        
        % export xml for trackmate
        %doTrackMateExport=0;
        if (doTrackMateExport)
            exportClassifiedTracks4TrackMate(imgFilename,pathImg,all_tr,traj2Cell,pixSize,lagTime,tabForBS,cellDescription);
        end%if
        
        % save results
        path_resultMSDanalysis=strcat(['resultMSDanalysis',filesep,imgFilename(1:end-4)]);
        if exist(path_resultMSDanalysis,'dir')~=7
            mkdir(path_resultMSDanalysis);
        end
        cd(path_resultMSDanalysis);
        
        save(fileOut_tab_patchDensityDyn,'tab_patchDensityDyn','-ascii');
        save(fileOut_tab_patchDynamic,'tab_patchDynamic','-ascii');
        save(fileOut_cellDescription,'cellDescription','-ascii');
        save(fileOut_tabForBS,'tabForBS','-ascii');
        paramMSDanalysis_out=[pixSize,lagTime,paramMSDanalysis];
        save(fileOut_paramMSDanalysis,'paramMSDanalysis_out','-ascii');
        print(50,fileOut_imgMask,'-dpng')
        cd ../../
        
    end%if    
    
    %end%if exist
    
end%for iFile

end%function

