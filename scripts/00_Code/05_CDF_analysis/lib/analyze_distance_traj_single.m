function confinement_strength=analyze_distance_traj_single(data)
doPlotConfinement=0;
nData=size(data,1);

tab_track_disp_avg=NaN(nData,1);
for dt=1:(nData-1)
    track_disp=data(1+dt:end,1:2) - data(1:end-dt,1:2);
    track_disp = sqrt(nansum(track_disp.^2,2)); %# dx^2+dy^2+dz^2

    tab_track_disp_avg(dt)=mean(track_disp);
end
% figure(909);clf;
% subplot(2,2,1);hold on; plot(data(:,1)-data(1,1)); plot([1, nData],0.250*[1 1],'k--'); plot([1, nData],-0.250*[1 1],'k--'); plot([1, nData],0.1*[1 1],'m--'); plot([1, nData],-0.1*[1 1],'m--')
% subplot(2,2,2);hold on; plot(data(:,2)-data(1,2)); plot([1, nData],0.250*[1 1],'k--'); plot([1, nData],-0.250*[1 1],'k--'); plot([1, nData],0.1*[1 1],'m--'); plot([1, nData],-0.1*[1 1],'m--')
% subplot(2,2,3);plot(tab_track_disp_avg);

dt=1;
track_disp=data(1+dt:end,1:2) - data(1:end-dt,1:2);
track_disp = sqrt(nansum(track_disp.^2,2)); %# dx^2+dy^2+dz^2

track_disp_avg=mean(track_disp);

track_disp_expected=track_disp_avg*nData;
track_disp_total=sum(track_disp);

traj_x=data(:,1);traj_y=data(:,2);
all_traj_distance=NaN(nData,nData);
for iData=1:nData
    all_traj_distance(:,iData)=sqrt((traj_x-traj_x(iData)).^2+(traj_y-traj_y(iData)).^2);
end
track_disp_max=max(all_traj_distance(:));
track_dist_fromT0=sqrt((traj_x-traj_x(1)).^2+(traj_y-traj_y(1)).^2);
fprintf("Expected dist / Total distance / Max distance / Distance T0 - Tf:")
disp([track_disp_expected,track_disp_total,track_disp_max, track_dist_fromT0(end)])
% figure(910);clf;hold on
% plot(data(:,1),data(:,2));plot(data(:,1),data(:,2),'k.');plot(data(1,1),data(1,2),'o');
% figure(920);clf;hold on
% plot([0;cumsum(track_disp)]./track_dist_fromT0)


confinement_strength=track_dist_fromT0/track_disp_expected;
if (doPlotConfinement)
    figure(915);clf;hold on
    plot(confinement_strength)
    ylabel('Confinement strength')
    %pause()
end

end%function