lstFiles=uipickfiles('FilterSpec','*.tif');
nFile=numel(lstFiles);
statistics_velocity=[];
statistics_cellTraj=[];

[data_in,data_File,paramMSDanalysis_File,nTrajMax,filename_label]=combine_getData(lstFiles);

% ******************** getSpeed
[resultPlot_velocity]=combine_getSpeeed_noCellAvg(data_in,data_File,nFile,filename_label);

% ******************** getDiffusion
[result_diffusion]=combine_getDiffusion_noCellAvg(data_in,data_File,nFile,filename_label);

% ******************** getDensity
[cellArea_perFile]=combine_getCellArea_perFile(data_in,data_File,nFile);
[resultPlot_densityAll,resultPlot_densityDyn,nTrajAnalyzed_PerFile]=combine_getDensity_DynBehavior_noCellAvg(data_in,data_File,nFile,cellArea_perFile,paramMSDanalysis_File,filename_label);



