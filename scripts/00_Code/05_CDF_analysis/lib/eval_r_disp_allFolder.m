function tab_r_disp=eval_r_disp_allFolder(allData,dtCDF)%,allParamAcq)

nFolder=max(allData(:,1));
tab_r_disp=[];

for iFolder=1:nFolder
    nCell=max(allData(allData(:,1)==iFolder,2));
    %lagTime=allParamAcq(iFolder,3);
    for iCell=1:nCell
        nTraj=max(allData((allData(:,1)==iFolder)&(allData(:,2)==iCell),3));
        for iTraj=1:nTraj
            %trajID=iTraj;
            data=allData((allData(:,1)==iFolder)&(allData(:,2)==iCell)&(allData(:,3)==iTraj),:);
            if (size(data,1)>(1+dtCDF))
                % [r_disp]=eval_r_disp(data(:,[5,6]),dtCDF);
                [r_disp]=eval_r_disp(data(:,[4,5]),dtCDF);
                tab_r_disp=[tab_r_disp;[iFolder,iCell,iTraj].*ones(size(r_disp)),r_disp;NaN(1,4)];
%            else
%                 tab_r_disp=[tab_r_disp;[iFolder,iCell,iTraj],NaN(1,1)];
            end%if
        end%for iTraj
    end%for iCell
end%for iFolder

end%function