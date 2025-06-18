function [tabStatus,tabSpeed,tabD,tabD_static,tabAlpha, durTrack]=getDynStatusMSDanalysis(all_tr,nTraj,thldR2diff,thldR2dir,pixelSize,lagTime)

durTrack=zeros(nTraj,1);
tabStatus=-ones(nTraj,1);
tabSpeed=NaN(nTraj,1);
tabD=NaN(nTraj,1);
tabD_static=NaN(nTraj,1);
tabAlpha=NaN(nTraj,1);

doPlot=0;
minTrcLgth=10;%local variable to perform MSD analysis

for iTraj=1:nTraj
    indx=find(all_tr(:,4)==iTraj);
    data=[all_tr(indx,1) all_tr(indx,2)]*pixelSize;
    nData = size(data,1); %# number of data points
    %missedDetection=sum(isnan(data(:,1)));
    %durTrack(iTraj)=size(data,1)-missedDetection;
    durTrack(iTraj)=nData;
    disp(strcat(['Traj: ',num2str(iTraj),' - duration: ',num2str(durTrack(iTraj))]))
    %if (durTrack(iTraj)>=minTrcLgth)
    if (nData>=minTrcLgth)
        
        %nData = size(data,1); %# number of data points        
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
        
        patch(iTraj).msd=msd(:,1);
        curvMSD(1:numel(msd(:,1)),iTraj)=msd(:,1);
        y=patch(iTraj).msd;
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
        if (numel(xL)>=2)
            p = polyfit(xL,yL,1);
            tabAlpha(iTraj)=p(1);
            % figure(501);hold on;plot(tabStatus(iTrc),p(1),'ko');
            %figure(650);clf;plot(data(:,1)-data(1,1),data(:,2)-data(1,2));hold on; plot(-0.25,-0.25,'k+');plot(-0.25,+0.25,'k+');plot(+0.25,+0.25,'k+');plot(+0.25,-0.25,'k+');axis equal
            %xlim(0.25*[-1, 1]);ylim(0.25*[-1, 1]);axis square
            %figure(651);clf;plot(x,y);hold on; plot(x,y+msd(:,2),'k--'); plot(x,y-msd(:,2),'k--');ylabel('MSD')
            disp(strcat(['Directed: ',num2str(stats2(1))]))
            disp(strcat(['Diffused: ',num2str(stats1(1))]))
            disp(strcat(['alpha: ',num2str(tabAlpha(iTraj))]))

            % pause()
        else
            tabAlpha(iTraj)=0;
        end        
        %         thldR2diff=0.8;
        %         thldR2dir=0.8;
        %if stats1(1) < thldR2diff & stats2(1) < thldR2dir & max(y)  <0.05        
        confinement_strength=analyze_distance_traj_single([all_tr(indx,1) all_tr(indx,2)]*pixelSize);
        %if max(y)  <(0.05) % 0.05; BEST SOLUTION??
        if (max(confinement_strength)<=0.25)
        %if ((tabAlpha(iTrc)<0.5)&(tabAlpha(iTrc)>=0.0))
            tabSpeed(iTraj)=NaN; tabD_static(iTraj)=DtrackZY; tabStatus(iTraj)=3; % static patches
        else
            if stats1(1)>thldR2diff & stats1(1) > stats2(1)
                tabSpeed(iTraj)=NaN; tabD(iTraj)=DtrackZY; tabStatus(iTraj)=2; % random diffusion
            end
            if stats2(1)>thldR2dir & stats2(1) > stats1(1) %& max(y) > 0.1
                tabSpeed(iTraj)=speedTrackZY; tabD(iTraj)=NaN; tabStatus(iTraj)=1; % active movement
            end
            if stats1(1)<=thldR2diff & stats2(1)<=thldR2dir
                tabSpeed(iTraj)=NaN; tabD(iTraj)=NaN; tabStatus(iTraj)=0; % unclassified
            end            
        end
%         if (tabStatus(iTraj)==2)
%             disp([iTraj,tabStatus(iTraj),tabD(iTraj),exp(p(2))/4])
%         end%if
%         if (tabStatus(iTraj)==3)
%             disp([iTraj,tabStatus(iTraj),-1,exp(p(2))/4])
%         end%if
%         colorStatus=['b','r','g'];
%         if (tabStatus(iTraj)>0)
%             %figure(500);hold on;plot(x,log(y),colorStatus(tabStatus(iTraj)));
%             figure(500);hold on;loglog(x,y,colorStatus(tabStatus(iTraj)));
%         else
%             %figure(500);hold on;plot(x,log(y),'k');
%         end
%         figure(500);axCurFig=gca();axCurFig.YScale='log';axCurFig.XScale='log';
%         

        if (doPlot>0)
            figure(2);
            switch tabStatus(iTraj)
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
        if 0%(1&tabStatus(iTraj)==0)
            xx=data(:,1)-data(1,1);xx=1000*xx;
            yy=data(:,2)-data(1,2);yy=1000*yy;
            XYLIM=max([abs(xx);abs(yy)]);;
            XYLIM=750;
            figure(760);clf;hold on;plot(xx,yy);plot(xx,yy,'k.');xlim([-XYLIM,XYLIM]);ylim([-XYLIM,XYLIM]);axis square
            figure(770);clf;hold on;plot(msd(:,1));plot(msd(:,1),'k.');
            tabStatus(iTraj)
            %analyze_distance_traj_single([tr(indx,1) tr(indx,2)]*pixSize);
            pause();
        end%if
    else
        patch(iTraj).msd=[];
    end%if (timePoints)
    disp(['Traj status: ',num2str(tabStatus(iTraj))])
    %pause()

end%for



end%function