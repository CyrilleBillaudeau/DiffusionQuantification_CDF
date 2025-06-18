function result_Fit_perTraj_Status=cdfAnalysis_perTraj_andStatus(allData,dtCDF,allParamAcq, pin, p_uper,statusID)

lagTime=mean(allParamAcq(:,3));
result_Fit_perTraj_Status=[];

lstFile=unique(allData(:,1));lstFile(isnan(lstFile))=[];
nFile=numel(lstFile);

for iFile=1:nFile
    curFile=allData(:,1)==lstFile(iFile);    
    lstCell=unique(allData(curFile,2));
    nCell=numel(lstCell);
    for iCell=1:nCell
        curCell=allData(:,2)==lstCell(iCell);        
        allData_curFileCell=allData(curFile&curCell,:);

        lstTraj=unique(allData_curFileCell(:,3));
        nTraj=numel(lstTraj);
        for iTraj=1:nTraj
            allData_curFileCellTraj=allData_curFileCell(allData_curFileCell(:,3)==lstTraj(iTraj),:);
            trajStatus=unique(allData_curFileCellTraj(:,8));
            if (trajStatus==statusID)
                tab_r_disp_traj=eval_r_disp_allFolder(allData_curFileCellTraj,dtCDF);
                [cdf_rdisp,x]=ecdf(tab_r_disp_traj(:,end));

                showPlot=0;%1;
                fitModel=1;[paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot);
                cur_Fit(1:2)=[-1,paramFit/(dtCDF*lagTime)];
                showPlot=0;%2;
                fitModel=2;[paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot);
                if (showPlot>0)
                    figure(700);subplot(4,1,[1:3]);ylabel('CDF (all traj)');subplot(4,1,4);ylabel('Fit error');legend({'fit 1-comp', 'fit 2-comp'}, 'Location','best')
                end
                cur_Fit(3:5)=paramFit;
                cur_Fit(4:5)=cur_Fit(4:5)/(dtCDF*lagTime);
                cur_Fit(6:8)=[size(x,1),-1,statusID];

                result_Fit_perTraj_Status=[result_Fit_perTraj_Status;cur_Fit,[lstFile(iFile),lstCell(iCell),lstTraj(iTraj)]];
            end%if
        end%for iTraj
    end%for iCell
end%for iFile

z_result=result_Fit_perTraj_Status;
doSwap=z_result(:,4)<z_result(:,5);
z_result(doSwap,[5,4])=z_result(doSwap,[4,5]);
z_result(doSwap,3)=1-z_result(doSwap,3);
result_Fit_perTraj_Status=z_result;
end%function