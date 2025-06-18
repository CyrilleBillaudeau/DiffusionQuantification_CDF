function all_relativPosTrajCell=measure_distTrajPole(allData,all_cellPole,allParamAcq)
% return array with distance to the nearest pole and cell length
% 1: folderID
% 2: cellID
% 3: trajID
% 4: polID (nearest 1 or 2),[
% 5: minDistPole (real unit)
% 6: cellLgth (real unit)

doPlotTrajPole=0;

all_relativPosTrajCell=[];
nFolder=max(allData(:,1));
disp('Measure distance between traj and pole ...')
for iFolder=1:nFolder
    nCell=max(allData(allData(:,1)==iFolder,2));
    pixSize=allParamAcq(iFolder,2);
    for iCell=1:nCell
        nTraj=max(allData((allData(:,1)==iFolder)&(allData(:,2)==iCell),3));
        for iTraj=1:nTraj
            keepTraj=(allData(:,1)==iFolder)&(allData(:,2)==iCell)&(allData(:,3)==iTraj);
            cur_data=allData(keepTraj,5:6);
            cellPole=all_cellPole((all_cellPole(:,1)==iFolder)&(all_cellPole(:,2)==iCell),3:6);
            
            % curFolder=lst_path{iFolder};
            % cd(curFolder);
            % imgCell=load('cellMsk_label.txt');
            % figure(50);clf;imshow(imgCell==iCell,[]);hold on
            % plot(cellPole([1,3]),cellPole([2,4]),'r+')
            % plot(floor(trajCentr(1)),floor(trajCentr(2)),'m+')
            
            trajCentr=mean(cur_data)/pixSize;
            distPol(1)=sqrt(sum((trajCentr-cellPole(1:2)).^2));
            distPol(2)=sqrt(sum((trajCentr-cellPole(3:4)).^2));
            
            if (distPol(1)<distPol(2))
                polID=1;
                minDistPole=distPol(1);
            else
                polID=2;
                minDistPole=distPol(2);
            end
            cellLgth=sqrt(sum((cellPole(1:2)-cellPole(3:4)).^2));
            all_relativPosTrajCell=[all_relativPosTrajCell;[iFolder,iCell,iTraj,polID,[minDistPole,cellLgth]*pixSize]];
            
        end%for iTraj
    end%for iCell
end%for iFolder

if (doPlotTrajPole)
    yPlot=all_relativPosTrajCell(:,5);
    figure(200);clf;histogram(yPlot,(0:.5:max(yPlot)),'FaceColor','k','EdgeColor','w');
    yPlot=all_relativPosTrajCell(:,5)./all_relativPosTrajCell(:,6);
    figure(210);clf;histogram(yPlot,(0:.02:1.2),'FaceColor','k','EdgeColor','w');
end%if
disp('Measure distance between traj and pole done!')
end%function