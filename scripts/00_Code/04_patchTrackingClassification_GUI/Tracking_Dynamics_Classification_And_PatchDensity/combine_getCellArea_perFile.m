function [cellArea_perFile]=combine_getCellArea_perFile(data_in,data_File,nFile)

nCellPerFile=NaN(nFile,1);
for iFile=1:nFile
    curData=data_in(data_File==iFile,:);
    nCellPerFile(iFile)=numel(unique(curData(:,1)));
end
cellArea_perFile=NaN(max(nCellPerFile),nFile);

for iFile=1:nFile
    curData=data_in(data_File==iFile,:);
    lstCellID=unique(curData(:,1));
    for iCell=1:nCellPerFile(iFile)
        curCell=lstCellID(iCell);
        curArea=unique(curData(curData(:,1)==curCell,8));
        if numel(curArea)>1
            disp('more than one area for current cell...');
            disp(curCell);
        else
            cellArea_perFile(iCell,iFile)=curArea;
        end
    end
end

end%function