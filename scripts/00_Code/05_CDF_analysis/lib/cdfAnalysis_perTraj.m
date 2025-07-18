function result_Fit_perTraj=cdfAnalysis_perTraj(tab_r_disp,dtCDF,allParamAcq, pin, p_uper)

lagTime=mean(allParamAcq(:,3));
result_Fit_perTraj=[];

nFolder=max(tab_r_disp(:,1));
for iFolder=1:nFolder
    nCell=max(tab_r_disp(tab_r_disp(:,1)==iFolder,2));    
    for iCell=1:nCell
        tab_r_disp_folder_cell=tab_r_disp((tab_r_disp(:,1)==iFolder)&(tab_r_disp(:,2)==iCell),:);
        if ~isempty(tab_r_disp_folder_cell)
            lst_Traj=unique(tab_r_disp_folder_cell(:,3));
            nTraj=numel(lst_Traj);
            for iTraj=1:nTraj
                trajID=lst_Traj(iTraj);
                % disp([iFolder,iCell,trajID])
                % tab_r_disp_folder_cell(tab_r_disp_folder_cell(:,3)==trajID,:)

                [cdf_rdisp,x]=ecdf(tab_r_disp_folder_cell(tab_r_disp_folder_cell(:,3)==trajID,end));

                showPlot=1;
                fitModel=1;[paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot);
                cur_Fit(1:2)=[-1,paramFit/(dtCDF*lagTime)];
                showPlot=2;
                fitModel=2;[paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot);
                figure(700);subplot(4,1,[1:3]);ylabel('CDF (all traj)');subplot(4,1,4);ylabel('Fit error');legend({'fit 1-comp', 'fit 2-comp'}, 'Location','best')
                cur_Fit(3:5)=paramFit;
                cur_Fit(4:5)=cur_Fit(4:5)/(dtCDF*lagTime);
                cur_Fit(6:8)=[size(x,1),-1,-1];

                result_Fit_perTraj=[result_Fit_perTraj;cur_Fit,[iFolder,iCell,trajID]];
                % if (size(x,1)>20); pause();end%if

            end%for
        end%if
    end
end



z_result=result_Fit_perTraj;
doSwap=z_result(:,4)<z_result(:,5);
z_result(doSwap,[5,4])=z_result(doSwap,[4,5]);
z_result(doSwap,3)=1-z_result(doSwap,3);
result_Fit_perTraj=z_result;
end%function