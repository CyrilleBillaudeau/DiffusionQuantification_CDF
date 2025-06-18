function [all_tr,nTraj,importDone]=importTrackimportTrack(imgFilename,pathImg,trackingMethod,lagTime,pixSize)
all_tr=[];
importDone=0;
nTraj=0;
switch(trackingMethod)
    case 1
        disp('-- load tracks from UTrack (comet detection)');
        [all_tr,nTraj,importDone]=importTrack_UTrack(imgFilename,pathImg);
    case 2
        disp('-- load tracks from Trackmate')
        [all_tr,nTraj,importDone]=importTrack_Trackmate(imgFilename,pathImg,pixSize);
end%swicth

end%function