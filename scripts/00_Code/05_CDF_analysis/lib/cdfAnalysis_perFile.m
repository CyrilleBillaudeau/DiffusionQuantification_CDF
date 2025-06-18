function result_Fit_Full_perFile=cdfAnalysis_perFile(tab_r_disp,dtCDF,allParamAcq, pin, p_uper)

lagTime=mean(allParamAcq(:,3))
lstFile=unique(tab_r_disp(:,1));lstFile(isnan(lstFile))=[];
result_Fit_Full_perFile=[];
nFile=numel(lstFile);

for iFile=1:nFile
    [cdf_rdisp,x]=ecdf(tab_r_disp(tab_r_disp(:,1)==lstFile(iFile),end));
    showPlot=1;
    fitModel=1;[paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot);
    cur_Fit(1:2)=[700+iFile,paramFit/(dtCDF*lagTime)];
    showPlot=2;
    fitModel=2;[paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot);
    figure(700);subplot(4,1,[1:3]);ylabel('CDF (all traj)');subplot(4,1,4);ylabel('Fit error');legend({'fit 1-comp', 'fit 2-comp'}, 'Location','best')
    cur_Fit(3:5)=paramFit;
    cur_Fit(4:5)=cur_Fit(4:5)/(dtCDF*lagTime);
    cur_Fit(6:8)=[size(x,1),-1,iFile];
    result_Fit_Full_perFile=[result_Fit_Full_perFile;cur_Fit];

    % Duplicate fig with a specific ID that can be used for saving:
    f2 = figure(700+iFile);clf;
    figure(700);
    subplot(4,1,[1:3]);a1 = gca;
    a2 = copyobj(a1,f2);
    subplot(4,1,4);a1 = gca;
    a2 = copyobj(a1,f2);
    figure(700+iFile);
end
z_result=result_Fit_Full_perFile;
doSwap=z_result(:,4)<z_result(:,5);
z_result(doSwap,[5,4])=z_result(doSwap,[4,5]);
z_result(doSwap,3)=1-z_result(doSwap,3);
result_Fit_Full_perFile=z_result;



end%function