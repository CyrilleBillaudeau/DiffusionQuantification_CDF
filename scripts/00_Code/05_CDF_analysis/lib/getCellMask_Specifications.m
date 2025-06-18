function [cellMask,nCell,cellDescription,tab_cellID_convert]=getCellMask_Specifications(imgFilename,pixSize)

% load image of cell areas generated using Fiji macros.
filenameMask=strcat([imgFilename(1:end-4),'.txt']);
cellMask=load(filenameMask);
cellMask=imdilate(cellMask,strel('disk',2));% MODIF CB 250526 - to be consistant with ROI mask used with Trackmate
%cellMask=imerode(imdilate(cellMask,strel('disk',2)),strel('disk',2));
lstCellID=unique(cellMask);
lstCellID(lstCellID==0)=[];
nCell=numel(lstCellID);
%% --
if (nCell~=max(lstCellID))
    disp('one missing cell in list');
    lstCellID_new=1:nCell;lstCellID_new=lstCellID_new';
    tab_cellID_convert=[lstCellID,lstCellID_new];
    cellMask_new=zeros(size(cellMask));
    for iCell=1:nCell
        [ii,ij]=find(cellMask==lstCellID(iCell));
        for iPix=1:numel(ii)
            cellMask_new(ii(iPix),ij(iPix))=iCell;
        end
    end
    cellMask=cellMask_new;
    lstCellID=unique(cellMask);
    lstCellID(lstCellID==0)=[];
    nCell=numel(lstCellID);
    clear cellMask_new;
    clear lstCellID_new;    
else
    tab_cellID_convert=[lstCellID,lstCellID];
end
%% -- 
figure(50);clf;hold on;imagesc(cellMask);axis square;axis equal;axis ij; colormap([0 0 0;lines(nCell)]);

% cell specifications
cellDescription=zeros(nCell,7);% cellID,cellCentroidX,cellCentroidY,cellArea,cellOrientation,MajorAxisLength,keepCell
for iCell=1:nCell
    cellID=lstCellID(iCell);
    curCell=cellMask==cellID;
    cellProp=regionprops(curCell,'Centroid','Area','MajorAxisLength','Orientation');
    nPart=numel(cellProp);
    cellArea=zeros(nPart,1);
    cellCentroid=zeros(nPart,2);
    cellOrientation=zeros(nPart,1);
    cellMajAxis=zeros(nPart,1);
    for iPart=1:nPart
        cellArea(iPart)=cellProp(iPart).Area;
        cellCentroid(iPart,:)=cellProp(iPart).Centroid;
        cellOrientation(iPart)=cellProp(iPart).Orientation;
        cellMajAxis(iPart)=cellProp(iPart).MajorAxisLength;
    end%for
    [z,indS]=sort(cellArea,'descend');
    cellArea=cellArea(indS);
    ratioAreaPart=100*cellArea./sum(cellArea);
    cellCentroid=cellCentroid(indS,:);
    cellOrientation=cellOrientation(indS);
    cellMajAxis=cellMajAxis(indS);
    if (ratioAreaPart(1)>65)
        cellOrientation=cellOrientation(1);
    else
        cellOrientation=mean(cellOrientation);
    end
    
    if (nPart>1)
        cellArea=sum(cellArea);
        cellCentroid=mean(cellCentroid);
        cellMajAxis=sum(cellMajAxis);
    end
    
    cellDescription(iCell,:)=[cellID,cellCentroid,cellArea,cellOrientation,cellMajAxis,1];
    %Orientation: angle between the x-axis and the major axis of the ellipse that has the same second-moments as the region. The value is in degrees, ranging from -90 to 90 degrees. This figure illustrates the axes and orientation of the ellipse. The left side of the figure shows an image region and its corresponding ellipse. The right side shows the same ellipse with the solid blue lines representing the axes, the red dots are the foci, and the orientation is the angle between the horizontal dotted line and the major axis.
    figure(50);text(cellCentroid(1),cellCentroid(2),num2str(cellID),'Color','w')
    %figure(50);text(cellCentroid(1),cellCentroid(2),strcat([num2str(cellID),'- part:',num2str(nPart)]),'Color','w')
end%for

figure(51);clf;bar([1:nCell],cellDescription(:,6)*pixSize,'k');hold on;
plot([0,nCell+1],median(cellDescription(:,6))*pixSize*ones(2,1),'g')
plot([0,nCell+1],0.5*median(cellDescription(:,6))*pixSize*ones(2,1),'r')
xlabel('Cell ID');
ylabel('Length of the major axis of the bacteria (um)')
cellLgth_median=median(cellDescription(:,6));
cellDescription(cellDescription(:,6)<0.5*cellLgth_median,7)=0;


end%functions