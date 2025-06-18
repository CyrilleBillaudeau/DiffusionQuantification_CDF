function [paramFit,fit_cdf_rdisp,err_res_paramFit]= fit_CDF(x, cdf_rdisp, dtCDF,lagTime,fitModel,pin,p_uper,showPlot)

if (nargin<8)
    showPlot=0;
end

res_paramFit=NaN(size(pin));
% add err_res_paramFit
err_res_paramFit=NaN(3,size(pin,2));
%% Fitting the CDF

switch (fitModel)
    case 1        
        % model: diffusion single population
        pin_D_1sp=median(pin(2:3));
        p_uper_D_1sp=max(p_uper(2:3));
        fo_D_1sp = fitoptions('Method','NonlinearLeastSquares',...
            'Lower',[0],...
            'Upper',p_uper_D_1sp,...
            'StartPoint',pin_D_1sp,...
            'DiffMinChange',0.0001,'MaxFunEvals',100,'MaxIter',1000);
        ft = fittype('1-exp(-x.^2/(4*a))','options',fo_D_1sp);
        
    case 2
        % model: diffusion double population
        pin_D_2sp=pin(1:3);
        p_uper_D_2sp=p_uper(1:3);
        fo_D_2sp = fitoptions('Method','NonlinearLeastSquares',...
            'Lower',[0,0,0],...
            'Upper',p_uper_D_2sp,...
            'StartPoint',pin_D_2sp,...
            'DiffMinChange',0.0001,'MaxFunEvals',100,'MaxIter',1000);
        ft = fittype('1-a*exp(-x.^2/(4*b))-(1-a)*exp(-x.^2/(4*c))','options',fo_D_2sp);
        
end%swictch

[fitObj,gof] = fit(x, cdf_rdisp, ft);%, 'Weights', wtfit);
paramFit=coeffvalues(fitObj);


switch (fitModel)
    case 1
        D1_res=paramFit(1)/(dtCDF*lagTime);
        fit_cdf_rdisp=1-exp(-x.^2/(4*D1_res*dtCDF*lagTime));
        disp(strcat(['Res Fit CDF Diff 1 sp: D1=',num2str(D1_res,3)]));      
        res_paramFit(2)=D1_res;
        
        % Evaluation of fitting errors
        % ----- std error on fit (from src:
        % https://fr.mathworks.com/matlabcentral/answers/153547-how-can-i-compute-the-standard-error-for-coefficients-returned-from-curve-fitting-functions-in-the-c)
        alpha = 0.95;
        df= gof.dfe;
        ci = confint(fitObj, alpha);
        t = tinv((1+alpha)/2, df);
        se = (ci(2,:)-ci(1,:)) ./ (2*t);
        err_res_paramFit(1,2)=se;
        
        % ----- confidence interval with alpha level
        err_res_paramFit(2:3,2)=confint(fitObj,alpha);

    case 2
        w_res=paramFit(1);
        D1_res=paramFit(2)/(dtCDF*lagTime);
        D2_res=paramFit(3)/(dtCDF*lagTime);
        fit_cdf_rdisp=1-w_res*exp(-x.^2/(4*D1_res*dtCDF*lagTime))-(1-w_res)*exp(-x.^2/(4*D2_res*dtCDF*lagTime));
        disp(strcat(['Res Fit CDF Diff 2 sp: w=',num2str(w_res,3),', D1=',num2str(D1_res,3),', D2=',num2str(D2_res,3)]));
        res_paramFit(1:3)=[w_res,D1_res,D2_res];
        
        
        % Evaluation of fitting errors
        % ----- std error on fit (from src:
        % https://fr.mathworks.com/matlabcentral/answers/153547-how-can-i-compute-the-standard-error-for-coefficients-returned-from-curve-fitting-functions-in-the-c)
        disp ('/!\ error quantification is missing');       
        
end%switch


if (showPlot)
    
    kColor=[0 0 0]/255;
    bColor=[0 130 254]/255;
    oColor=[255 128 1]/255;
    gColor=[47 172 102]/255;
    mColor=[255 0 255]/255;
    
    figure(700);
    if (showPlot==1);clf;end%if
    subplot(4,1,[1:3]);semilogx(x,cdf_rdisp,'k');
    switch (fitModel)
        case 1
            figure(700);subplot(4,1,[1:3]);hold on;p=plot(x,fit_cdf_rdisp,'k-');
            p.Color=oColor;
            figure(700);subplot(4,1,4);hold on;p=semilogx(x,fit_cdf_rdisp-cdf_rdisp,'k');ylim([-0.2 0.2]);xlabel('r disp (µm)');ax=gca;ax.XScale='log';
            p.Color=oColor;
            
        case 2
            figure(700);subplot(4,1,[1:3]);hold on;p=plot(x,fit_cdf_rdisp,'k-');
            p.Color=bColor;
            figure(700);subplot(4,1,4);hold on;p=semilogx(x,fit_cdf_rdisp-cdf_rdisp,'k');ylim([-0.2 0.2]);xlabel('r disp (µm)');ax=gca;ax.XScale='log';
            p.Color=bColor;
    end%switch
    
end%if

end%function