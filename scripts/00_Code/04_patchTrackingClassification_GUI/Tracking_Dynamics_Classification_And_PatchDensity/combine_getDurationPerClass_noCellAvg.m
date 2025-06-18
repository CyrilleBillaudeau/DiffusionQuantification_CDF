function [resultPlot_duration,resultPlot_durationTime,resultPlot_dynBehavior]=combine_getDurationPerClass_noCellAvg(data_in,data_File,nFile,filename_label,paramMSDanalysis_File)

result_duration=[data_File,data_in(:,[3,6])];

nDurationPerFile=sum(result_duration(:,1)==[1:nFile]);
resultPlot_duration=NaN(max(nDurationPerFile),nFile);
resultPlot_durationTime=NaN(max(nDurationPerFile),nFile);
resultPlot_dynBehavior=NaN(max(nDurationPerFile),nFile);

for iFile=1:nFile
    resultPlot_duration(1:nDurationPerFile(iFile),iFile)=result_duration(result_duration(:,1)==iFile,3);
    resultPlot_durationTime(1:nDurationPerFile(iFile),iFile)=result_duration(result_duration(:,1)==iFile,3)*paramMSDanalysis_File(iFile,2);
    resultPlot_dynBehavior(1:nDurationPerFile(iFile),iFile)=result_duration(result_duration(:,1)==iFile,2);
end%for iFile

if (nFile>1)
    resultPlot_duration_all=resultPlot_duration(:);
    resultPlot_duration_all(isnan(resultPlot_duration_all))=[];
    
    resultPlot_durationTime_all=resultPlot_durationTime(:);
    resultPlot_durationTime_all(isnan(resultPlot_durationTime_all))=[];

    resultPlot_dynBehavior_all=resultPlot_dynBehavior(:);
    resultPlot_dynBehavior_all(isnan(resultPlot_dynBehavior_all))=[];
    
    resultPlot_duration=[[resultPlot_duration;NaN(size(resultPlot_duration_all,1)-max(nDurationPerFile),nFile)],resultPlot_duration_all];
    resultPlot_durationTime=[[resultPlot_durationTime;NaN(size(resultPlot_durationTime_all,1)-max(nDurationPerFile),nFile)],resultPlot_durationTime_all];
    resultPlot_dynBehavior=[[resultPlot_dynBehavior;NaN(size(resultPlot_dynBehavior_all,1)-max(nDurationPerFile),nFile)],resultPlot_dynBehavior_all];
    nFilePlot=nFile+1;
else
    nFilePlot=nFile;
end%if

XLIM_FRAME=floor(0.5+max(resultPlot_duration(:))/10)*10;
XLIM_FRAME_TIME=floor(0.5+max(resultPlot_durationTime(:))/10)*10;
if (XLIM_FRAME_TIME==0)
    XLIM_FRAME_TIME=floor(0.5+max(resultPlot_durationTime(:))/1)*1;
end
figure(230);clf;
subplot(2,10,1:3);
curPlot=resultPlot_duration;
curPlot(resultPlot_dynBehavior~=1)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (frame)')
xlim([0 XLIM_FRAME])
ylim([0 nFilePlot+1])
title('Directed');

subplot(2,10,4:6);
curPlot=resultPlot_duration;
curPlot(resultPlot_dynBehavior~=2)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (frame)')
xlim([0 XLIM_FRAME])
ylim([0 nFilePlot+1])
title('Diffusing');

subplot(2,10,11:13);
curPlot=resultPlot_duration;
curPlot(resultPlot_dynBehavior~=3)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (frame)')
xlim([0 XLIM_FRAME])
ylim([0 nFilePlot+1])
title('Constrained');

subplot(2,10,14:16);
curPlot=resultPlot_duration;
curPlot(resultPlot_dynBehavior~=0)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (frame)')
xlim([0 XLIM_FRAME])
ylim([0 nFilePlot+1])
title('Unclassified');

subplot(2,10,17:19);
curPlot=resultPlot_duration;
curPlot(resultPlot_dynBehavior~=-1)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (frame)')
xlim([0 XLIM_FRAME])
ylim([0 nFilePlot+1])
title('Not analyzed');

axLegend=subplot(2,10,7:10);
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

figure(235);clf;
subplot(2,10,1:3);
curPlot=resultPlot_durationTime;
curPlot(resultPlot_dynBehavior~=1)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (sec)')
xlim([0 XLIM_FRAME_TIME])
ylim([0 nFilePlot+1])
title('Directed');

subplot(2,10,4:6);
curPlot=resultPlot_durationTime;
curPlot(resultPlot_dynBehavior~=2)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (sec)')
xlim([0 XLIM_FRAME_TIME])
ylim([0 nFilePlot+1])
title('Diffusing');

subplot(2,10,11:13);
curPlot=resultPlot_durationTime;
curPlot(resultPlot_dynBehavior~=3)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (sec)')
xlim([0 XLIM_FRAME_TIME])
ylim([0 nFilePlot+1])
title('Constrained');

subplot(2,10,14:16);
curPlot=resultPlot_durationTime;
curPlot(resultPlot_dynBehavior~=0)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (sec)')
xlim([0 XLIM_FRAME_TIME])
ylim([0 nFilePlot+1])
title('Unclassified');

subplot(2,10,17:19);
curPlot=resultPlot_durationTime;
curPlot(resultPlot_dynBehavior~=-1)=NaN;
boxplot(curPlot,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('traj duration (sec)')
xlim([0 XLIM_FRAME_TIME])
ylim([0 nFilePlot+1])
title('Not analyzed');



axLegend=subplot(2,10,7:10);
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