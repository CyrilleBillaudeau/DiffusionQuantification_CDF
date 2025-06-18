function traj2DynStatus=importResMSDanalysis(imgFilename)
%traj2DynStatus: 2D-array with 3 columns (CellID; TrajID; TrajDynStatus)

cd('resultMSDanalysis\')
cd(imgFilename(1:end-4))
tab_MSDanalysisFull=load("tabForBS.txt");

cd ../..

traj2DynStatus=tab_MSDanalysisFull(:,1:3);
end%
