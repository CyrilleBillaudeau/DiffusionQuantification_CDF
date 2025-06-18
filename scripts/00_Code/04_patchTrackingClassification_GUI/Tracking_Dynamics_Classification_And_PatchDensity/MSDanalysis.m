function [tabStatus,tabSpeed,tabD,durTrack,curvMSD]=MSDanalysis(tr,nTrack,minTrcLgth,thldR2diff,thldR2dir,pixSize,lagTime,doPlot)
%nTrack=totalTraj;minTrcLgth,thldR2diff,thldR2dir,pixSize,lagTime,doPlot
if (nargin==7)
    doPlot=1;
end
durTrack=zeros(nTrack,1);
tabStatus=-ones(nTrack,1);
tabSpeed=NaN(nTrack,1);
tabD=NaN(nTrack,1);
tabAlpha=NaN(nTrack,1);
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
        %numberOfDeltaT = floor(nData*7/8); %# for MSD, dt should be up to 1/4 of number of data points
        numberOfDeltaT = floor(nData*5/8); %# for MSD, dt should be up to 1/4 of number of data points ADD A TEST IN CASE OF SHORT TRACES
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

        [resParam1,resParam2]=fit_expMSD(x,y,msd(:,2));
        DtrackZY=resParam1(1,1);
        speedTrackZY=resParam2(1,1);
        stats1(1)=resParam1(1,2);
        stats2(1)=resParam2(1,2);
        
        % MSD Fit on log-log plot
        x(y==0)=[];
        y(y==0)=[];
        xL=log(x);yL=log(y);
        p = polyfit(xL,yL,1);
        tabAlpha(iTrc)=p(1);
        %figure(501);hold on;plot(tabStatus(iTrc),p(1),'ko');
        
        %         thldR2diff=0.8;
        %         thldR2dir=0.8;
        %if stats1(1) < thldR2diff & stats2(1) < thldR2dir & max(y)  <0.05
        %if max(y)  <(0.05) % 0.05; BEST SOLUTION??
        confinement_strength=analyze_distance_traj_single([tr(indx,1) tr(indx,2)]*pixSize);
        if (max(confinement_strength)<=0.25)
        %if ((tabAlpha(iTrc)<0.5)&(tabAlpha(iTrc)>=0.0))
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
%         if (tabStatus(iTrc)==2)
%             disp([iTrc,tabStatus(iTrc),tabD(iTrc),exp(p(2))/4])
%         end%if
%         if (tabStatus(iTrc)==3)
%             disp([iTrc,tabStatus(iTrc),-1,exp(p(2))/4])
%         end%if
%         colorStatus=['b','r','g'];
%         if (tabStatus(iTrc)>0)
%             %figure(500);hold on;plot(x,log(y),colorStatus(tabStatus(iTrc)));
%             figure(500);hold on;loglog(x,y,colorStatus(tabStatus(iTrc)));
%         else
%             %figure(500);hold on;plot(x,log(y),'k');
%         end
%         figure(500);axCurFig=gca();axCurFig.YScale='log';axCurFig.XScale='log';
%         

        if (doPlot>0)
            figure(2);
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
        if 0%(1&tabStatus(iTrc)==0)
            xx=data(:,1)-data(1,1);xx=1000*xx;
            yy=data(:,2)-data(1,2);yy=1000*yy;
            XYLIM=max([abs(xx);abs(yy)]);
            figure(760);clf;hold on;plot(xx,yy);plot(xx,yy,'k.');xlim([-XYLIM,XYLIM]);ylim([-XYLIM,XYLIM]);axis square
            figure(770);clf;hold on;plot(msd(:,1));plot(msd(:,1),'k.');
            %tabStatus(iTrc)
            %analyze_distance_traj_single([tr(indx,1) tr(indx,2)]*pixSize);
            pause();
        end%if
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