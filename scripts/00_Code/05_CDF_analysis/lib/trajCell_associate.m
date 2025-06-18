function traj2Cell=trajCell_associate(all_tr,nTraj,cellDescription,nCell,cellMask)
% associate traj to cell
traj2Cell=zeros(nTraj,2);
nFrame=0;

showTrajOutsideSelectedCell=0;
if (showTrajOutsideSelectedCell)
    figure(950);clf;hold on;imagesc(cellMask);axis square;axis equal;axis ij; colormap([0 0 0;lines(nCell)]);
    for iTraj=1:nTraj
        curTraj=all_tr(all_tr(:,4)==iTraj,:);
        xTraj=curTraj(:,1);yTraj=curTraj(:,2);ampl=curTraj(:,5);
        meanPosXTraj=mean(xTraj);meanPosYTraj=mean(yTraj);
        plot(meanPosXTraj,meanPosYTraj,'m.');
    end

end%if

for iTraj=1:nTraj
    curTraj=all_tr(all_tr(:,4)==iTraj,:);
    xTraj=curTraj(:,1);yTraj=curTraj(:,2);ampl=curTraj(:,5);
    timeTraj=curTraj(:,3);
    nFrame=max(nFrame,max(timeTraj(:,1)));
    
    if (~isempty(xTraj))
        meanPosXTraj=mean(xTraj);meanPosYTraj=mean(yTraj);
        
        % associate Traj 2 Cell
        distTraj2Cell=zeros(nCell,1);
        distTraj2Cell(:,1)=sqrt((meanPosXTraj-cellDescription(:,2)).^2+(meanPosYTraj-cellDescription(:,3)).^2);
        
        indCell=find(distTraj2Cell(:,1)==min(distTraj2Cell(:,1)));
        %if (distTraj2Cell(indCell,1)<min(cellDescription(cellDescription(:,7)>0,6)))            
        if (distTraj2Cell(indCell,1)<max(cellDescription(cellDescription(:,7)>0,6)))% MODIF CB 250526 because too exclusive            
            traj2Cell(iTraj,1)=indCell;
            xMpix=floor(meanPosXTraj);
            yMpix=floor(meanPosYTraj);
            %disp([xMpix,yMpix])
            if (xMpix<1);xMpix=1;end
            if (yMpix<1);yMpix=1;end
            if (xMpix>size(cellMask,2));xMpix=size(cellMask,2);end
            if (yMpix>size(cellMask,1));yMpix=size(cellMask,1);end
            traj2Cell(iTraj,2)=cellMask(yMpix,xMpix);            
        else
            traj2Cell(iTraj,:)=[-1,-1];
            if (showTrajOutsideSelectedCell);plot(xTraj,yTraj,'m');end%if
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
