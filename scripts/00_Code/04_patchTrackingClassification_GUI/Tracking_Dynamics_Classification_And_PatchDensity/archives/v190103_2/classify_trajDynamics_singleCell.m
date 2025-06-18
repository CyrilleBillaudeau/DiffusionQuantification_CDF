function [tab_patchDensityDyn,tab_patchDynamic,tabForBS]=classify_trajDynamics_singleCell(lstTraj,traj2Cell,nCell,cellDescription,pixSize,lagTime,paramMSDanalysis,doPlot)
% loop on each cell: msd analysis on each traj + classification
% results estimation
tab_patchDensityDyn=NaN(nCell,5);
tab_patchDynamic=NaN(nCell,10);
tabForBS=[];
%MSD_curv=[];
disp('Classification based on MSD is starting');
for iCell=1:nCell
    if (cellDescription(iCell,7)>0)
        cell_area=cellDescription(iCell,4);
        cell_area=cell_area*(pixSize)^2;
        
        [tr,trajID,totalTraj,trajDuration,nFrame]=getTraj_CurrentCell(lstTraj,traj2Cell,iCell);
        
        %% MSD fitting
        if (doPlot>0);figure(2);clf;end
        %     thldR2diff=0.8;
        %     thldR2dir=0.8;
        %     minTrcLgth=6;
        minTrcLgth=paramMSDanalysis(1);
        thldR2dir=paramMSDanalysis(2);
        thldR2diff=paramMSDanalysis(3);
        
        [tabStatus,tabSpeed,tabD,durTrack,curvMSD]=MSDanalysis(tr,totalTraj,minTrcLgth,thldR2diff,thldR2dir,pixSize,lagTime,doPlot);
        
        % for bootstrap analysis
        startTrack=NaN(totalTraj,1);
        for iTraj=1:totalTraj
            startTrack(iTraj,1)=min(tr(tr(:,4)==iTraj,3));
        end
        tabForBS=[tabForBS;iCell*ones(size(tabStatus)),trajID,tabStatus,tabSpeed,tabD,durTrack,startTrack,cell_area*ones(totalTraj,1)];
        
        nTrack=totalTraj;%nTraj;
        %MSD_curv=[MSD_curv,[tabStatus(tabStatus>0)';curvMSD(:,tabStatus>0)]];
        summaryPatch=NaN(nFrame,5);
        for iFrame=1:nFrame
            IDtraj=tr(tr(:,3)==iFrame,4);
            instStatus=tabStatus(IDtraj);
            summaryPatch(iFrame,1)=sum(instStatus==1);
            summaryPatch(iFrame,2)=sum(instStatus==2);
            summaryPatch(iFrame,3)=sum(instStatus==3);
            summaryPatch(iFrame,4)=sum(instStatus==0);
            summaryPatch(iFrame,5)=sum(instStatus==-1);
        end
        tab_patchDensityDyn(iCell,:)=mean(summaryPatch)/cell_area;%std(summaryPatch)/cell_area;
        
        if (doPlot>0)
            % plot: track duration histogram
            if (~isempty(tabStatus))
                figure(2);subplot(3,3,2);
                lgthTrc=zeros(nTrack,1);
                for iTrc=1:nTrack;lgthTrc(iTrc)=sum(tr(:,4)==iTrc);end%for
                hist(lgthTrc,[1:max(lgthTrc)])
                [n,xout]=hist(lgthTrc,[1:max(lgthTrc)]);
                xlim([0 max(lgthTrc)]);ylim([0 1+max(n)]);
            end%if
            
            subplot(3,3,4);ylim([0 0.5]);xlim([0 30])
            subplot(3,3,5);ylim([0 0.5]);xlim([0 30])
            subplot(3,3,7);ylim([0 0.5]);xlim([0 30])
            subplot(3,3,8);ylim([0 0.5]);xlim([0 30])
        end%if doPlot
        
        % measure averages of speed and diffusion coeffcient on the cell
        patch_speed=nanmean(tabSpeed(find(tabStatus==1)));
        patch_speed_std=nanstd(tabSpeed(find(tabStatus==1)));
        patch_speed_diffused=nanmean(tabSpeed(find(tabStatus==2&tabSpeed>0))); % obsolete?
        patch_speed_diffused_std=nanstd(tabSpeed(find(tabStatus==2&tabSpeed>0))); % obsolete?
        patch_diffusion=nanmean(tabD(find(tabStatus==2)));
        patch_diffusion_std=nanstd(tabD(find(tabStatus==2)));
        
        % measure trajectory distribution among 4 classes
        percentage_directed=length(find(tabStatus==1))/sum(tabStatus>=0);
        percentage_diffusing=length(find(tabStatus==2))/sum(tabStatus>=0);
        percentage_static=length(find(tabStatus==3))/sum(tabStatus>=0);
        percentage_unclassified=length(find(tabStatus==0))/sum(tabStatus>=0);
        
        if (doPlot>0)
            figure(2);
            subplot(3,3,3)
            if ~isnan(sum([percentage_directed,percentage_diffusing,percentage_static,percentage_unclassified]))
                b=bar([1,2,3,4],100*[percentage_directed,percentage_diffusing,percentage_static,percentage_unclassified],'k');
                ylabel('Frequency (%)');title(strcat(['#ok: ',num2str(sum(tabStatus>=0))]))
                xlim([0 5]);ylim([0 ceil(max(b.YData)/10)*10])
            end%if
            
            subplot(3,3,6)
            if (sum(tabStatus==1)>0)
                boxplot(1000*tabSpeed(tabStatus==1));
                hold on; plot(1,1000*patch_speed,'ko','MarkerFaceColor','k');
                ylabel('speed (nm/s)')
            end
            subplot(3,3,9)
            if(sum(tabD>0)>0)
                boxplot(tabD(tabD>0));
                hold on; plot(1,patch_diffusion,'ko','MarkerFaceColor','k');
                ylabel('Diff. coeff (µm2/s)')
            end
        end%if doPlot
        tab_patchDynamic(iCell,:)=[iCell,1000*patch_speed,1000*patch_speed_std,patch_diffusion,patch_diffusion_std,percentage_directed,percentage_diffusing,percentage_static,percentage_unclassified,sum(tabStatus>=0)];
        axis equal
    end
end
disp('Classification based on MSD done!')
end%function