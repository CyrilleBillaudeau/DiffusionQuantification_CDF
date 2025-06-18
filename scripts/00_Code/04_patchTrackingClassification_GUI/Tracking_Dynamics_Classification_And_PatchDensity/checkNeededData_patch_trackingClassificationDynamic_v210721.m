function [text_error,i_err]=checkNeededData_patch_trackingClassificationDynamic_v210721(lstFiles,trackingMethod)
%clear all
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/IO_tools/');
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/Tracking_Dynamics_Classification_And_PatchDensity');
    
nFile=numel(lstFiles);
default_pixSize=0.064;
disp(strcat(['default pixel size: ',num2str(default_pixSize)]));
text_error={};
i_err=0;
for iFile=1:nFile
    
    curPath=lstFiles{iFile};
    pathImg=curPath(1:max(strfind(curPath,filesep)));
    imgFilename=curPath(1+max(strfind(curPath,filesep)):end);
    cd(pathImg)
    
    switch(trackingMethod)
            case 1
                disp('-- check files for UTrack (comet detection)');
                [text_error,i_err]=checkNeededData_patch_trackingClassificationDynamic_uTrack(pathImg,imgFilename,text_error,i_err,default_pixSize);
            case 2
                disp('-- check files for Trackmate')
                [text_error,i_err]=checkNeededData_patch_trackingClassificationDynamic_TrackMate(pathImg,imgFilename,text_error,i_err,default_pixSize);

    end%swicth    
    
end%for iFile

end%function

