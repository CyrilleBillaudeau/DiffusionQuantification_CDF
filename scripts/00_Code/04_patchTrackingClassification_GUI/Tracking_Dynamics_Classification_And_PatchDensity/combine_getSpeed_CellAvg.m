function [resultPlot_velocity]=combine_getSpeed_CellAvg(data_in,data_File,nFile,filename_label)

result_velocity=[data_File,data_in(:,7)/1000];

nVelocityPerFile=sum(result_velocity(:,1)==[1:nFile]);
resultPlot_velocity=NaN(max(nVelocityPerFile),nFile);

for iFile=1:nFile
    resultPlot_velocity(1:nVelocityPerFile(iFile),iFile)=result_velocity(result_velocity(:,1)==iFile,2);
end%for iFile

if (nFile>1)
    result_velocity_all=resultPlot_velocity(:);
    result_velocity_all(isnan(result_velocity_all))=[];    
    % bug correction (230922 - CB): in case of shorter array for
    % result_velocity_all, concatenation of arrays resultPlot_velocity and
    % result_velocity_all returns error.
    % previous code: resultPlot_velocity=[[resultPlot_velocity;NaN(size(result_velocity_all,1)-max(nVelocityPerFile),nFile)],result_velocity_all];
    
    nrows_diff=size(result_velocity_all,1)-max(nVelocityPerFile);
    if (nrows_diff>0)
        resultPlot_velocity=[[resultPlot_velocity;NaN(nrows_diff,nFile)],result_velocity_all];
    else
        resultPlot_velocity=[resultPlot_velocity,[result_velocity_all;NaN(-nrows_diff,1)]];
    end%if
    nFilePlot=nFile+1;
else
    nFilePlot=nFile;
end%if

figure(200);clf;
subplot(1,5,1:3);
boxplot(1000*resultPlot_velocity,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('velocity (nm/s)')
xlim([0 100])
ylim([0 nFilePlot+1])

axLegend=subplot(1,5,4:5);
pLegend=plot(zeros(nFilePlot,1),[1:nFilePlot],'ks');
ylim([0 nFilePlot+1])
xlim([0 10])
for iFile=1:nFile
    text(0.5,iFile,filename_label{iFile},'FontSize',6,'interpreter','none');
end%for iFile
if (nFile>1)
    text(0.5,nFile+1,strcat([num2str(nFile+1),'-all files together']),'FontSize',6,'interpreter','none');
end%if
axLegend.Box='off';
axLegend.XTick=[];
axLegend.YTick=[];
axLegend.Color='none';
axLegend.XAxis.Color='none';
axLegend.YAxis.Color='none';
% ********************
% ********************

end%function