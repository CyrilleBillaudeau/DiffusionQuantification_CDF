function [resultPlot_densityAll,resultPlot_densityDyn,nTrajAnalyzed_PerFile]=combine_getDensity_DynBehavior_noCellAvg(data_in,data_File,nFile,cellArea_perFile,paramMSDanalysis_File,filename_label)

resultPlot_densityAll=NaN(5,nFile); %[mean,std, 1st quartile, median, 3rd quatile]
resultPlot_densityDyn=NaN(8,nFile);
result_patchDensityAll=[];
instantaneousPatchDynamics_all=[];

if (nFile==1)
    nTrajAnalyzed_PerFile=NaN(nFile,1);
    nFilePlot=nFile;
else
    nTrajAnalyzed_PerFile=NaN(nFile+1,1);
    nFilePlot=nFile+1;
end

for iFile=1:nFile
    
    curData=data_in(data_File==iFile,:);
    
    % getPatchDensity (count all detection at any time and average it)
    nFrameMax=max(curData(:,7)+curData(:,6)+1);% frameTrajStart+frameTrajDuration+1 (frame starting at 0 in result)
    
    nTrajTotal=size(curData,1);
    instantaneousDetectedPatch=zeros(nTrajTotal,nFrameMax);
    for iTraj=1:nTrajTotal
        trajIsVisible=1+(curData(iTraj,7):(curData(iTraj,7)+curData(iTraj,6)));
        instantaneousDetectedPatch(iTraj,trajIsVisible)=instantaneousDetectedPatch(iTraj,trajIsVisible)+1;
    end
    total_cellArea_curFile=nansum(cellArea_perFile(:,iFile));
    patchDensityFile_time=sum(instantaneousDetectedPatch)/total_cellArea_curFile;
    timePlot=(1:nFrameMax)*paramMSDanalysis_File(iFile,2);
    
    result_patchDensityAll=[result_patchDensityAll;iFile*ones(nFrameMax,1),timePlot',patchDensityFile_time'];
    resultPlot_densityAll(:,iFile)=[...
        nanmean(patchDensityFile_time),nanstd(patchDensityFile_time),...
        quantile(patchDensityFile_time,[0.25,0.5,0.75])];
    
    % get dynBehavior (count all classified dyn behavior at any time and
    % averaged it
    instantaneousPatchDynamics=NaN(nTrajTotal,nFrameMax);
    for iTraj=1:nTrajTotal
        trajIsVisible=1+(curData(iTraj,7):(curData(iTraj,7)+curData(iTraj,6)));
        instantaneousPatchDynamics(iTraj,trajIsVisible)=curData(iTraj,3);
    end
    if (size(instantaneousPatchDynamics_all,2)>size(instantaneousPatchDynamics,2))
        instantaneousPatchDynamics=[instantaneousPatchDynamics,NaN(nTrajTotal,size(instantaneousPatchDynamics_all,2)-nFrameMax)];
    end
    if (size(instantaneousPatchDynamics_all,2)<size(instantaneousPatchDynamics,2))
        instantaneousPatchDynamics_all=[instantaneousPatchDynamics_all,NaN(size(instantaneousPatchDynamics_all,1),nFrameMax-size(instantaneousPatchDynamics_all,2))];
    end    
    instantaneousPatchDynamics_all=[instantaneousPatchDynamics_all;instantaneousPatchDynamics];
    
    instantaneousTrajAnalyzed=sum(instantaneousPatchDynamics>-1);
    instantaneousTrajDir_pct=sum(instantaneousPatchDynamics==1)./instantaneousTrajAnalyzed;
    instantaneousTrajDiff_pct=sum(instantaneousPatchDynamics==2)./instantaneousTrajAnalyzed;
    instantaneousTrajConst_pct=sum(instantaneousPatchDynamics==3)./instantaneousTrajAnalyzed;
    instantaneousTrajUncl_pct=sum(instantaneousPatchDynamics==0)./instantaneousTrajAnalyzed;
    
    resultPlot_densityDyn(:,iFile)=[...
        nanmean(instantaneousTrajDir_pct),...
        nanmean(instantaneousTrajDiff_pct),...
        nanmean(instantaneousTrajConst_pct),...
        nanmean(instantaneousTrajUncl_pct),...
        nanstd(instantaneousTrajDir_pct),...
        nanstd(instantaneousTrajDiff_pct),...
        nanstd(instantaneousTrajConst_pct),...
        nanstd(instantaneousTrajUncl_pct)];
    nTrajAnalyzed_PerFile(iFile)=sum(nanmedian(instantaneousPatchDynamics,2)>-1);
end
if (nFile>1)
nTrajAnalyzed_PerFile(nFile+1)=sum(nTrajAnalyzed_PerFile(1:nFile));

zAll=[...
nanmean(result_patchDensityAll(:,3)),nanstd(result_patchDensityAll(:,3)),...
quantile(result_patchDensityAll(:,3),[0.25,0.5,0.75])];zAll=zAll';
resultPlot_densityAll=[resultPlot_densityAll,zAll];

instantaneousTrajAnalyzed_all=sum(instantaneousPatchDynamics_all>-1);
instantaneousTrajDir_pct_all=sum(instantaneousPatchDynamics_all==1)./instantaneousTrajAnalyzed_all;
instantaneousTrajDiff_pct_all=sum(instantaneousPatchDynamics_all==2)./instantaneousTrajAnalyzed_all;
instantaneousTrajConst_pct_all=sum(instantaneousPatchDynamics_all==3)./instantaneousTrajAnalyzed_all;
instantaneousTrajUncl_pct_all=sum(instantaneousPatchDynamics_all==0)./instantaneousTrajAnalyzed_all;

resultPlot_densityDyn_All=[...
    mean(instantaneousTrajDir_pct_all),...
    mean(instantaneousTrajDiff_pct_all),...
    mean(instantaneousTrajConst_pct_all),...
    mean(instantaneousTrajUncl_pct_all),...
    std(instantaneousTrajDir_pct_all),...
    std(instantaneousTrajDiff_pct_all),...
    std(instantaneousTrajConst_pct_all),...
    std(instantaneousTrajUncl_pct_all)];
end%if

if (nFile>1);resultPlot_densityDyn=[resultPlot_densityDyn,resultPlot_densityDyn_All'];end

figure(220);clf;hold on
for iFile=1:nFile
    timePlot=result_patchDensityAll(result_patchDensityAll(:,1)==iFile,2);
    patchDensityFile_time=result_patchDensityAll(result_patchDensityAll(:,1)==iFile,3);
    subplot(2,2,1:2);hold on;plot(timePlot,patchDensityFile_time)
    ylim([0 10])
    xlabel('time (sec)');
    ylabel('patch density (1/µm2)');
end%for

if (nFile==1)
    subplot(2,2,1:2);
    legend(filename_label,'location','northwest','Interpreter','None')
else
    plot([timePlot(1),timePlot(end)],zAll(1)*[1 1],'k.')
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
