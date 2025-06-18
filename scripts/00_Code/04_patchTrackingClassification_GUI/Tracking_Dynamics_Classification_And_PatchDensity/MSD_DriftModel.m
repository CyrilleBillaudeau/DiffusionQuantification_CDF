function [tabDrift]=MSD_DriftModel(tr,nTrack,minTrcLgth,pixSize,lagTime,doPlot)
%nTrack=totalTraj;minTrcLgth,pixSize,lagTime,doPlot
if (nargin==5)
    doPlot=1;
end

tabDrift=NaN(nTrack,3);

% -- Cyrille / Bugs fixed 210721 
%curvMSD=NaN(121,nTrack);
lastFrameCell=0;
% figure(500);
% figure(501);
for iTrc=1:nTrack
    timeTrc=tr(tr(:,4)==iTrc,3);
    lastFrameCell=max([lastFrameCell,max(timeTrc)]);
end%for
curvMSD=NaN(lastFrameCell,nTrack);
% -- Cyrille / Bugs fixed 210721 (end)

if (doPlot>0);figure(2);end;
for iTrc=1:nTrack
    indx=find(tr(:,4)==iTrc);
    data=[tr(indx,1) tr(indx,2)]*pixSize;
    nData = size(data,1); %# number of data points
    missedDetection=sum(isnan(data(:,1)));
    durTrack(iTrc)=size(data,1)-missedDetection;
    
    if (durTrack(iTrc)>=minTrcLgth)
        
        nData = size(data,1); %# number of data points
        numberOfDeltaT = floor(nData*7/8); %# for MSD, dt should be up to 1/4 of number of data points
        %     numberOfDeltaT = floor(nData)-1; %# for MSD, dt should be up to 1/4 of number of data points
        
        msd = zeros(numberOfDeltaT,3); %# We'll store [mean, std, n]
        
        %# calculate msd for all deltaT's
        
        for dt = 1:numberOfDeltaT
            deltaCoords = data(1+dt:end,1:2) - data(1:end-dt,1:2);
            squaredDisplacement = nansum(deltaCoords.^2,2); %# dx^2+dy^2+dz^2
            
            msd(dt,1) = mean(squaredDisplacement); %# average squared root
            msd(dt,2) = std(squaredDisplacement); %# std
            msd(dt,3) = length(squaredDisplacement); %# n
        end
        
        patch(iTrc).msd=msd(:,1);
        curvMSD(1:numel(msd(:,1)),iTrc)=msd(:,1);
        y=patch(iTrc).msd;
        x=[1:length(y)]';x=x*lagTime;        

        [resParam]=fit_expMSD_Drift(x,y,msd(:,2));
        DtrackZY=resParam(1,2);
        speedTrackZY=resParam(1,1);
        %[resParam]=fit_expMSD_Drift_woNoise(x,y,msd(:,2));
        %DtrackZY=0;
        %speedTrackZY=resParam(1,1);
        %stats1=resParam(2,3);
        
        
        % MSD Fit on log-log plot
        xL=log(x);yL=log(y);
        p = polyfit(xL,yL,1);
        tabAlpha(iTrc)=p(1);
        %figure(501);hold on;plot(tabStatus(iTrc),p(1),'ko');
        tabDrift(iTrc,:)=[speedTrackZY,DtrackZY,resParam(2,3)];

%         if (doPlot>0)
%             figure(2);
%             switch tabStatus(iTrc)
%                 case 1
%                     subplot(3,3,4),plot(x,y);ylim([0 0.5]);hold on
%                     subplot(3,3,1),plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on
%                 case 2
%                     subplot(3,3,5),plot(x,y);ylim([0 0.5]);hold on
%                     subplot(3,3,2),plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on
%                 case 3
%                     subplot(3,3,7),plot(x,y);ylim([0 0.5]);hold on
%                     subplot(3,3,3),plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on
%                 case 0
%                     subplot(3,3,8),plot(x,y);ylim([0 0.5]);hold on
%                     subplot(3,3,6),plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on
%                     %disp([stats1(1),stats2(1)])
%                     %figure(11);clf;plot(x,y);pause();
%                     %figure(10)
%             end
%         end%if doPlot
    else
        patch(iTrc).msd=[];
    end%if (timePoints)
    %pause()

end%for

% % % 
% % % figure(900);clf;hold on;
% % % for iTrc=1:nTrack
% % %     if (tabStatus(iTrc)==3)
% % %         indx=find(tr(:,4)==iTrc);
% % %         data=[tr(indx,1) tr(indx,2)]*pixSize;
% % %         nData = size(data,1); %# number of data points
% % %         durTrack(iTrc)=size(data,1);
% % %         plot(data(:,1),data(:,2));
% % %         axis equal
% % %     end%if
% % % end%for
% % % figure(901);clf;hold on;
% % % for iTrc=1:nTrack
% % %     if (tabStatus(iTrc)==2)
% % %         indx=find(tr(:,4)==iTrc);
% % %         data=[tr(indx,1) tr(indx,2)]*pixSize;
% % %         nData = size(data,1); %# number of data points
% % %         durTrack(iTrc)=size(data,1);
% % %         plot(data(:,1),data(:,2));
% % %         axis equal
% % %     end%if
% % % end%for

end%function