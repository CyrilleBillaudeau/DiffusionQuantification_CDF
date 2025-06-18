function run_patch_trackingClassificationDynamic_v190103(lstFiles)
%clear all
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/IO_tools/');
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/Tracking_Dynamics_Classification_And_PatchDensity');

askForListFile=0;
if nargin==0
    askForListFile=1;
end
    
fileOut_tab_patchDensityDyn='tab_patchDensityDyn.txt';
fileOut_tab_patchDynamic='tab_patchDynamic.txt';
fileOut_cellDescription='cellDescription.txt';
fileOut_tabForBS='tabForBS.txt';
fileOut_paramMSDanalysis='paramMSDanalysis.txt';
fileOut_imgMask='cellMask_withLabelAndSpec.png';


minTrcLgth=6;
thldR2dir=0.8;
thldR2diff=0.8;
prompt = {'Minimal track duration (unit: frame)','Minimal threshold for classification as directed motion (R2)','Minimal threshold for classification as random diffusion (R2)'};
dlg_title = 'Parameters for automatic classification of trajectory dynamics';
num_lines = 1;
defaultans = {num2str(minTrcLgth),num2str(thldR2dir),num2str(thldR2diff)};
%defaultans = {'3','1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
minTrcLgth=str2double(answer{1});
thldR2dir=str2double(answer{2});
thldR2diff=str2double(answer{3});
paramMSDanalysis=[minTrcLgth,thldR2dir,thldR2diff];

if (askForListFile)
    lstFiles=uipickfiles('FilterSpec','*.tif');
end%if
nFile=numel(lstFiles);

for iFile=1:nFile
    
    curPath=lstFiles{iFile};
    pathImg=curPath(1:max(strfind(curPath,filesep)));
    imgFilename=curPath(1+max(strfind(curPath,filesep)):end);
    cd(pathImg)
    
    path_resUTrack=strcat([imgFilename(1:end-4),filesep,'TrackingPackage',filesep,'tracks']);
    if (exist(path_resUTrack,'dir')==7)        
        
        % spec file has been generated using a simple fiji macros to return
        % pixel size and lagTime. In future, we should fixed how metadata are
        % set in raw acquisition to skip this operation
        specFile=strcat([imgFilename(1:end-4),'_spec.txt']);
        specAcq=load(specFile);
        lagTime=specAcq(2);
        pixSize=specAcq(3);
        
        %% Cells mask (area, positions, and others)
        [cellMask,nCell,cellDescription]=getCellMask_Specifications(imgFilename);
 
        %% Load tracks from uTrack
        cd(path_resUTrack)        
        D=load('Channel_1_tracking_result.mat');
        lstTraj=D.tracksFinal;
        nTraj=numel(lstTraj);
        cd(pathImg)    
        
        % associate traj to cell
        traj2Cell=trajCell_associate(lstTraj,nTraj,cellDescription,nCell,cellMask);        
        
        %% Dynamic classification and characteristics of each tracks        
        doPlot=0;
        [tab_patchDensityDyn,tab_patchDynamic,tabForBS]=classify_trajDynamics_singleCell(lstTraj,traj2Cell,nCell,cellDescription,pixSize,lagTime,paramMSDanalysis,doPlot);
        
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

