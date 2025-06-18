function [data_in,data_File,paramMSDanalysis_File,nTrajMax,filename_label]=combine_getData_noCellAvg(lstFiles)
% Description for taborBS:
%1:cellID
%2:trajID
%3:tabStatus
%4:tabSpeed
%5:tabD
%6:durTrack
%7:startTrack
%8:cell_area
%9: Speed (drift)
%10: D (drift)
%11: r2
%12: Displacement (t_end - t_start)
%13: Displacement (cumulative)

nFile=numel(lstFiles);
data_File=[];
data_in=[];

paramMSDanalysis_File=[];
nTrajMax=0;

for iFile=1:nFile
    
    curPath=lstFiles{iFile};
    pathImg=curPath(1:max(strfind(curPath,filesep)));
    imgFilename=curPath(1+max(strfind(curPath,filesep)):end);
    filename_label{iFile}=strcat([num2str(iFile),'-',imgFilename]);
    cd(pathImg)
    cd('resultMSDanalysis\')
    cd(imgFilename(1:end-4))
    paramMSDanalysis=load('paramMSDanalysis.txt');
    paramMSDanalysis_File=[paramMSDanalysis_File;paramMSDanalysis];
    curData=load('tabForBS.txt');
    nTrajMax=max([nTrajMax,size(curData,1)]);
    data_in=[data_in;curData];
    data_File=[data_File;iFile*ones(size(curData,1),1)];
end%for iFile

end%function