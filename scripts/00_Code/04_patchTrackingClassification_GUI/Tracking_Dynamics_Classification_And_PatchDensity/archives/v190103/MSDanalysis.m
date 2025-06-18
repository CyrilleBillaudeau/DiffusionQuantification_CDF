function [tabStatus,tabSpeed,tabD,durTrack,curvMSD]=MSDanalysis(tr,nTrack,minTrcLgth,thldR2diff,thldR2dir,pixSize,lagTime,doPlot)
%nTrack=totalTraj;minTrcLgth,thldR2diff,thldR2dir,pixSize,lagTime,doPlot
if (nargin==7)
    doPlot=1;
end
durTrack=zeros(nTrack,1);
tabStatus=-ones(nTrack,1);
tabSpeed=NaN(nTrack,1);
tabD=NaN(nTrack,1);
curvMSD=NaN(121,nTrack);
if (doPlot>0);figure(2);end;
for iTrc=1:nTrack
    indx=find(tr(:,4)==iTrc);
    data=[tr(indx,1) tr(indx,2)]*pixSize;
    nData = size(data,1); %# number of data points
    durTrack(iTrc)=size(data,1);
    
    if (durTrack(iTrc)>=minTrcLgth)
        
        nData = size(data,1); %# number of data points
        numberOfDeltaT = floor(nData*7/8); %# for MSD, dt should be up to 1/4 of number of data points
        %     numberOfDeltaT = floor(nData)-1; %# for MSD, dt should be up to 1/4 of number of data points
        
        msd = zeros(numberOfDeltaT,3); %# We'll store [mean, std, n]
        
        %# calculate msd for all deltaT's
        
        for dt = 1:numberOfDeltaT
            deltaCoords = data(1+dt:end,1:2) - data(1:end-dt,1:2);
            squaredDisplacement = sum(deltaCoords.^2,2); %# dx^2+dy^2+dz^2
            
            msd(dt,1) = mean(squaredDisplacement); %# average squared root
            msd(dt,2) = std(squaredDisplacement); %# std
            msd(dt,3) = length(squaredDisplacement); %# n
        end
        
        patch(iTrc).msd=msd(:,1);
        curvMSD(1:numel(msd(:,1)),iTrc)=msd(:,1);
        y=patch(iTrc).msd;
        x=[1:length(y)]';x=x*lagTime;
        
        %         [b1,bint,r,rint,stats1] = regress(y,x); %% b1 means linear
        %         [b2,bint,r,rint,stats2] = regress(y,x.^2); %% b2 means second order
        %         DtrackZY=b1/4;
        %         speedTrackZY=sqrt(b2);
        [resParam1,resParam2]=fit_expMSD(x,y,msd(:,2));
        DtrackZY=resParam1(1,1);
        speedTrackZY=resParam2(1,1);
        stats1(1)=resParam1(1,2);
        stats2(1)=resParam2(1,2);
        %         thldR2diff=0.8;
        %         thldR2dir=0.8;
        %if stats1(1) < thldR2diff & stats2(1) < thldR2dir & max(y)  <0.05
        if max(y)  <0.05
            tabSpeed(iTrc)=0; tabD(iTrc)=0; tabStatus(iTrc)=3; % static patches
        else
            if stats1(1)>thldR2diff & stats1(1) > stats2(1)
                tabSpeed(iTrc)=0; tabD(iTrc)=DtrackZY; tabStatus(iTrc)=2; % random diffusion
            end
            if stats2(1)>thldR2dir & stats2(1) > stats1(1) %& max(y) > 0.1
                tabSpeed(iTrc)=speedTrackZY; tabD(iTrc)=0; tabStatus(iTrc)=1; % active movement
            end
            if stats1(1)<=thldR2diff & stats2(1)<=thldR2dir
                tabSpeed(iTrc)=0; tabD(iTrc)=0; tabStatus(iTrc)=0; % unclassified
            end
            
        end
        
        if (doPlot>0)
            switch tabStatus(iTrc)
                case 1
                    subplot(3,3,4),plot(x,y);ylim([0 0.5]);hold on
                    subplot(3,3,1),plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on
                case 2
                    subplot(3,3,5),plot(x,y);ylim([0 0.5]);hold on
                    subplot(3,3,2),plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on
                case 3
                    subplot(3,3,7),plot(x,y);ylim([0 0.5]);hold on
                    subplot(3,3,3),plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on
                case 0
                    subplot(3,3,8),plot(x,y);ylim([0 0.5]);hold on
                    subplot(3,3,6),plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on
                    %disp([stats1(1),stats2(1)])
                    %figure(11);clf;plot(x,y);pause();
                    %figure(10)
            end
        end%if doPlot
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