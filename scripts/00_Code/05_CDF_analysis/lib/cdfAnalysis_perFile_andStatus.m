function [result_Fit_Full_perFile_DynDir, result_Fit_Full_perFile_DynDiff, result_Fit_Full_perFile_DynConst, result_Fit_Full_perFile_DynUncl]=cdfAnalysis_perFile_andStatus(allData,dtCDF,allParamAcq, pin, p_uper)

lagTime=mean(allParamAcq(:,3))

lstFile=unique(allData(:,1));lstFile(isnan(lstFile))=[];

nFile=numel(lstFile);

tab_r_disp_DynDir=eval_r_disp_allFolder(allData(allData(:,8)==1,:),dtCDF);
tab_r_disp_DynDiff=eval_r_disp_allFolder(allData(allData(:,8)==2,:),dtCDF);
tab_r_disp_DynConst=eval_r_disp_allFolder(allData(allData(:,8)==3,:),dtCDF);
tab_r_disp_DynUncl=eval_r_disp_allFolder(allData(allData(:,8)==0,:),dtCDF);

max_rdisp=max([tab_r_disp_DynDiff(:,4);tab_r_disp_DynConst(:,4)]);
%min_rdisp=min([tab_r_disp_DynDiff(:,4);tab_r_disp_DynConst(:,4)]);
if (max_rdisp<1)
    max_rdisp=0.1*round(0.5+10*max_rdisp);
else
    max_rdisp=round(0.5+max_rdisp);
end
xBin=linspace(0,max_rdisp);

figure(333);clf;hold on
%histogram(tab_r_disp_DynDir(:,4),'Normalization','probability')
histogram(tab_r_disp_DynConst(:,4),xBin,'Normalization','probability')
histogram(tab_r_disp_DynDiff(:,4),xBin,'Normalization','probability')
%histogram(tab_r_disp_DynUncl(:,4),'Normalization','probability')
legend({'Const','Diff'})

for classDyn_ID=1:4
    result_Fit_Full_perFile=[];
    switch classDyn_ID
        case 1
            tab_r_disp=tab_r_disp_DynDir;
            ID_dynClass=1;
            disp("------------------ Directed tracks")
        case 2
            tab_r_disp=tab_r_disp_DynDiff;
            ID_dynClass=2;
            disp("------------------ Diffused tracks")
        case 3
            tab_r_disp=tab_r_disp_DynConst;
            ID_dynClass=3;
            disp("------------------ Constrained tracks")
        case 4
            tab_r_disp=tab_r_disp_DynUncl;
            ID_dynClass=0;
            disp("------------------ Unclassified tracks")
    end%switch

    for iFile=1:nFile
        
        if (sum(tab_r_disp(:,1)==lstFile(iFile))>0)
            [cdf_rdisp,x]=ecdf(tab_r_disp(tab_r_disp(:,1)==lstFile(iFile),end));
            showPlot=1;
            fitModel=1;[paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot);
            cur_Fit(1:2)=[ID_dynClass,paramFit/(dtCDF*lagTime)];
            showPlot=2;
            fitModel=2;[paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot);
            figure(700);subplot(4,1,[1:3]);ylabel('CDF (all traj)');subplot(4,1,4);ylabel('Fit error');legend({'fit 1-comp', 'fit 2-comp'}, 'Location','best')
            cur_Fit(3:5)=paramFit;
            cur_Fit(4:5)=cur_Fit(4:5)/(dtCDF*lagTime);
            cur_Fit(6:8)=[size(x,1),-1,iFile];
            result_Fit_Full_perFile=[result_Fit_Full_perFile;cur_Fit];

            % % Duplicate fig with a specific ID that can be used for saving:
            % switch ID_dynClass
            %     case 1
            %         figID_root=100;
            %     case 2
            %         figID_root=200;
            % 
            %     case 3
            %         figID_root=300;
            % 
            %     case 0
            %         figID_root=400;
            % end
            % f2 = figure(figID_root+iFile);clf;
            % figure(700);
            % subplot(4,1,[1:3]);a1 = gca;
            % a2 = copyobj(a1,f2);
            % subplot(4,1,4);a1 = gca;
            % a2 = copyobj(a1,f2);
            % figure(figID_root+iFile);
        
        end%if
    end
    z_result=result_Fit_Full_perFile;
    doSwap=z_result(:,4)<z_result(:,5);
    z_result(doSwap,[5,4])=z_result(doSwap,[4,5]);
    z_result(doSwap,3)=1-z_result(doSwap,3);
    result_Fit_Full_perFile=z_result;

    switch classDyn_ID
        case 1
            result_Fit_Full_perFile_DynDir=result_Fit_Full_perFile;
        case 2
            result_Fit_Full_perFile_DynDiff=result_Fit_Full_perFile;
        case 3
            result_Fit_Full_perFile_DynConst=result_Fit_Full_perFile;
        case 4
            result_Fit_Full_perFile_DynUncl=result_Fit_Full_perFile;
    end%switch

end%for

end%function