function analyze_distance_traj(tr,nTrack,minTrcLgth,thldR2diff,thldR2dir,pixSize,lagTime,doPlot)
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
        dt=1;

        track_disp=data(1+dt:end,1:2) - data(1:end-dt,1:2);
        track_disp = sqrt(nansum(track_disp.^2,2)); %# dx^2+dy^2+dz^2

        track_disp_avg=mean(track_disp);

        track_disp_expected=track_disp_avg*durTrack(iTrc);
        track_disp_total=sum(track_disp);

        traj_x=data(:,1);traj_y=data(:,2);
        all_traj_distance=NaN(nData,nData);
        for iData=1:nData
            all_traj_distance(:,iData)=sqrt((traj_x-traj_x(iData)).^2+(traj_y-traj_y(iData)).^2);
        end
        track_disp_max=max(all_traj_distance(:));
        track_dist_fromT0=sqrt((traj_x-traj_x(1)).^2+(traj_y-traj_y(1)).^2);
        fprintf("Expected dist / Total distance / Max distance / Distance T0 - Tf")
        disp([track_disp_expected,track_disp_total,track_disp_max, track_dist_fromT0(end)])
        figure(910);clf;hold on
        plot(data(:,1),data(:,2));plot(data(:,1),data(:,2),'k.');plot(data(1,1),data(1,2),'o');
        figure(915);clf;hold on
        plot(track_dist_fromT0/track_disp_expected)
        pause()
    end%if(durTrack(iTrc)>=minTrcLgth)
end%for iTrc=1:nTrack

end%function