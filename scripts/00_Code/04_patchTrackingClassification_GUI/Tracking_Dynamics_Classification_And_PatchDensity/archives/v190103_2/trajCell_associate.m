function traj2Cell=trajCell_associate(lstTraj,nTraj,cellDescription,nCell,cellMask)
% associate traj to cell
traj2Cell=zeros(nTraj,2);
nFrame=0;
figure(950);clf;hold on;imagesc(cellMask);axis square;axis equal;axis ij; colormap([0 0 0;lines(nCell)]);
for iTraj=1:nTraj
    curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
    xTraj=curTraj(1:8:end);yTraj=curTraj(2:8:end);ampl=curTraj(4:8:end);
    xTraj_std=curTraj(5:8:end);yTraj_std=curTraj(6:8:end);ampl_std=curTraj(8:8:end);
    timeTraj=lstTraj(iTraj).seqOfEvents;
    nFrame=max(nFrame,max(timeTraj(:,1)));
    
    if (~isempty(xTraj))
        meanPosXTraj=mean(xTraj);meanPosYTraj=mean(yTraj);
        
        % associate Traj 2 Cell
        distTraj2Cell=zeros(nCell,1);
        distTraj2Cell(:,1)=sqrt((meanPosXTraj-cellDescription(:,2)).^2+(meanPosYTraj-cellDescription(:,3)).^2);
        
        indCell=find(distTraj2Cell(:,1)==min(distTraj2Cell(:,1)));
        if (distTraj2Cell(indCell,1)<min(cellDescription(cellDescription(:,7)>0,6)))            
            traj2Cell(iTraj,1)=indCell;            
            traj2Cell(iTraj,2)=cellMask(floor(meanPosYTraj),floor(meanPosXTraj));            
        else
            traj2Cell(iTraj,:)=[-1,-1];
            plot(xTraj,yTraj,'m');
        end
    end%if  (~isempty(xTraj))
end%for
%100*mean(traj2Cell(traj2Cell(:,2)>0,1)==traj2Cell(traj2Cell(:,2)>0,2));
traj2Cell=traj2Cell(:,2);traj2Cell(traj2Cell==0)=-1;        
disp('% Traj associated to cell in mask:')
disp(100*mean(traj2Cell>0))
msg_cellMask=strcat(['Traj associated to cell in mask: ',num2str(100*mean(traj2Cell(:,1)>0)),' %']);
figure(50);title(msg_cellMask);
end
