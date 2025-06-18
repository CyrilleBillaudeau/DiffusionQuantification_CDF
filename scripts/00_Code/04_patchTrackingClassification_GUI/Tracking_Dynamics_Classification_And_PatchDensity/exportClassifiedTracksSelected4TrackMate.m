function exportClassifiedTracksSelected4TrackMate(imgFilename,pathImg,all_tr,traj2Cell,pixSize,lagTime,tabForBS,cellDescription,displayParams);

disp('Export to trackmate with selection is starting');
if (nargin == 8)
    ParamSelect_trajStatus=-2;
    ParamSelect_cellID=0;
    ParamSelect_trajSpeed_selection=0;
    ParamSelect_trajSpeed_min=0;
    ParamSelect_trajSpeed_max=0;
    ParamSelect_trajDiff_selection=0;
    ParamSelect_trajDiff_min=0;
    ParamSelect_trajDiff_max=0;
    ParamSelect_trajDuration_selection=0;
    ParamSelect_trajDuration_min=0;
    ParamSelect_trajDuration_max=0;
    prompt = {...
        'Traj status (-2:all / -1:untreated / 0:unclassified / 1:directed / 2:diffused / 3:constrained)',...
        'Cell ID selection (0:all)',...
        'Traj selected using speed (0:no / 1:yes)',...
        'Traj min speed (unit: nm/s)',...
        'Traj max speed (unit: nm/s)',...
        'Traj selected using diffusion coef D (0:no / 1:yes)',...
        'Traj min D (unit: 1e-3 µm2/s)',...
        'Traj max D(unit: 1e-3 µm2/s)',...
        'Traj selected using duration (0:no / 1:yes)',...
        'Traj min duration (unit: frame)',...
        'Traj max duration (unit: frame)',...
        };
    dlg_title = 'Parameters for trajectories exportation';
    num_lines = 1;
    defaultans = {...
        num2str(ParamSelect_trajStatus),...
        num2str(ParamSelect_cellID),...
        num2str(ParamSelect_trajSpeed_selection),...
        num2str(ParamSelect_trajSpeed_min),...
        num2str(ParamSelect_trajSpeed_max),...
        num2str(ParamSelect_trajDiff_selection),...
        num2str(ParamSelect_trajDiff_min),...
        num2str(ParamSelect_trajDiff_max),...
        num2str(ParamSelect_trajDuration_selection),...
        num2str(ParamSelect_trajDuration_min),...
        num2str(ParamSelect_trajDuration_max),...
        };
    
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    ParamSelect_trajStatus=str2double(answer{1});
    ParamSelect_cellID=str2double(answer{2});
    ParamSelect_trajSpeed_selection=str2double(answer{3});
    ParamSelect_trajSpeed_min=str2double(answer{4});
    ParamSelect_trajSpeed_max=str2double(answer{5});
    ParamSelect_trajDiff_selection=str2double(answer{6});
    ParamSelect_trajDiff_min=str2double(answer{7});
    ParamSelect_trajDiff_max=str2double(answer{8});
    ParamSelect_trajDuration_selection=str2double(answer{9});
    ParamSelect_trajDuration_min=str2double(answer{10});
    ParamSelect_trajDuration_max=str2double(answer{11});
    
end

if (nargin==9)   
    ParamSelect_trajStatus=displayParams.statusPlot;
    ParamSelect_cellID=displayParams.cellID;
    ParamSelect_trajSpeed_selection=displayParams.trajSpeed_selection;
    ParamSelect_trajSpeed_min=displayParams.trajSpeed_min;
    ParamSelect_trajSpeed_max=displayParams.trajSpeed_max;
    ParamSelect_trajDiff_selection=displayParams.trajDiff_selection;
    ParamSelect_trajDiff_min=displayParams.trajDiff_min;
    ParamSelect_trajDiff_max=displayParams.trajDiff_max;
    ParamSelect_trajDuration_selection=displayParams.trajDuration_selection;
    ParamSelect_trajDuration_min=displayParams.trajDuration_min;
    ParamSelect_trajDuration_max=displayParams.trajDuration_max;
end

nSel=11;
%paramMSDanalysis=[minTrcLgth,thldR2dir,thldR2diff];

%% --- TABLE WITH SELECTION CRITERIA
nTrajTot=max(all_tr(:,4));%numel(lstTraj);
tab_Selection=zeros(nTrajTot,nSel);
% traj Status
if (ParamSelect_trajStatus == -2) 
    tab_Selection(:,1)=1;    
else    
    tab_Selection(tabForBS(tabForBS(:,3)==ParamSelect_trajStatus,2),1)=1;
end
% cell ID
traj2Cell_select=traj2Cell;
cell_remove=find(cellDescription(:,7)==0);
nCell_rm=numel(cell_remove);
for iCell_rm=1:nCell_rm
    traj2Cell_select(traj2Cell_select==cell_remove(iCell_rm))=-2;
end

if (ParamSelect_cellID == 0) 
    tab_Selection(traj2Cell_select>0,2)=1;
else    
    tab_Selection(traj2Cell==ParamSelect_cellID,2)=1;
end

% selection with speed
if (ParamSelect_trajSpeed_selection == 1) 
    tab_Selection(:,3)=1;        
    tabSpeed=NaN(nTrajTot,1);
    tabZ=[find(tabForBS(:,3)==1),tabForBS(tabForBS(:,3)==1,2),1000*tabForBS(tabForBS(:,3)==1,4)];    
    if (~isempty(tabZ))
        tabSpeed(tabZ(:,2))=tabZ(:,3);
        tab_Selection(tabSpeed>=ParamSelect_trajSpeed_min,4)=1;
        tab_Selection(tabSpeed<=ParamSelect_trajSpeed_max,5)=1;
    end%if
end

% selection with diff
if (ParamSelect_trajDiff_selection== 1) 
    tab_Selection(:,6)=1;    
    tabDiff=NaN(nTrajTot,1);
    tabZ=[find(tabForBS(:,3)==2),tabForBS(tabForBS(:,3)==2,2),1000*tabForBS(tabForBS(:,3)==2,5)];
    if (~isempty(tabZ))
        tabDiff(tabZ(:,2))=tabZ(:,3);
        tab_Selection(tabDiff>=ParamSelect_trajDiff_min,7)=1;
        tab_Selection(tabDiff<=ParamSelect_trajDiff_max,8)=1;
    end%if
    
end

% selection with duration
if (ParamSelect_trajDuration_selection== 1) 
    tab_Selection(:,9)=1;    
    tabDuration=NaN(nTrajTot,1);
    tabZ=[find(tabForBS(:,3)>-2),tabForBS(tabForBS(:,3)>-2,2),tabForBS(tabForBS(:,3)>-2,6)];
    if (~isempty(tabZ))
        tabDuration(tabZ(:,2))=tabZ(:,3);
        tab_Selection(tabDuration>=ParamSelect_trajDuration_min,10)=1;
        tab_Selection(tabDuration<=ParamSelect_trajDuration_max,11)=1;
    end%if
end

tabKeep=ones(nTrajTot,1);
if (ParamSelect_trajStatus>-2)
    tabKeep = (tabKeep& tab_Selection(:,1));
end
%if (ParamSelect_cellID>0)
tabKeep = (tabKeep& tab_Selection(:,2));
%end
if (ParamSelect_trajSpeed_selection>0)
    tabKeep = (tabKeep & tab_Selection(:,4) & tab_Selection(:,5));
end
if (ParamSelect_trajDiff_selection>0)
    tabKeep = (tabKeep & tab_Selection(:,7) & tab_Selection(:,8));
end
if (ParamSelect_trajDuration_selection>0)
    tabKeep = (tabKeep & tab_Selection(:,10) & tab_Selection(:,11));
end

nTrajKeep=sum(tabKeep);
disp(strcat(['Remaining tracks: ',num2str(nTrajKeep)]));

if (nTrajKeep==0)
    disp('Export abort');
    return;
end%if

%% ---

pathFct=mfilename('fullpath');
%disp(pathFct);
pathFct=pathFct(1:max(strfind(pathFct,filesep)));
path_xmlTemplate=strcat([pathFct,'templates_xml',filesep]);
%disp(path_xmlTemplate);

img_info=imfinfo(imgFilename);
nFrame=numel(img_info);
imW=img_info(1).Width;
imH=img_info(1).Height;

xmlFilename=strcat([imgFilename(1:(end-4)),'_Selection.xml']);
fDest = fopen(xmlFilename, 'w' );
%fDest = fopen( 'template.xml.TEMP', 'w' );

%% --- Copy template with start of xml file for trackmate
xmlTemplate=strcat([path_xmlTemplate,'template_init.xml']);
if (exist(xmlTemplate,'file')~=2)
    disp('Template file not found for: "template_init.xml"');
    disp('Job aborted!');
    return;
end

fOrig = fopen(xmlTemplate, 'r' );
while ~feof(fOrig)
    line = fgets(fOrig);
    fprintf(fDest, '%s', line);
end
fclose(fOrig);

%% --- Spot/Tracks/Edge feature
nSpot=get_nSpot_Sel(all_tr,traj2Cell_select,tabKeep);%nSpot=get_nSpot_Sel(lstTraj,traj2Cell_select,tabKeep);
line=strcat(['    <AllSpots nspots="',num2str(nSpot),'">']);
fprintf(fDest, '%s\n', line);
disp('XML: edit spot features');
[traj2spot,spotSpec]=editXML_spot_Sel(fDest,all_tr,traj2Cell_select,nSpot, nFrame,pixSize,lagTime,tabKeep);
disp('XML: edit track/edge features');
editXML_tracks_Sel(fDest,all_tr,traj2Cell_select,traj2spot,spotSpec,lagTime,pixSize,tabForBS,tabKeep);

%% --- Copy template with end of xml file for trackmate
fprintf(fDest, '%s\n%s\n','  </Model>','  <Settings>');

line=strcat(['    <ImageData filename="',imgFilename,'" folder="',pathImg,'" width="',num2str(imW),'" height="',num2str(imH),'" nslices="1" nframes="',num2str(nFrame),'" pixelwidth="',num2str(pixSize),'" pixelheight="',num2str(pixSize),'" voxeldepth="0.00" timeinterval="',num2str(lagTime),'" />"']);
fprintf(fDest, '%s\n', line);
line=strcat(['    <BasicSettings xstart="0" xend="',num2str(imW-1),'" ystart="0" yend="',num2str(imH-1),'" zstart="0" zend="0" tstart="0" tend="',num2str(nFrame-1),'" />']);
fprintf(fDest, '%s\n', line);

xmlTemplate=strcat([path_xmlTemplate,'template_end.xml']);
if (exist(xmlTemplate,'file')~=2)
    disp('Template file not found for: "template_end.xml"');
    disp('Job aborted!');
    return;
end
fOrig = fopen( xmlTemplate, 'r' );
while ~feof(fOrig)
    line = fgets(fOrig);
    fprintf(fDest, '%s', line);
    
end
fclose(fOrig);

fclose(fDest);
disp('Export to trackmate with selection done!');
end

function nSpot=get_nSpot_Sel(all_tr,traj2Cell_select,tabKeep)
nSpot=0;
nTraj=max(all_tr(:,4));%numel(lstTraj);
for iTraj=1:nTraj
    if ((traj2Cell_select(iTraj)>0)&(tabKeep(iTraj)>0))
%         curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
%         tmpTraj=curTraj(1:8:end);
%         nSpot=nSpot+numel(tmpTraj);
        curTraj=all_tr(all_tr(:,4)==iTraj,:);
        nSpot=nSpot+size(curTraj,1);
    end
end
disp(strcat(['nSpot Total: ', num2str(nSpot)]))
end%function


function [traj2spot,spotSpec]=editXML_spot_Sel(fDest,all_tr,traj2Cell_select,nSpot, nFrame,pixSize,lagTime,tabKeep)

traj2spot=edit_traj2spot_Sel(all_tr,traj2Cell_select,nFrame,tabKeep);
[spotSpec]=eval_spotSpec(all_tr,traj2Cell_select,traj2spot,nSpot,pixSize,lagTime);

for iFrame=1:nFrame
    line=strcat(['      <SpotsInFrame frame="',num2str(iFrame-1),'">']);
    fprintf(fDest, '%s\n', line);
    lstSpotID=traj2spot(iFrame,tabKeep>0);lstSpotID(isnan(lstSpotID))=[];
    %disp(lstSpotID);
    %spotSpec(lstSpotID,:)
    if (~isempty(lstSpotID))
        nLstSpot=numel(lstSpotID);
        for iLst=1:nLstSpot
            iSpotID=lstSpotID(iLst);
            line=strcat(['        <Spot ID="',num2str(iSpotID),'" name="ID',num2str(iSpotID)]);
            line=strcat([line,'" QUALITY="',num2str(spotSpec(iSpotID,3))]);
            line=strcat([line,'" POSITION_T="',num2str(spotSpec(iSpotID,4))]);
            line=strcat([line,'" MAX_INTENSITY="',num2str(spotSpec(iSpotID,5))]);
            line=strcat([line,'" FRAME="',num2str(spotSpec(iSpotID,6))]);
            line=strcat([line,'" MEDIAN_INTENSITY="',num2str(spotSpec(iSpotID,7))]);
            line=strcat([line,'" VISIBILITY="',num2str(spotSpec(iSpotID,8))]);
            line=strcat([line,'" MEAN_INTENSITY="',num2str(spotSpec(iSpotID,9))]);
            line=strcat([line,'" TOTAL_INTENSITY="',num2str(spotSpec(iSpotID,10))]);
            line=strcat([line,'" ESTIMATED_DIAMETER="',num2str(spotSpec(iSpotID,11))]);
            line=strcat([line,'" RADIUS="',num2str(spotSpec(iSpotID,12))]);
            line=strcat([line,'" SNR="',num2str(spotSpec(iSpotID,13))]);
            line=strcat([line,'" POSITION_X="',num2str(spotSpec(iSpotID,14))]);
            line=strcat([line,'" POSITION_Y="',num2str(spotSpec(iSpotID,15))]);
            line=strcat([line,'" STANDARD_DEVIATION="',num2str(spotSpec(iSpotID,16))]);
            line=strcat([line,'" CONTRAST="',num2str(spotSpec(iSpotID,17))]);
            line=strcat([line,'" MANUAL_COLOR="',num2str(spotSpec(iSpotID,18))]);
            line=strcat([line,'" MIN_INTENSITY="',num2str(spotSpec(iSpotID,19))]);
            line=strcat([line,'" POSITION_Z="',num2str(spotSpec(iSpotID,20))]);
            line=strcat([line,'" CELL_ID="',num2str(spotSpec(iSpotID,21))]);
            line=strcat([line,'" />']);
            fprintf(fDest, '%s\n', line);
        end
    end
    line='      </SpotsInFrame>';
    fprintf(fDest, '%s\n', line);
end
line='    </AllSpots>';
fprintf(fDest, '%s\n', line);
end%function

function traj2spot=edit_traj2spot_Sel(all_tr,traj2Cell_select,nFrame,tabKeep)
nTraj=max(all_tr(:,4));%numel(lstTraj);
traj2spot=NaN(nFrame,nTraj);

spotID=0;
for iFrame=1:nFrame
    for iTraj=1:nTraj
        if ((traj2Cell_select(iTraj)>0)&(tabKeep(iTraj)>0))
            curTraj=all_tr(all_tr(:,4)==iTraj,:);
%             curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
%             xTraj=curTraj(1:8:end);yTraj=curTraj(2:8:end);ampl=curTraj(4:8:end);
%             timeTraj=lstTraj(iTraj).seqOfEvents;
%             nFrame=max(nFrame,max(timeTraj(:,1)));
%             time_curTraj=timeTraj(1,1):timeTraj(2,1);time_curTraj=time_curTraj';
            time_curTraj=curTraj(:,3)+1;
            if (find(time_curTraj==iFrame))
                spotID=spotID+1;
                traj2spot(iFrame,iTraj)=spotID;
            end
        end%if
    end%for
end%for


end%function

function [spotSpec]=eval_spotSpec(all_tr,traj2Cell_select,traj2spot,nSpot,pixSize,lagTime)
nSpecParam=21;
spotSpec=NaN(nSpot,nSpecParam);

for iSpotID=1:nSpot
    [iFrame,iTraj]=find(traj2spot==iSpotID);
    
%     curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
%     xTraj=curTraj(1:8:end);yTraj=curTraj(2:8:end);ampl=curTraj(4:8:end);
    curTraj=all_tr(all_tr(:,4)==iTraj,:);
    xTraj=curTraj(:,1);yTraj=curTraj(:,2);ampl=curTraj(:,5);
    
%     timeTraj=lstTraj(iTraj).seqOfEvents;
%     time_curTraj=timeTraj(1,1):timeTraj(2,1);time_curTraj=time_curTraj';
    time_curTraj=curTraj(:,3)+1;
        
    iFrame_ind=find(time_curTraj==iFrame);
%    xTraj=xTraj(iFrame_ind)*pixSize;yTraj=yTraj(iFrame_ind)*pixSize;ampl=ampl(iFrame_ind);% sub -1 on pixel?
    xTraj=xTraj(iFrame_ind);yTraj=yTraj(iFrame_ind);ampl=ampl(iFrame_ind);% sub -1 on pixel?   
    
    frame_curTraj=time_curTraj(iFrame_ind);
    time_curTraj=(time_curTraj(iFrame_ind)-1)*lagTime;
    
    spotSpec(iSpotID,1) =iSpotID;%Spot ID
    spotSpec(iSpotID,2) =iSpotID;%name Spot ID
    spotSpec(iSpotID,3) =-1;%QUALITY;
    spotSpec(iSpotID,4) =time_curTraj;%POSITION_T;
    spotSpec(iSpotID,5) =ampl;%MAX_INTENSITY;
    spotSpec(iSpotID,6) =frame_curTraj;%FRAME;
    spotSpec(iSpotID,7) =ampl;%MEDIAN_INTENSITY;
    spotSpec(iSpotID,8) =1;%VISIBILITY;
    spotSpec(iSpotID,9) =ampl;%MEAN_INTENSITY;
    spotSpec(iSpotID,10)=ampl;%TOTAL_INTENSITY;
    spotSpec(iSpotID,11)=0.1;%ESTIMATED_DIAMETER;
    spotSpec(iSpotID,12)=0.1;%RADIUS;
    spotSpec(iSpotID,13)=-1;%SNR;
    spotSpec(iSpotID,14)=xTraj;%POSITION_X;
    spotSpec(iSpotID,15)=yTraj;%POSITION_Y;
    spotSpec(iSpotID,16)=-1;%STANDARD_DEVIATION;
    spotSpec(iSpotID,17)=-1;%CONTRAST;
    spotSpec(iSpotID,18)=-10921639;%MANUAL_COLOR;
    spotSpec(iSpotID,19)=ampl;%MIN_INTENSITY;
    spotSpec(iSpotID,20)=0;%POSITION_Z;
    spotSpec(iSpotID,21)=traj2Cell_select(iTraj);%CELL_ID ;
end

end



function editXML_tracks_Sel(fDest,all_tr,traj2Cell_select,traj2spot,spotSpec,lagTime,pixSize,tabForBS,tabKeep)
nTraj=max(all_tr(:,4));%numel(lstTraj);
[trajSpec,lstTrajExport]=eval_trajSpec_Sel(all_tr,traj2Cell_select,traj2spot,lagTime,pixSize,tabForBS,tabKeep);

line='    <AllTracks>';
fprintf(fDest, '%s\n', line);

% Loop tracks
nTrajExport=numel(lstTrajExport);
for iTrajExp=1:nTrajExport
    trajID=lstTrajExport(iTrajExp);
    line=strcat(['      <Track name="Track_',num2str(trajSpec(iTrajExp,1)-1)]);
    line=strcat([line,'" TRACK_ID="',num2str(trajSpec(iTrajExp,2)-1)]);
    line=strcat([line,'" NUMBER_SPOTS="',num2str(trajSpec(iTrajExp,3))]);
    line=strcat([line,'" NUMBER_GAPS="',num2str(trajSpec(iTrajExp,4))]);
    line=strcat([line,'" LONGEST_GAP="',num2str(trajSpec(iTrajExp,5))]);
    line=strcat([line,'" NUMBER_SPLITS="',num2str(trajSpec(iTrajExp,6))]);
    line=strcat([line,'" NUMBER_MERGES="',num2str(trajSpec(iTrajExp,7))]);
    line=strcat([line,'" NUMBER_COMPLEX="',num2str(trajSpec(iTrajExp,8))]);
    line=strcat([line,'" TRACK_DURATION="',num2str(trajSpec(iTrajExp,9))]);
    line=strcat([line,'" TRACK_START="',num2str(trajSpec(iTrajExp,10))]);
    line=strcat([line,'" TRACK_STOP="',num2str(trajSpec(iTrajExp,11))]);
    line=strcat([line,'" TRACK_DISPLACEMENT="',num2str(trajSpec(iTrajExp,12))]);
    line=strcat([line,'" TRACK_INDEX="',num2str(trajSpec(iTrajExp,13)-1)]);
    line=strcat([line,'" TRACK_X_LOCATION="',num2str(trajSpec(iTrajExp,14))]);
    line=strcat([line,'" TRACK_Y_LOCATION="',num2str(trajSpec(iTrajExp,15))]);
    line=strcat([line,'" TRACK_Z_LOCATION="',num2str(trajSpec(iTrajExp,16))]);
    line=strcat([line,'" TRACK_MEAN_SPEED="',num2str(trajSpec(iTrajExp,17))]);
    line=strcat([line,'" TRACK_MAX_SPEED="',num2str(trajSpec(iTrajExp,18))]);
    line=strcat([line,'" TRACK_MIN_SPEED="',num2str(trajSpec(iTrajExp,19))]);
    line=strcat([line,'" TRACK_MEDIAN_SPEED="',num2str(trajSpec(iTrajExp,20))]);
    line=strcat([line,'" TRACK_STD_SPEED="',num2str(trajSpec(iTrajExp,21))]);
    line=strcat([line,'" TRACK_MEAN_QUALITY="',num2str(trajSpec(iTrajExp,22))]);
    line=strcat([line,'" TRACK_MAX_QUALITY="',num2str(trajSpec(iTrajExp,23))]);
    line=strcat([line,'" TRACK_MIN_QUALITY="',num2str(trajSpec(iTrajExp,24))]);
    line=strcat([line,'" TRACK_MEDIAN_QUALITY="',num2str(trajSpec(iTrajExp,25))]);
    line=strcat([line,'" TRACK_STD_QUALITY="',num2str(trajSpec(iTrajExp,26))]);
    line=strcat([line,'" TRACK_STATUS="',num2str(trajSpec(iTrajExp,27))]);
    line=strcat([line,'" TRACK_DIFF="',num2str(trajSpec(iTrajExp,28))]);
    line=strcat([line,'">']);
    fprintf(fDest, '%s\n', line);
    
    % - HERE
    [edgeSpec,nEdge]=eval_edgeSpec(traj2spot,spotSpec,trajID);
    %disp(trajID);
    %disp(edgeSpec);
    for iEdge=1:nEdge
        line=strcat(['        <Edge SPOT_SOURCE_ID="',num2str(edgeSpec(iEdge,1))]);
        line=strcat([line,'" SPOT_TARGET_ID="',num2str(edgeSpec(iEdge,2))]);
        line=strcat([line,'" EDGE_TIME="',num2str(edgeSpec(iEdge,3))]);
        line=strcat([line,'" EDGE_X_LOCATION="',num2str(edgeSpec(iEdge,4))]);
        line=strcat([line,'" EDGE_Y_LOCATION="',num2str(edgeSpec(iEdge,5))]);
        line=strcat([line,'" EDGE_Z_LOCATION="',num2str(edgeSpec(iEdge,6))]);
        line=strcat([line,'" VELOCITY="',num2str(edgeSpec(iEdge,7))]);
        line=strcat([line,'" DISPLACEMENT="',num2str(edgeSpec(iEdge,8))]);
        line=strcat([line,'" />']);
        fprintf(fDest, '%s\n', line);
    end%for
    line='      </Track>';
    fprintf(fDest, '%s\n', line);
end

line='    </AllTracks>';
fprintf(fDest, '%s\n', line);

line='    <FilteredTracks>';
fprintf(fDest, '%s\n', line);

for iTraj=1:nTraj
    if ((traj2Cell_select(iTraj)>0)&(tabKeep(iTraj)>0))
        line=strcat(['      <TrackID TRACK_ID="',num2str(iTraj-1),'" />']);
        fprintf(fDest, '%s\n', line);
    end%if
end%for
line='    </FilteredTracks>';
fprintf(fDest, '%s\n', line);
end%function


function [trajSpec,lstTrajExport]=eval_trajSpec_Sel(all_tr,traj2Cell_select,traj2spot,lagTime,pixSize,tabForBS,tabKeep)
%tabForBS=[iCell*ones(size(tabStatus)),trajID,tabStatus,tabSpeed,tabD,durTrack,startTrack,cell_area*ones(totalTraj,1)];

lstTrajExport=find((traj2Cell_select>0)&(tabKeep>0));

nSpecParam=28;
nTrajExport=numel(lstTrajExport);
trajSpec=NaN(nTrajExport,nSpecParam);

for iTrajExp=1:nTrajExport
    trajID=lstTrajExport(iTrajExp);
    index_tabForBS=find(tabForBS(:,2)==trajID);
    
    %     curTraj=lstTraj(trajID).tracksCoordAmpCG;curTraj=curTraj';
    %     xTraj=curTraj(1:8:end);yTraj=curTraj(2:8:end);ampl=curTraj(4:8:end);
    curTraj=all_tr(all_tr(:,4)==trajID,:);
    xTraj=curTraj(:,1);yTraj=curTraj(:,2);ampl=curTraj(:,5);
    
    if (isempty(index_tabForBS))
        figure(50);hold on;plot(xTraj,yTraj,'m')
    end
    %     timeTraj=lstTraj(trajID).seqOfEvents;
    %     time_curTraj=timeTraj(1,1):timeTraj(2,1);time_curTraj=time_curTraj';
    time_curTraj=curTraj(:,3)+1;
    
    nTrajSpot=traj2spot(:,trajID);nTrajSpot=sum(~isnan(nTrajSpot));
    trajDuration=(time_curTraj(end)-time_curTraj(1))*lagTime;
    trajStart=(time_curTraj(1)-1)*lagTime;
    trajStop=(time_curTraj(end)-1)*lagTime;
    trajDisplacement=sqrt(((xTraj(end)-xTraj(1))^2+(yTraj(end)-yTraj(1))^2))*pixSize;
    trajX_loc = mean(xTraj)*pixSize;
    trajY_loc = mean(yTraj)*pixSize;
    
    trajSpec(iTrajExp,1) =trajID;%name
    trajSpec(iTrajExp,2) =trajID;%TRACK_ID
    trajSpec(iTrajExp,3) =nTrajSpot;%NUMBER_SPOTS
    trajSpec(iTrajExp,4) =0;%NUMBER_GAPS
    trajSpec(iTrajExp,5) =-1;%LONGEST_GAP
    trajSpec(iTrajExp,6) =-1;%NUMBER_SPLITS
    trajSpec(iTrajExp,7) =-1;%NUMBER_MERGES
    trajSpec(iTrajExp,8) =-1;%NUMBER_COMPLEX
    trajSpec(iTrajExp,9) =trajDuration;%TRACK_DURATION
    trajSpec(iTrajExp,10)=trajStart;%TRACK_START
    trajSpec(iTrajExp,11)=trajStop;%TRACK_STOP
    trajSpec(iTrajExp,12)=trajDisplacement;%TRACK_DISPLACEMENT
    trajSpec(iTrajExp,13)=trajID;%TRACK_INDEX
    trajSpec(iTrajExp,14)=trajX_loc;%TRACK_X_LOCATION
    trajSpec(iTrajExp,15)=trajY_loc;%TRACK_Y_LOCATION
    trajSpec(iTrajExp,16)=0;%TRACK_Z_LOCATION
    if (tabForBS(index_tabForBS,3)==1)
        trajSpec(iTrajExp,17)=1000*tabForBS(index_tabForBS,4);%TRACK_MEAN_SPEED
    else
        trajSpec(iTrajExp,17)=-1;%TRACK_MEAN_SPEED
    end
    trajSpec(iTrajExp,18)=-1;%TRACK_MAX_SPEED
    trajSpec(iTrajExp,19)=-1;%TRACK_MIN_SPEED
    trajSpec(iTrajExp,20)=-1;%TRACK_MEDIAN_SPEED
    trajSpec(iTrajExp,21)=-1;%TRACK_STD_SPEED
    trajSpec(iTrajExp,22)=-1;%TRACK_MEAN_QUALITY
    trajSpec(iTrajExp,23)=-1;%TRACK_MAX_QUALITY
    trajSpec(iTrajExp,24)=-1;%TRACK_MIN_QUALITY
    trajSpec(iTrajExp,25)=-1;%TRACK_MEDIAN_QUALITY
    trajSpec(iTrajExp,26)=-1;%TRACK_STD_QUALITY
    trajSpec(iTrajExp,27)=tabForBS(index_tabForBS,3);%TRACK_STATUS
    if (tabForBS(index_tabForBS,3)==2)
        trajSpec(iTrajExp,28)=1000*tabForBS(index_tabForBS,5);%TRACK_DIFFCOEFF
    else
        trajSpec(iTrajExp,28)=-1;%TRACK_DIFFCOEFF
    end
end

end%function

function [edgeSpec,nEdge]=eval_edgeSpec(traj2spot,spotSpec,trajID)
lstSpot=traj2spot(:,trajID);
lstSpot(isnan(lstSpot))=[];
nEdge=numel(lstSpot)-1;
edgeSpec=NaN(nEdge,8);
for iEdge=1:nEdge
    edgeSpec(iEdge,1)=lstSpot(iEdge);
    edgeSpec(iEdge,2)=lstSpot(iEdge+1);
    
    edgeSpec(iEdge,3)=0.5*(spotSpec(edgeSpec(iEdge,1),4)+spotSpec(edgeSpec(iEdge,2),4));
    edgeSpec(iEdge,4)=0.5*(spotSpec(edgeSpec(iEdge,1),14)+spotSpec(edgeSpec(iEdge,2),14));
    edgeSpec(iEdge,5)=0.5*(spotSpec(edgeSpec(iEdge,1),15)+spotSpec(edgeSpec(iEdge,2),15));
    edgeSpec(iEdge,6)=0;
    edgeSpec(iEdge,7)=-1;
    edgeSpec(iEdge,8)=-1;
end

end%function