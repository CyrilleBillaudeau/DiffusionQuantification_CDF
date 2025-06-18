function [resParam1,resParam2]=fit_expMSD(x,y,yerr)

doPlotFit=0;
% 250509 - MODIFICATION CB:
% A warning message were displayes due to the output about r-square &
% F-stat that was not used in this scripts. I fixed it by removeing them
% original lines:
% [b1,bint,r,rint,stats1] = regress(y,x); %% b1 means linear
% [b2,bint,r,rint,stats2] = regress(y,x.^2); %% b2 means second order
% new lines: 
b1 = regress(y,x); %% b1 means linear
b2 = regress(y,x.^2); %% b2 means second order

DtrackZY=b1/4;
speedTrackZY=sqrt(b2);

%% Fitting the MSD with a simple linear model
pinLin=DtrackZY;
fo = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',0,...
    'Upper',0.5,...
    'StartPoint',pinLin,...
    'DiffMinChange',0.01,'MaxFunEvals',10,'MaxIter',10);
if (DtrackZY>fo.Upper); fo.Upper=DtrackZY*1.5;end
ft = fittype('4*a*x','options',fo);

    
%yerr=msd_fit(:,2);
std_y=yerr;
wt=1./std_y;

xfit=x(yerr>0);
yfit=y(yerr>0);
wtfit=wt(yerr>0);
%wtfit=ones(size(xfit));

resParam1=-ones(2,3);
if (numel(xfit)>2)
    [fitObj,gof] = fit(xfit, yfit, ft, 'Weights', wtfit);
    Dtrack=coeffvalues(fitObj);
    
    % Results of fitting
    
    resParam1(1,:)=[Dtrack,gof.rsquare,numel(y)];
    % Evaluation of fitting errors
    resParam1(2,1)=gof.rmse;
    if (numel(xfit)>1) % Cannot compute confidence intervals if #observations<=#coefficients.
        resParam1(2,2:3)=confint(fitObj,0.95);
    end
    %resParam1(2,1)=(resParam1(1,1)>resParam1(2,2))&(resParam1(1,1)<resParam1(2,3));
end %if (numel(xfit)>2)

%% Fitting the MSD with a simple quadratic model
pinLin=speedTrackZY^2;
%pinLin=sqrt(speedTrackZY);
fo = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',0,...
    'Upper',0.5,...
    'StartPoint',pinLin,...
    'DiffMinChange',0.01,'MaxFunEvals',10,'MaxIter',10);
if (speedTrackZY>fo.Upper); fo.Upper=speedTrackZY*1.5;end
ft = fittype('a^2*x^2','options',fo);

resParam2=-ones(2,3);
if (numel(xfit)>2)
    [fitObj,gof] = fit(xfit, yfit, ft, 'Weights', wtfit);
    %speedTrack=sqrt(coeffvalues(fitObj));
    speedTrack=(coeffvalues(fitObj));
    
    % Results of fitting
    resParam2(1,:)=[speedTrack,gof.rsquare,numel(y)];
    % Evaluation of fitting errors
    resParam2(2,1)=gof.rmse;
    if (numel(xfit)>1) % Cannot compute confidence intervals if #observations<=#coefficients.
        resParam2(2,2:3)=confint(fitObj,0.95);
    end
    %resParam2(2,1)=(resParam2(1,1)>resParam2(2,2))&(resParam2(1,1)<resParam2(2,3));
end% if (numel(xfit)>2)

if (doPlotFit>0)
    XLIM=2*max(x);
    YLIM=2*max(y);
    if YLIM<0.2;YLIM=0.2;end%if
    figure(750);clf;
    plot(x,y,'k.'); hold on
    if(resParam1(1,2)> resParam2(1,2))
        plot(x,4*Dtrack*x,'m'); hold on
        plot(x,(speedTrack*x).^2,'r-.'); hold on        
    else
        plot(x,4*Dtrack*x,'m-.'); hold on
        plot(x,(speedTrack*x).^2,'r'); hold on
    end    
    %ylim([0 0.4]);
    ylim([0 YLIM]);
    xlim([0 XLIM]);
    legend({"MSD","Fit Diff","Fit Dir"})
    title(strcat(['R2diff: ',num2str(resParam1(1,2)), ' - R2dir: ',num2str(resParam2(1,2))]))
    %pause();
end%if
%[stats1(1),stats2(1)]
%[resParam1(1,2),resParam2(1,2)]

end%function