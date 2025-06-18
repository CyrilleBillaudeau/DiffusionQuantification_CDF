function [all_tr,nTraj,importDone]=importTrack_Trackmate(imgFilename,pathImg,pixSize)

all_tr=[];
nTraj=0;
importDone=0;

cd('outputTrackmate')%cd('outputTrackmate\')

xmlfilename=strcat([imgFilename(1:(end-4)),'_Tracks.xml']);
if (exist(xmlfilename,'file')==2)    
    [tracks, md] = importTrackMateTracks(xmlfilename);
    
    nTraj=numel(tracks);
    for iTraj=1:nTraj
        curTraj=tracks{iTraj};
        xTraj=curTraj(:,2)/pixSize;
        yTraj=curTraj(:,3)/pixSize;
        time_curTraj=curTraj(:,1);
        ampl=-ones(size(xTraj));
        all_tr=[all_tr;xTraj,yTraj,time_curTraj,iTraj*ones(size(xTraj)),ampl];
    end%for
    importDone=1;
    
end%if

cd(pathImg)

end%function
