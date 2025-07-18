function exportClassifiedTracks4TrackMate(imgFilename,pathImg,all_tr,traj2Cell,pixSize,lagTime,tabForBS,cellDescription)
disp('Export to trackmate is starting');
pathFct=mfilename('fullpath');
%disp(pathFct);
pathFct=pathFct(1:max(strfind(pathFct,filesep)));
path_xmlTemplate=strcat([pathFct,'templates_xml',filesep]);
%disp(path_xmlTemplate);


img_info=imfinfo(imgFilename);
nFrame=numel(img_info);
imW=img_info(1).Width;
imH=img_info(1).Height;

xmlFilename=strcat([imgFilename(1:(end-4)),'.xml']);
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
traj2Cell_select=traj2Cell;
cell_remove=find(cellDescription(:,7)==0);
nCell_rm=numel(cell_remove);
for iCell_rm=1:nCell_rm
    traj2Cell_select(traj2Cell_select==cell_remove(iCell_rm))=-2;
end
nSpot=get_nSpot(all_tr,traj2Cell_select);
line=strcat(['    <AllSpots nspots="',num2str(nSpot),'">']);
fprintf(fDest, '%s\n', line);
disp('XML: edit spot features');
[traj2spot,spotSpec]=editXML_spot(fDest,all_tr,traj2Cell_select,nSpot, nFrame,pixSize,lagTime);
disp('XML: edit track/edge features');
editXML_tracks(fDest,all_tr,traj2Cell_select,traj2spot,spotSpec,lagTime,pixSize,tabForBS,cellDescription);

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
disp('Export to trackmate done!');
end

function nSpot=get_nSpot(all_tr,traj2Cell)
nSpot=0;
nTraj=max(all_tr(:,4));%numel(lstTraj);

for iTraj=1:nTraj
    if (traj2Cell(iTraj)>0)
        %curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
        %tmpTraj=curTraj(1:8:end);
        %nSpot=nSpot+numel(tmpTraj);
        curTraj=all_tr(all_tr(:,4)==iTraj,:);
        nSpot=nSpot+size(curTraj,1);
    end
end
end%function


function [traj2spot,spotSpec]=editXML_spot(fDest,all_tr,traj2Cell,nSpot, nFrame,pixSize,lagTime)

traj2spot=edit_traj2spot(all_tr,traj2Cell,nFrame);
[spotSpec]=eval_spotSpec(all_tr,traj2Cell,traj2spot,nSpot,pixSize,lagTime);

for iFrame=1:nFrame
    line=strcat(['      <SpotsInFrame frame="',num2str(iFrame-1),'">']);
    fprintf(fDest, '%s\n', line);
    lstSpotID=traj2spot(iFrame,:);lstSpotID(isnan(lstSpotID))=[];
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

function traj2spot=edit_traj2spot(all_tr,traj2Cell,nFrame)
nTraj=max(all_tr(:,4));%numel(lstTraj);
traj2spot=NaN(nFrame,nTraj);

spotID=0;
for iFrame=1:nFrame
    for iTraj=1:nTraj
        if (traj2Cell(iTraj)>0)
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

function [spotSpec]=eval_spotSpec(all_tr,traj2Cell,traj2spot,nSpot,pixSize,lagTime)
nSpecParam=21;
spotSpec=NaN(nSpot,nSpecParam);

for iSpotID=1:nSpot
    [iFrame,iTraj]=find(traj2spot==iSpotID);
    
    %curTraj=lstTraj(iTraj).tracksCoordAmpCG;curTraj=curTraj';
    %xTraj=curTraj(1:8:end);yTraj=curTraj(2:8:end);ampl=curTraj(4:8:end);
    curTraj=all_tr(all_tr(:,4)==iTraj,:);    
    xTraj=curTraj(:,1);yTraj=curTraj(:,2);ampl=curTraj(:,5);
    
%     timeTraj=lstTraj(iTraj).seqOfEvents;
%     time_curTraj=timeTraj(1,1):timeTraj(2,1);time_curTraj=time_curTraj';
    time_curTraj=curTraj(:,3)+1;
    
    iFrame_ind=find(time_curTraj==iFrame);
    %xTraj=xTraj(iFrame_ind)*pixSize;yTraj=yTraj(iFrame_ind)*pixSize;ampl=ampl(iFrame_ind);% sub -1 on pixel?
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
    spotSpec(iSpotID,21)=traj2Cell(iTraj);%CELL_ID ;
end

end



function editXML_tracks(fDest,all_tr,traj2Cell,traj2spot,spotSpec,lagTime,pixSize,tabForBS,cellDescription)
nTraj=max(all_tr(:,4));%numel(lstTraj);
[trajSpec,lstTrajExport]=eval_trajSpec(all_tr,traj2Cell,traj2spot,lagTime,pixSize,tabForBS,cellDescription);

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
        line=strcat([line,'" LINK_COST="',num2str(edgeSpec(iEdge,3))]);
        line=strcat([line,'" EDGE_TIME="',num2str(edgeSpec(iEdge,4))]);
        line=strcat([line,'" EDGE_X_LOCATION="',num2str(edgeSpec(iEdge,5))]);
        line=strcat([line,'" EDGE_Y_LOCATION="',num2str(edgeSpec(iEdge,6))]);
        line=strcat([line,'" EDGE_Z_LOCATION="',num2str(edgeSpec(iEdge,7))]);
        line=strcat([line,'" VELOCITY="',num2str(edgeSpec(iEdge,8))]);
        line=strcat([line,'" DISPLACEMENT="',num2str(edgeSpec(iEdge,9))]);
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
    if (traj2Cell(iTraj)>0)
        line=strcat(['      <TrackID TRACK_ID="',num2str(iTraj-1),'" />']);
        fprintf(fDest, '%s\n', line);
    end%if
end%for
line='    </FilteredTracks>';
fprintf(fDest, '%s\n', line);
end%function


function [trajSpec,lstTrajExport]=eval_trajSpec(all_tr,traj2Cell,traj2spot,lagTime,pixSize,tabForBS,cellDescription)
%tabForBS=[iCell*ones(size(tabStatus)),trajID,tabStatus,tabSpeed,tabD,durTrack,startTrack,cell_area*ones(totalTraj,1)];

lstTrajExport=find(traj2Cell>0); % -- associate to a cell (even the one remove from analysis because too small)
%lstTrajExport=lstTrajExport(cellDescription(traj2Cell(lstTrajExport),7)>0); % remove traj associated to removed cells

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
% Model:
% SPOT_SOURCE_ID="379377" 
% SPOT_TARGET_ID="379415" 
% LINK_COST="0.023292378570377987" 
% EDGE_TIME="77.38050000000001" 
% EDGE_X_LOCATION="14.129516667266246" 
% EDGE_Y_LOCATION="6.65493491677673" 
% EDGE_Z_LOCATION="0.0" 
% VELOCITY="0.23371884894352837" 
% DISPLACEMENT="0.15261840836012538" 

for iEdge=1:nEdge
    edgeSpec(iEdge,1)=lstSpot(iEdge);%SPOT_SOURCE_ID
    edgeSpec(iEdge,2)=lstSpot(iEdge+1);%SPOT_TARGET_ID
    edgeSpec(iEdge,3)=-1;%LINK_COST
    edgeSpec(iEdge,4)=0.5*(spotSpec(edgeSpec(iEdge,1),4)+spotSpec(edgeSpec(iEdge,2),4));%EDGE_TIME
    edgeSpec(iEdge,5)=0.5*(spotSpec(edgeSpec(iEdge,1),14)+spotSpec(edgeSpec(iEdge,2),14));%EDGE_X_LOCATION
    edgeSpec(iEdge,6)=0.5*(spotSpec(edgeSpec(iEdge,1),15)+spotSpec(edgeSpec(iEdge,2),15));%EDGE_Y_LOCATION
    edgeSpec(iEdge,7)=0;%EDGE_Z_LOCATION
    curDisp=sqrt((spotSpec(edgeSpec(iEdge,1),14)-spotSpec(edgeSpec(iEdge,2),14))^2+(spotSpec(edgeSpec(iEdge,1),15)-spotSpec(edgeSpec(iEdge,2),15))^2);
    edgeSpec(iEdge,8)=curDisp/(spotSpec(edgeSpec(iEdge,2),4)-spotSpec(edgeSpec(iEdge,1),4));%VELOCITY
    edgeSpec(iEdge,9)=curDisp;%DISPLACEMENT
end

% for iEdge=1:nEdge
%     edgeSpec(iEdge,1)=lstSpot(iEdge);%SPOT_SOURCE_ID
%     edgeSpec(iEdge,2)=lstSpot(iEdge+1);%SPOT_TARGET_ID
%     
%     edgeSpec(iEdge,3)=0.5*(spotSpec(edgeSpec(iEdge,1),4)+spotSpec(edgeSpec(iEdge,2),4));%EDGE_TIME
%     edgeSpec(iEdge,4)=0.5*(spotSpec(edgeSpec(iEdge,1),14)+spotSpec(edgeSpec(iEdge,2),14));%EDGE_X_LOCATION
%     edgeSpec(iEdge,5)=0.5*(spotSpec(edgeSpec(iEdge,1),15)+spotSpec(edgeSpec(iEdge,2),15));%EDGE_Y_LOCATION
%     edgeSpec(iEdge,6)=0;%EDGE_Z_LOCATION
%     edgeSpec(iEdge,7)=-1;%VELOCITY
%     edgeSpec(iEdge,8)=-1;%DISPLACEMENT
% end


end%function