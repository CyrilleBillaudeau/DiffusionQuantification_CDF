function [all_tr,nTraj,importDone]=importTrack_UTrack(imgFilename,pathImg)

all_tr=[];
nTraj=0;
importDone=0;

path_resUTrack=strcat([imgFilename(1:end-4),filesep,'TrackingPackage',filesep,'tracks']);
if (exist(path_resUTrack,'dir')==7)
    
    cd(path_resUTrack)
    D=load('Channel_1_tracking_result.mat');
    lstTraj=D.tracksFinal;
    nTraj=numel(lstTraj);
    cd(pathImg)   
    
    %trajID=[];
    %tr_err=[];
    nFrame=0;
    
    for iTraj=1:nTraj
        curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
        xTraj=curTraj(1:8:end);yTraj=curTraj(2:8:end);ampl=curTraj(4:8:end);
        %xTraj_std=curTraj(5:8:end);yTraj_std=curTraj(6:8:end);ampl_std=curTraj(8:8:end);
        timeTraj=lstTraj(iTraj).seqOfEvents;
        nFrame=max(nFrame,max(timeTraj(:,1)));
        time_curTraj=timeTraj(1,1):timeTraj(2,1);time_curTraj=time_curTraj';
        all_tr=[all_tr;xTraj,yTraj,time_curTraj,iTraj*ones(size(xTraj)),ampl];
        %trajID=[trajID;iTraj];
        %tr_err=[tr_err;xTraj_std,yTraj_std,ampl_std];
    end%for
    importDone=1;    
end
end%function