function [r_disp]=eval_r_disp(data,dtCDF)

nT=size(data,1);
r_disp=NaN(nT-dtCDF,1);
for iT=(1+dtCDF):nT
    r_disp(iT-dtCDF)=sqrt(sum((data(iT,:)-data(iT-dtCDF,:)).^2));
end%for
%r_disp=[sqrt(sum(diff(data).^2,2))];

end