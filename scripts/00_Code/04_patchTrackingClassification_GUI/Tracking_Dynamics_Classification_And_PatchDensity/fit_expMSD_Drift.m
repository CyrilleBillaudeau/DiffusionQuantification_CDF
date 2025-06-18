function [resParam]=fit_expMSD_Drift(x,y,yerr)
%yerr=msd(:,2)
doPlotFit=0;
% 250509 - MODIFICATION CB:
% A warning message were displayes due to the output about r-square &
% F-stat that was not used in this scripts. I fixed it by removeing them
% original lines:
%[b1,bint,r,rint,stats1] = regress(y,x); %% b1 means linear
%[b2,bint,r,rint,stats2] = regress(y,x.^2); %% b2 means second order
% new lines: 
b1 = regress(y,x); %% b1 means linear
b2 = regress(y,x.^2); %% b2 means second order

DtrackZY=b1/4;
speedTrackZY=sqrt(b2);

%% Fitting the MSD with a drift model with noise
%pinLin=[sqrt(speedTrackZY),DtrackZY];
pinLin=[speedTrackZY,DtrackZY, nanmedian(y)];
fo = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0,0,0],...
    'Upper',[0.5 0.5 0.5],...
    'StartPoint',pinLin,...
    'DiffMinChange',0.01,'MaxFunEvals',10,'MaxIter',10);
%if (DtrackZY>fo.Upper); fo.Upper=DtrackZY*1.5;end
ft = fittype('a^2*x^2+4*b*x+c','options',fo);


%yerr=msd_fit(:,2);
std_y=yerr;
wt=1./std_y;

xfit=x(yerr>0);
yfit=y(yerr>0);
wtfit=wt(yerr>0);
%wtfit=ones(size(xfit));

resParam=-ones(3,3);

if (numel(xfit)>2)
    [fitObj,gof] = fit(xfit, yfit, ft, 'Weights', wtfit);
    DriftCoef=coeffvalues(fitObj);
    
    % Results of fitting
    %resParam=-ones(3,3);
    
    resParam(1,:)=[DriftCoef(1:2),numel(y)];
    % Evaluation of fitting errors
    
    %resParam(2:3,1:2)=confint(fitObj,0.95);
    resParam(2,3)=gof.rsquare;
    resParam(3,3)=gof.rmse;
    
    if (doPlotFit>0)
        figure(751);clf;
        plot(x,y,'k'); hold on
        speedTrack=DriftCoef(1);
        Dtrack=DriftCoef(2);
        plot(x,(speedTrack*x).^2+4*Dtrack*x,'r'); hold on
        ylim([0 0.4]);
        %pause();
    end%if
    %[stats1(1),stats2(1)]
    %[resParam1(1,2),resParam2(1,2)]
    
end%if
end%function