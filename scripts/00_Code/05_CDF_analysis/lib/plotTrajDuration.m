function trajDuration=plotTrajDuration(allData)

trajDuration=NaN(size(allData,1),4);
nFile=max(allData(:,1));
nTraj=0;
for iFile=1:nFile
    isCurFile=allData(:,1)==iFile;
    lstCell_curFile=unique(allData(isCurFile,2));
    for iCell=1:numel(lstCell_curFile)
        cellID=lstCell_curFile(iCell);
        isCurCell=(allData(:,2)==cellID);
        curFileCell_data=allData(isCurFile&isCurCell,:);
        lstTraj=unique(curFileCell_data(:,3));
        for iTraj=1:numel(lstTraj)
            nTraj=nTraj+1;
            trajID=lstTraj(iTraj);
            trajDuration(nTraj,1:3)=[iFile,cellID,trajID];
            trajDuration(nTraj,4)=size(curFileCell_data(curFileCell_data(:,3)==trajID,end),1);
        end
    end
end
trajDuration(nTraj+1:end,:)=[];
figure(80);clf;histogram(trajDuration(:,4),[1:max(trajDuration(:,4))],'FaceColor','k','EdgeColor','w','FaceAlpha',1.0);

end%function