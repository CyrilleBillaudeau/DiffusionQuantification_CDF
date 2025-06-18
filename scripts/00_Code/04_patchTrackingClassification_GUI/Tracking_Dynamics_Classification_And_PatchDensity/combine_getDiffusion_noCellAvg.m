function [resultPlot_diffusion]=combine_getDiffusion_noCellAvg(data_in,data_File,nFile,filename_label)

result_diffusion=[data_File,data_in(:,5)];
result_diffusion(data_in(:,3)~=2,:)=[];

nDiffusingPerFile=sum(result_diffusion(:,1)==[1:nFile]);
resultPlot_diffusion=NaN(max(nDiffusingPerFile),nFile);

for iFile=1:nFile
    resultPlot_diffusion(1:nDiffusingPerFile(iFile),iFile)=result_diffusion(result_diffusion(:,1)==iFile,2);    
end%for iFile

if (nFile>1)
    resultPlot_diffusion_all=resultPlot_diffusion(:);
    resultPlot_diffusion_all(isnan(resultPlot_diffusion_all))=[];
    resultPlot_diffusion=[[resultPlot_diffusion;NaN(size(resultPlot_diffusion_all,1)-max(nDiffusingPerFile),nFile)],resultPlot_diffusion_all];
    nFilePlot=nFile+1;
else
    nFilePlot=nFile;
end

figure(210);clf;
subplot(1,5,1:3);
boxplot(1000*resultPlot_diffusion,'Color','k','Symbol','k.','Orientation','horizontal');%,'Labels',filename_label);
xlabel('diff. coef (1e-3 µm2/s)')
xlim([0 10])
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