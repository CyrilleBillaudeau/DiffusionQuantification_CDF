function [tr,trajID,totalTraj,trajDuration,nFrame]=getTraj_CurrentCell(lstTraj,traj2Cell,iCell)

tr=[];
trajID=[];
%tr_err=[];
nFrame=0;
trajCurCell=find(traj2Cell(:,1)==iCell);
totalTraj=numel(trajCurCell);

for iTrajCell=1:totalTraj
    iTraj=trajCurCell(iTrajCell);
    curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
    xTraj=curTraj(1:8:end);yTraj=curTraj(2:8:end);ampl=curTraj(4:8:end);
    xTraj_std=curTraj(5:8:end);yTraj_std=curTraj(6:8:end);ampl_std=curTraj(8:8:end);
    timeTraj=lstTraj(iTraj).seqOfEvents;
    nFrame=max(nFrame,max(timeTraj(:,1)));
    time_curTraj=timeTraj(1,1):timeTraj(2,1);time_curTraj=time_curTraj';
    tr=[tr;xTraj,yTraj,time_curTraj,iTrajCell*ones(size(xTraj)),ampl];
    trajID=[trajID;iTraj];
    %tr_err=[tr_err;xTraj_std,yTraj_std,ampl_std];
end%for

trajDuration=zeros(totalTraj,1);
for iTraj=1:totalTraj
    trajDuration(iTraj)= sum(tr(:,4)==iTraj);
end%for

end%function