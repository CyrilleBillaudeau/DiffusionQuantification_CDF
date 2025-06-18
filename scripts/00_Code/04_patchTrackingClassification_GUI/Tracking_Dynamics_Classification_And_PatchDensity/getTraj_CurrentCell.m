function [tr,trajID,totalTraj,trajDuration,nFrame]=getTraj_CurrentCell(all_tr,traj2Cell,iCell)

tr=[];
trajID=[];
%tr_err=[];
nFrame=0;
trajCurCell=find(traj2Cell(:,1)==iCell);
totalTraj=numel(trajCurCell);

for iTrajCell=1:totalTraj
    iTraj=trajCurCell(iTrajCell);
    
    curTraj=all_tr(all_tr(:,4)==iTraj,:);
    xTraj=curTraj(:,1);yTraj=curTraj(:,2);ampl=curTraj(:,5);
    time_curTraj=curTraj(:,3);
    nFrame=max(nFrame,max(time_curTraj(:,1)));
    tr=[tr;xTraj,yTraj,time_curTraj,iTrajCell*ones(size(xTraj)),ampl];
    trajID=[trajID;iTraj];
    %tr_err=[tr_err;xTraj_std,yTraj_std,ampl_std];
end%for

trajDuration=zeros(totalTraj,1);
for iTraj=1:totalTraj
    trajDuration(iTraj)= sum(tr(:,4)==iTraj);
end%for

end%function