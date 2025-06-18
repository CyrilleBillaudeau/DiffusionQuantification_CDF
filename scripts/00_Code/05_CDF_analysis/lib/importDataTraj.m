function [allData,allParamAcq,allDynStatus]=importDataTraj(lst_path)
% return:
% -- allData: array with 8 columns:
% 1: folderID -> fileID
% 2: cellID
% 3: trajID
% 4: x (real unit)
% 5: y (real unit)
% 6: t (time unit)
% 7: traj duration
% 8: trajStatus
% -- allParamAcq: array with 3 colums: 
% 1: folderID -> fileID
% 2: pixelSize
% 3: lagTime

disp('Loading data ...')
nFile=numel(lst_path);

allData=[];
allParamAcq=NaN(nFile,3);
allDynStatus=[];

for iFile=1:nFile
       
    curFile=lst_path{iFile};
    curFolder_parent=strsplit(curFile,strcat('outputTrackmate',filesep));
    xmlfile=curFolder_parent{2};
    curFolder_parent=curFolder_parent{1};
    cd(curFolder_parent);
    imgFilename=replace(xmlfile,'_Tracks.xml','.tif');
    disp(imgFilename)

    % lstFile=dir('Cell*.txt');
    % nCell=0;
    % cellFileID=[];
    % for iLst=1:numel(lstFile)
    %     if (strcmp(lstFile(iLst).name,'cellMsk_label.txt') ~=1)
    %         nCell=nCell+1;
    %         zName=lstFile(iLst).name;
    %         cellFileID=[cellFileID;str2num(replace(zName(5:end),'.txt',''))];
    %     end
    % end
    % cellFileID=sort(cellFileID);
    % %cellPerFolder(iFolder,:)=[iFolder,nCell];
    
    % load param acquistion
    specParam_filename=replace(imgFilename,'.tif','_spec.txt');
    param=load(specParam_filename);
    %param=load('paramAcq.txt');
    pixelSize=param(3);
    lagTime=param(2);
    allParamAcq(iFile,:)=[iFile,pixelSize,lagTime];

    % GET CELL MASK
    % msk_filename=replace(imgFilename,'.tif','.txt');
    % cellMask=load(msk_filename);
    % lstCellID=unique(cellMask(:)); lstCellID(1)=[];    
    [cellMask,nCell,cellDescription,tab_cellID_convert]=getCellMask_Specifications(imgFilename,pixelSize);

    % Load tracks
    pathImg=curFolder_parent;
    [all_tr,nTraj,importDone]=importTrack_Trackmate(imgFilename,pathImg,pixelSize);

    % Associate Traj with Cell
    traj2Cell=trajCell_associate(all_tr,nTraj,cellDescription,nCell,cellMask);    

    % % Import Dynamic Behavior (MSD)
    % traj2DynStatus=importResMSDanalysis(imgFilename);% VERIF SI MËME TRAJ ENTRE DEUX ANALYSES

    % Get Dyn Status of each track (based on MSD analysis)
    thldR2diff=0.8;
    thldR2dir=0.9;    
    [tabStatus,tabSpeed,tabD,tabD_static,tabAlpha,durTrack]=getDynStatusMSDanalysis(all_tr,nTraj,thldR2diff,thldR2dir,pixelSize,lagTime);
    DynStatus=[tabStatus,tabSpeed,tabD,tabD_static,tabAlpha,durTrack];

    % Sort Traj

    plotTraj=0;
    if (plotTraj)
        figure(60);clf;hold on
        colorPlot_dyn={'b','r','g','k','m-.'};
    end%if

    for iCellF=1:nCell
        

        iCell=tab_cellID_convert(iCellF,2);
        lstTraj=find(traj2Cell==iCellF);

        % ---
        %trajDuration=NaN(numel(lstTraj),1);        
        for iTraj=1:numel(lstTraj)            
            trajID=lstTraj(iTraj);            
            data=all_tr(all_tr(:,4)==trajID,1:3);%pix_X,pix_Y,Frame
            data(:,1:2)=data(:,1:2)*pixelSize;
            data(:,3)=data(:,3)*lagTime;        
            %data=traj(traj(:,1)==trajID,2:4);data(:,1)=data(:,1)*lagTime;data(:,2:3)=data(:,2:3)*pixelSize;
            trajDuration=size(data,1);      
            %trajStatus=traj2DynStatus((traj2DynStatus(:,1)==iCellF)&(traj2DynStatus(:,2)==trajID),3);                        
            %if (isempty(trajStatus));trajStatus=-1;end
            trajStatus=tabStatus(trajID);
            allData=[allData;[[iFile,iCell,trajID].*ones(trajDuration,1),data,trajDuration*ones(trajDuration,1),trajStatus*ones(trajDuration,1)]];            
            allDynStatus=[allDynStatus;[iFile,iCell,trajID,DynStatus(trajID,:)]];

            if  (plotTraj &~isempty(lstTraj))
                switch trajStatus
                    case 1
                        colorPlot = colorPlot_dyn{1};
                    case 2
                        colorPlot = colorPlot_dyn{2};
                    case 3
                        colorPlot = colorPlot_dyn{3};
                    case 0
                        colorPlot = colorPlot_dyn{4};
                    case -1
                        colorPlot = colorPlot_dyn{5};
                end%switch
                figure(60);plot(data(:,1),data(:,2),colorPlot); axis equal; axis ij
                figure(60);plot(data(1,1),data(1,2),'k.'); axis equal; axis ij
                figure(60);plot(data(end,1),data(end,2),'k.'); axis equal; axis ij
            end%if
        end% for iTraj        
    end%for iCell
    % pause()

end%for iFile
disp('Loading data done!')
end%function