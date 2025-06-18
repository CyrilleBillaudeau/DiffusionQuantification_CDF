function [resultPlot_densityAll,resultPlot_densityDyn,nTrajAnalyzed_PerFile]=combine_getDensity_DynBehavior_CellAvg(data_in,data_File,nFile,cellArea_perFile,paramMSDanalysis_File,filename_label)

resultPlot_densityAll=NaN(5,nFile); %[mean,std, 1st quartile, median, 3rd quatile]
resultPlot_densityDyn=NaN(8,nFile);

if (nFile==1)
    nTrajAnalyzed_PerFile=NaN(nFile,1);
    nFilePlot=nFile;
else
    nTrajAnalyzed_PerFile=NaN(nFile+1,1);
    nFilePlot=nFile+1;
end

for iFile=1:nFile
    
    curData=data_in(data_File==iFile,:);    
    resultPlot_densityAll(:,iFile)=[...
        nanmean(curData(:,1)),nanstd(curData(:,1)),...
        quantile(curData(:,1),[0.25,0.5,0.75])];
    
    resultPlot_densityDyn(:,iFile)=[...
        nanmean(curData(:,3)),...
        nanmean(curData(:,4)),...
        nanmean(curData(:,5)),...
        nanmean(curData(:,6)),...
        nanstd(curData(:,3)),...
        nanstd(curData(:,4)),...
        nanstd(curData(:,5)),...
        nanstd(curData(:,6))];
    nTrajAnalyzed_PerFile(iFile)=nansum(curData(:,2));
end

if (nFile>1)
    nTrajAnalyzed_PerFile(nFile+1)=sum(nTrajAnalyzed_PerFile(1:nFile));
    
    zAll=[...
        nanmean(data_in(:,1)),nanstd(data_in(:,1)),...
        quantile(data_in(:,1),[0.25,0.5,0.75])];zAll=zAll';
    
    resultPlot_densityAll=[resultPlot_densityAll,zAll];
    
    resultPlot_densityDyn_All=[...
        nanmean(data_in(:,3)),...
        nanmean(data_in(:,4)),...
        nanmean(data_in(:,5)),...
        nanmean(data_in(:,6)),...
        nanstd(data_in(:,3)),...
        nanstd(data_in(:,4)),...
        nanstd(data_in(:,5)),...
        nanstd(data_in(:,6))];
    
end%if

if (nFile>1);resultPlot_densityDyn=[resultPlot_densityDyn,resultPlot_densityDyn_All'];end

figure(220);clf;hold on
maxCell=0;
for iFile=1:nFile
    id_cell_file=1:sum(data_File==iFile);
    maxCell=max([maxCell,sum(data_File==iFile)]);
    patchDensityFile_cell=data_in(data_File==iFile,1);    
    subplot(2,2,1:2);hold on;plot(id_cell_file,patchDensityFile_cell,'o')
    ylim([0 10])
    xlabel('cell ID');
    ylabel('patch density (1/µm2)');
end%for

if (nFile==1)
    subplot(2,2,1:2);
    legend(filename_label,'location','northwest','Interpreter','None')
else    
    plot([1,nFilePlot],resultPlot_densityAll(1,nFilePlot)*[1 1],'k.');%%plot([1,maxCell],resultPlot_densityAll(nFilePlot,1)*[1 1],'k.')
    filename_label_all=filename_label;
    filename_label_all{nFile+1}=strcat([num2str(nFile+1),'-all files together']);
    subplot(2,2,1:2);
    legend(filename_label_all,'location','northwest','Interpreter','None')
end

subplot(2,2,3);hold on;
bar(resultPlot_densityAll(1,:),'k')
errorbar(resultPlot_densityAll(1,:),resultPlot_densityAll(2,:),'k.')
plot([1:nFilePlot],resultPlot_densityAll(4,:),'ro')
plot([1:nFilePlot],resultPlot_densityAll(3,:),'m--')
plot([1:nFilePlot],resultPlot_densityAll(5,:),'m--')
xlim([0 nFilePlot+1])
ylim([0 4])
ylabel('patch density (1/µm2)');


%% Trajectory dynamics distribtion
kColor=[0 0 0]/255;
bColor=[0 130 254]/255;
oColor=[255 128 1]/255;
gColor=[47 172 102]/255;
mColor=[255 0 255]/255;

subplot(2,2,4);
%y=results_final_patchDensity(:,3:6);
y=100*resultPlot_densityDyn(1:4,:);y=y';
plotOrder=[1,2,4,3];
y=y(:,plotOrder);
% compil_label_Bar=compil_label;
if (nFile==1)
    y(2,:)=NaN;
    compil_label_Bar{2}=' ';
end
hbar=bar(y,'stacked');
%set(gca,'xticklabel',compil_label_Bar)

hbar(1).FaceColor=bColor;
hbar(2).FaceColor=oColor;
hbar(4).FaceColor=gColor;
hbar(3).FaceColor=205*[1 1 1]/255;
hbar(1).EdgeColor='none';
hbar(2).EdgeColor='none';
hbar(3).EdgeColor='none';
hbar(4).EdgeColor='none';

hold on;
yerr=100*resultPlot_densityDyn(5:8,:);yerr=yerr';
yerr=yerr(:,plotOrder);

for i=1:(nFilePlot)
    for j=1:4
        errorbar(i,sum(y(i,1:j)),yerr(i,j),'k')
    end
    t=text(i,120,num2str(nTrajAnalyzed_PerFile(i)));
    t.Rotation=45;    
end%for
xlim([0 nFilePlot+1])
ylim([0 120])
legend({'dir.','diff.','uncl.','constr.'},'Location','eastoutside');

end%function
