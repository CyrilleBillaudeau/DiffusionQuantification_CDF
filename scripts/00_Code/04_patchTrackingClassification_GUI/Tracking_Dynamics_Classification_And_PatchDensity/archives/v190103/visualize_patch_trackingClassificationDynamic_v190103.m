function visualize_patch_trackingClassificationDynamic_v190103(displayParams)

if nargin==0
    statusPlot=3;
    nRepet=2;
    invertedCMAP=1;   
else
    %displayParams
    statusPlot=displayParams.statusPlot;
    nRepet=displayParams.nRepet;
    invertedCMAP=displayParams.invertedCMAP;   
end
%clear all;
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/IO_tools/');
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/Tracking_Dynamics_Classification_And_PatchDensity');

fileOut_tab_patchDensityDyn='tab_patchDensityDyn.txt';
fileOut_tab_patchDynamic='tab_patchDynamic.txt';
fileOut_cellDescription='cellDescription.txt';
fileOut_tabForBS='tabForBS.txt';
fileOut_paramMSDanalysis='paramMSDanalysis.txt';
fileOut_imgMask='cellMask_withLabelAndSpec.png';

[imgFilename,pathImg] = uigetfile('*.tif','Select only one file to visualize');

iFile=1;

cd(pathImg)


path_resUTrack=strcat([imgFilename(1:end-4),filesep,'TrackingPackage',filesep,'tracks']);
if (exist(path_resUTrack,'dir')==7)
    
    % spec file has been generated using a simple fiji macros to return
    % pixel size and lagTime. In future, we should fixed how metadata are
    % set in raw acquisition to skip this operation
    specFile=strcat([imgFilename(1:end-4),'_spec.txt']);
    specAcq=load(specFile);
    nFrame=specAcq(1);
    lagTime=specAcq(2);
    pixSize=specAcq(3);
    
    % Load raw acquistions
    imgInfo=imfinfo(imgFilename);
    imW=imgInfo(1).Width;imH=imgInfo(1).Height;
    img=zeros(imH,imW,nFrame);
    
    % classical imread is too fast, specially when files are on network. To
    % speed this function, it is better to add 'Info' option to avoid read
    % image info at each loading of the frame. Alternative options below
%     for iFrame=1:nFrame;
%         %disp(strcat(['Load imag #',num2str(iFrame),'/',num2str(nFrame)]));
%         img(:,:,iFrame)=imread(imgFilename,iFrame,'Info',imgInfo);
%     end
    
    imgInfo=imfinfo(imgFilename);
    imW=imgInfo(1).Width;imH=imgInfo(1).Height;   
    img=zeros(imH,imW,nFrame);%,'uint16');    
    TifLink = Tiff(imgFilename, 'r');
    for  iFrame=1:nFrame;
        TifLink.setDirectory(iFrame);
        img(:,:,iFrame)=TifLink.read();
    end
    TifLink.close();
    
    
    %% Cells mask (area, positions, and others)
    [cellMask,nCell,cellDescription]=getCellMask_Specifications(imgFilename);
    
    %% Load tracks from uTrack
    cd(path_resUTrack)
    D=load('Channel_1_tracking_result.mat');
    lstTraj=D.tracksFinal;
    nTraj=numel(lstTraj);
    cd(pathImg)
    
    % associate traj to cell
    traj2Cell=trajCell_associate(lstTraj,nTraj,cellDescription,nCell,cellMask);
    
end%if


path_resultMSDanalysis=strcat(['resultMSDanalysis',filesep,imgFilename(1:end-4)]);
if exist(path_resultMSDanalysis,'dir')==7
    cd(path_resultMSDanalysis);
    if (exist(fileOut_tab_patchDensityDyn))
        patchDensityDyn=load(fileOut_tab_patchDensityDyn);
    end
    if (exist(fileOut_tab_patchDynamic))
        patchDynamic=load(fileOut_tab_patchDynamic);
    end
    if (exist(fileOut_tabForBS))
        tabForBS=load(fileOut_tabForBS);
        trajStatus=tabForBS(:,3);
        trajID=tabForBS(:,2);        
    end
    cd(pathImg)
end

nTrajAss=numel(trajID);
lstTrajID=unique(trajID);
lstTrajAss=lstTraj;

for iTraj=nTraj:-1:1
    if isempty(find(lstTrajID==iTraj))
        lstTrajAss(iTraj)=[];
    end
end%if
trajStatusAss=trajStatus;


%{
%nTrajAss=sum(traj2Cell(:,1)>0);
lstTrajAss=lstTraj;

for iTraj=nTraj:-1:1
    if traj2Cell(iTraj,2)<=0
        lstTrajAss(iTraj)=[];
    end
end%if
nTrajAss=numel(lstTrajAss);

trajStatusAss=trajStatus(traj2Cell(traj2Cell(:,1)>0,2)>0);
%}


img_min=min(img,[],3);
img_display=img;
for iFrame=1:nFrame; img_display(:,:,iFrame)=img_display(:,:,iFrame)-img_min;end
img_display=max(img_display,[],3);
img_display=mean(img_display,3);
clim=quantile(img_display(:),[0.01 0.999]);
figure(700);clf;imagesc(img_display,clim);hold on;axis equal;colormap(gray)
%cellMaskContour=edge(imclose(cellMask>0,strel('disk',10)));
cellMaskContour=edge(cellMask>0);
[edgeI,edgeJ]=find(cellMaskContour>0);
plot(edgeJ,edgeI,'m.','MarkerSize',1);
for iCell=1:nCell;text(cellDescription(iCell,2)+10,cellDescription(iCell,3)+10,num2str(iCell),'Color','w');end

xlim([0 size(cellMask,2)]);ylim([0 size(cellMask,1)])
for iTraj=1:nTrajAss
    if (statusPlot <-1)
        [xTraj,yTraj,timeTraj]=extract_singleTrajCoordinates(lstTrajAss,iTraj);
        plot(xTraj,yTraj);
        axis ij; axis square
    else        
        if (trajStatusAss(iTraj)==statusPlot)
            [xTraj,yTraj,timeTraj]=extract_singleTrajCoordinates(lstTrajAss,iTraj);
            plot(xTraj,yTraj);
            axis ij; axis square
        end%if
    end
end


%% PLOT TRAJ WITH SPECIFIED STATUS
%nRepet=2;
figure(10);clf;
cmap=colormap(gray);
if (invertedCMAP>0); cmap=cmap(end:-1:1,:); end

for iRepet=1:nRepet
    disp(strcat(['Repetition #',num2str(iRepet),'/',num2str(nRepet)]))
    for iFrame=1:nFrame
        valPixel=img(:,:,iFrame);
        clim=quantile(valPixel(:),[0.01 0.9999]);

        figure(10);clf;imagesc(img(:,:,iFrame),clim);hold on;axis equal;colormap(cmap)
        if (statusPlot <-1)
            lstTrajPlot=find(trajStatusAss>=statusPlot);            
        else
            lstTrajPlot=find(trajStatusAss==statusPlot);
        end
        for iTrajPlot=1:numel(lstTrajPlot)
            iTraj=lstTrajPlot(iTrajPlot);
            [xTraj,yTraj,timeTraj]=extract_singleTrajCoordinates(lstTrajAss,iTraj);
            timeTraj=timeTraj(1,1):timeTraj(2,1);
            xTraj=xTraj(find(timeTraj==iFrame));yTraj=yTraj(find(timeTraj==iFrame));
            %plot(xTraj,yTraj,'ro')
            plot(xTraj,yTraj,'g+')
        end
        title(num2str(iFrame))
        pause(0.02)
    end%for
end%for


end%function


