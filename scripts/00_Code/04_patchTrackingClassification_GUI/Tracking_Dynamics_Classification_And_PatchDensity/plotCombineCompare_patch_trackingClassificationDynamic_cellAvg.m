function plotCombineCompare_patch_trackingClassificationDynamic_cellAvg()

clear all;
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/IO_tools/');
%addpath('/home/cyrille/INRA/3_Imaging/ImageAnalysis/Matlab/Matlab-scripts/Tracking_Dynamics_Classification_And_PatchDensity');

fileOut_tab_patchDensityDyn='tab_patchDensityDyn.txt';
fileOut_tab_patchDynamic='tab_patchDynamic.txt';
fileOut_cellDescription='cellDescription.txt';
fileOut_tabForBS='tabForBS.txt';
fileOut_paramMSDanalysis='paramMSDanalysis.txt';
fileOut_imgMask='cellMask_withLabelAndSpec.png';

%% Select all data to be grouped together

defineNewLst=1;
nCond=0;
compil_nTrajAnalyzed_PerFile={};
compil_patchDensityDyn=[];
compil_label={};
compil_velocity=[];
compil_diffusion=[];
compil_patchDensity=[];
lstFiles_cond={};
lstTmpSave_cond={};
nFile_perCond=[];

while (defineNewLst>0)
    lstFiles=uipickfiles('Prompt','Select all files corresponding to similar condition (e.g.: WT, Mutant1, ...)','FilterSpec','*.tif');
    nFile=numel(lstFiles);
    
    % ******************** getData
    [data_in,data_File,paramMSDanalysis_File,nTrajMax,filename_label,tab_patchDensityDyn,tab_patchDynamic]=combine_getData_CellAvg(lstFiles);
    
    % ******************** getSpeed
    [resultPlot_velocity]=combine_getSpeed_CellAvg(data_in,data_File,nFile,filename_label);
    
    % ******************** getDiffusion
    [resultPlot_diffusion]=combine_getDiffusion_CellAvg(data_in,data_File,nFile,filename_label);
    
    % ******************** getDensity
    cellArea_perFile=data_in(:,11);
    [resultPlot_densityAll,resultPlot_densityDyn,nTrajAnalyzed_PerFile]=combine_getDensity_DynBehavior_CellAvg(data_in,data_File,nFile,cellArea_perFile,paramMSDanalysis_File,filename_label);
    
    nCond=nCond+1;
    nFile_perCond=[nFile_perCond;nCond,nFile];
    
    if (nFile>1)
        % Save File Variation in a tmp folder that will be moved at the end
        % if saving is required
        lstTmpSave=lstFiles{1};
        lstTmpSave=strcat([lstTmpSave(1:max(strfind(lstTmpSave,filesep))),num2str(nCond),'_tmpSave',filesep]);
        if (exist(lstTmpSave,'dir')~=7)
            mkdir(lstTmpSave)
        end
        cd(lstTmpSave)
        
        print(200,'velocity_fileVariation.svg','-dsvg');
        print(210,'diffusion_fileVariation.svg','-dsvg');
        print(220,'densityAndDynamics_fileVariation.svg','-dsvg');
        %        print(230,'trajDurationFrame_fileVariation.svg','-dsvg');
        %        print(235,'trajDurationSecond_fileVariation.svg','-dsvg');
        
        all_results={};
        all_results.densityAll=resultPlot_densityAll;% array: colums = File; rows = [mean;std;1st quartile;median;3rd quatile];
        all_results.densityDyn=resultPlot_densityDyn;% array: colums = File; rows = [mean (4 classes);std (4 classes)];
        all_results.velocity=resultPlot_velocity;
        all_results.diffusion=resultPlot_diffusion;
        save('all_results.mat','all_results');
        
        cd ..
        lstTmpSave_cond{nCond}=lstTmpSave;
    else
        lstTmpSave_cond{nCond}='none';
    end%if
    
    compil_velocity=[compil_velocity;resultPlot_velocity(:,end),nCond*ones(size(resultPlot_velocity,1),1)];
    compil_diffusion=[compil_diffusion;resultPlot_diffusion(:,end),nCond*ones(size(resultPlot_diffusion,1),1)];
    compil_patchDensity=[compil_patchDensity;resultPlot_densityAll(:,end)',nCond];
    compil_patchDensityDyn=[compil_patchDensityDyn;resultPlot_densityDyn(:,end),nCond*ones(8,1)];
    compil_nTrajAnalyzed_PerFile{nCond}=nTrajAnalyzed_PerFile;
    
    prompt = {'Set condition name: (e.g.: WT, Mutants1, ...)','Define new list? (1:yes -> new selection / 0: no -> stop and generate final plot):'};
    dlg_title = 'Input';
    num_lines = 1;
    defaultans = {num2str(nCond),num2str(defineNewLst)};
    %defaultans = {'3','1'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    compil_label{nCond}=answer{1}
    defineNewLst=str2num(answer{2});
    if (defineNewLst>0)
        curPath=lstFiles{end};
        pathImg=curPath(1:max(strfind(curPath,filesep)));
        cd(pathImg)
    end
    lstFiles_cond{nCond}=lstFiles;
end%while


%% Trajectory dynamics distribtion
kColor=[0 0 0]/255;
bColor=[0 130 254]/255;
oColor=[255 128 1]/255;
gColor=[47 172 102]/255;
mColor=[255 0 255]/255;

results_final_patchDensityDyn=NaN(nCond,8);
for iCond=1:nCond
    results_final_patchDensityDyn(iCond,:)=compil_patchDensityDyn(compil_patchDensityDyn(:,2)==iCond,1);
end%for

figure(100);clf
y=100*results_final_patchDensityDyn(:,1:4);
plotOrder=[1,2,4,3];
y=y(:,plotOrder);
tabOut{1}=y;
compil_label_Bar=compil_label;
if (nCond==1)
    y(2,:)=NaN;
    compil_label_Bar{2}=' ';
end
hbar=bar(y,'stacked');
set(gca,'xticklabel',compil_label_Bar)

hbar(1).FaceColor=bColor;
hbar(2).FaceColor=oColor;
hbar(4).FaceColor=gColor;
hbar(3).FaceColor=205*[1 1 1]/255;
hbar(1).EdgeColor='none';
hbar(2).EdgeColor='none';
hbar(3).EdgeColor='none';
hbar(4).EdgeColor='none';

hold on;
yerr=100*results_final_patchDensityDyn(:,5:8);
yerr=yerr(:,plotOrder);

zOut=tabOut{1};
for i=1:nCond
    for j=1:4
        errorbar(i,sum(y(i,1:j)),yerr(i,j),'k')
    end
    nTrajAnalyzed_Cond=compil_nTrajAnalyzed_PerFile{i};nTrajAnalyzed_Cond=nTrajAnalyzed_Cond(end);
    t=text(i,120,num2str(nTrajAnalyzed_Cond));
    t.Rotation=45;
    zOut(i,5)=nTrajAnalyzed_Cond;
end%for
%xlim([0 3])
ylim([0 120])
legend({'dir.','diff.','uncl.','constr.'},'Location','eastoutside')

pause(0.5)
tabOut{1}=zOut;

%% Patch speed

nDirPerCond=sum(compil_velocity(:,2)==[1:nCond]);
tab_speed=NaN(max(nDirPerCond),nCond);
for iCond=1:nCond; tab_speed(1:nDirPerCond(iCond),iCond)=1000*compil_velocity(compil_velocity(:,2)==iCond,1);end

figure(111);clf;
boxplot(tab_speed,'Color','k','Symbol','k.','Labels',compil_label);
ylabel('speed (nm/s) ')
ylim([0 100])
pause(0.5)
tabOut{2}=tab_speed;

%% Patch diffusion coefficient
nDiffPerCond=sum(compil_diffusion(:,2)==[1:nCond]);
tab_diffCoeff=NaN(max(nDiffPerCond),nCond);
for iCond=1:nCond; tab_diffCoeff(1:nDiffPerCond(iCond),iCond)=compil_diffusion(compil_diffusion(:,2)==iCond,1);end

figure(121);clf;
boxplot(1000*tab_diffCoeff,'Color','k','Symbol','k.','Labels',compil_label);
ylabel('diff. coeff (1e-3 µm2/s) ')
ylim([0 10])
pause(0.5);
tabOut{3}=tab_diffCoeff;

%% Patch density

figure(151);clf;hold on;
%boxplot(tab_pDensity,'Color','k','Symbol','k.','Labels',compil_label);
%b=bar(compil_patchDensity(:,1),'k')
%c = categorical(compil_label);
%bar(c,compil_patchDensity(:,1),'k');
bar(compil_patchDensity(:,1),'k');
errorbar(compil_patchDensity(:,1),compil_patchDensity(:,2),'k.')
ylabel('patch density (1/µm2) ')
ylim([0 10])
tabOut{4}=compil_patchDensity(:,1:end-1)';

% - Display modifications
scrsz = get(groot,'ScreenSize');
figure(151);fCur=gcf();fCurPos=fCur.Position;
fCur.Position=[1 1 fCurPos(3) fCurPos(4)];

figure(100);fCur=gcf();fCurPos=fCur.Position;
fCur.Position=[1 scrsz(4)-fCurPos(4)-100 fCurPos(3) fCurPos(4)];

figure(121);fCur=gcf();fCurPos=fCur.Position;
fCur.Position=[scrsz(3)-fCurPos(3) 1 fCurPos(3) fCurPos(4)];

figure(111);fCur=gcf();fCurPos=fCur.Position;
fCur.Position=[scrsz(3)-fCurPos(3) scrsz(4)-fCurPos(4)-100 fCurPos(3) fCurPos(4)];

prompt = {'Minimal patch density (1/µm2)','Maximal patch density (1/µm2)','Minimal patch speed (nm/s)','Maximal patch speed (nm/s)','Minimal patch diffusion (1e-3 µm2/s)','Maximal patch diffusion (1e-3 µm2/s)','Save results? (0=no / 1=yes)'};
dlg_title = 'Figures display parameters';
num_lines = 1;
PATCH_DENSITY_MIN=0;
PATCH_DENSITY_MAX=10;
PATCH_SPEED_MIN=0;
PATCH_SPEED_MAX=100;
PATCH_DIFF_MIN=0;
PATCH_DIFF_MAX=10;
DO_SAVE=1;

defaultans = {num2str(PATCH_DENSITY_MIN),num2str(PATCH_DENSITY_MAX),num2str(PATCH_SPEED_MIN),num2str(PATCH_SPEED_MAX),num2str(PATCH_DIFF_MIN),num2str(PATCH_DIFF_MAX),num2str(DO_SAVE)};
%defaultans = {'3','1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
PATCH_DENSITY_MIN=str2double(answer{1});
PATCH_DENSITY_MAX=str2double(answer{2});
PATCH_SPEED_MIN=str2double(answer{3});
PATCH_SPEED_MAX=str2double(answer{4});
PATCH_DIFF_MIN=str2double(answer{5});
PATCH_DIFF_MAX=str2double(answer{6});
DO_SAVE=str2double(answer{7});
figure(151);ylim([PATCH_DENSITY_MIN PATCH_DENSITY_MAX]);
figure(111);ylim([PATCH_SPEED_MIN PATCH_SPEED_MAX]);
figure(121);ylim([PATCH_DIFF_MIN PATCH_DIFF_MAX]);
figure(100);

%% Saving results
if (DO_SAVE)
    pathOut=uigetdir('title','Save all figs in a specific folder? ');
    if (pathOut ~=0)
        cd(pathOut);
        print(100,'dynamicBehavior.svg','-dsvg');
        print(111,'speed.svg','-dsvg');
        print(121,'diffusionCoeff.svg','-dsvg');
        print(151,'patchDensity.svg','-dsvg');
        
        if ispc
            filenameXLS='0_compilationResults.xls';
            A={'dir.','diff.','uncl.','constr.'};
            xlswrite(filenameXLS,A,'dynamicBehavior','A1');
            xlswrite(filenameXLS,tabOut{1},'dynamicBehavior','A2');
            
            xlswrite(filenameXLS,compil_label,'patchDensity','A1');
            xlswrite(filenameXLS,tabOut{4},'patchDensity','A2');
            
            xlswrite(filenameXLS,compil_label,'speed','A1');
            xlswrite(filenameXLS,tabOut{2},'speed','A2');
            
            xlswrite(filenameXLS,compil_label,'diffusionCoeff','A1');
            xlswrite(filenameXLS,tabOut{3},'diffusionCoeff','A2');
            
        else if isunix
                tmpData=tabOut{1};save('dynamicBehavior.txt', 'tmpData','-ascii')
                tmpData=tabOut{2};save('speed.txt', 'tmpData','-ascii')
                tmpData=tabOut{3};save('diffusionCoeff.txt', 'tmpData','-ascii')
                tmpData=tabOut{4};save('patchDensity.txt', 'tmpData','-ascii')
            end
        end
        
        % move tmp figs
        if (~isempty(lstTmpSave_cond))
            for iCond=1:nCond
                lstTmpSave=lstTmpSave_cond{iCond};
                if (~strcmp(lstTmpSave,'none'))
                    if (exist(strcat([pathOut,filesep,'fileVariation']))~=7)
                        mkdir(strcat([pathOut,filesep,'fileVariation']))
                    end
                    srcFile=strcat([lstTmpSave,'velocity_fileVariation.svg']);
                    dstFile=strcat([pathOut,filesep,'fileVariation',filesep,compil_label{iCond},'_velocity_fileVariation.svg']);
                    movefile(srcFile,dstFile)
                    
                    srcFile=strcat([lstTmpSave,'diffusion_fileVariation.svg']);
                    dstFile=strcat([pathOut,filesep,'fileVariation',filesep,compil_label{iCond},'_diffusion_fileVariation.svg']);
                    movefile(srcFile,dstFile)
                    
                    srcFile=strcat([lstTmpSave,'densityAndDynamics_fileVariation.svg']);
                    dstFile=strcat([pathOut,filesep,'fileVariation',filesep,compil_label{iCond},'_densityAndDynamics_fileVariation.svg']);
                    movefile(srcFile,dstFile)
                    
                    srcFile=strcat([lstTmpSave,'all_results.mat']);
                    dstFile=strcat([pathOut,filesep,'fileVariation',filesep,compil_label{iCond},'_all_results.mat']);
                    movefile(srcFile,dstFile)                    
                    
                    %                     srcFile=strcat([lstTmpSave,'trajDurationFrame_fileVariation.svg']);
                    %                     dstFile=strcat([pathOut,filesep,compil_label{iCond},'_trajDurationFrame_fileVariation.svg']);
                    %                     movefile(srcFile,dstFile)
                    %
                    %                     srcFile=strcat([lstTmpSave,'trajDurationSecond_fileVariation.svg']);
                    %                     dstFile=strcat([pathOut,filesep,compil_label{iCond},'_trajDurationSecond_fileVariation.svg']);
                    %                     movefile(srcFile,dstFile)
                end%if
            end%for
        end%if
    end%if
end%if

%remove tmp save folder
if (~isempty(lstTmpSave_cond))
    for iCond=1:nCond
        lstTmpSave=lstTmpSave_cond{iCond};
        if (~strcmp(lstTmpSave,'none'))
            rmdir(lstTmpSave, 's')
        end%if
    end%for
end%if


% % % % % %
% % % % % %
% % % % % % results_final_patchDensity=zeros(nCond,15);
% % % % % % % 1: iCond
% % % % % % % 2: patch density_avg
% % % % % % % 3: directed % avg
% % % % % % % 4: diffused % avg
% % % % % % % 5: constrained % avg
% % % % % % % 6: unclassified % avg
% % % % % % % 7: speed_avg
% % % % % % % 8: diff_avg
% % % % % % % 9: patch density_std
% % % % % % %10: directed % std
% % % % % % %11: diffused % std
% % % % % % %12: constrained % std
% % % % % % %13: unclassified % std
% % % % % % %14: speed_std
% % % % % % %15: diff_std
% % % % % %
% % % % % % for iCond=1:nCond
% % % % % %     tab_patchDensityDyn=compil_patchDensityDyn(compil_patchDensityDyn(:,end)==iCond,1:(end-1));
% % % % % %     tab_patchDynamic=compil_patchDynamic(compil_patchDynamic(:,end)==iCond,1:(end-1));
% % % % % %     results_final_patchDensity(iCond,[1,2,9])=[iCond,nanmean(sum(tab_patchDensityDyn,2)),nanstd(sum(tab_patchDensityDyn,2))];
% % % % % %     results_final_patchDensity(iCond,[7,8,14,15])=[nanmean(tab_patchDynamic(:,2)),nanmean(tab_patchDynamic(:,4)),nanstd(tab_patchDynamic(:,2)),nanstd(tab_patchDynamic(:,4))];
% % % % % %     results_final_patchDensity(iCond,[3,4,5,6,10,11,12,13])=[100*nanmean(tab_patchDynamic(:,6:9)),100*nanstd(tab_patchDynamic(:,6:9))];
% % % % % % end%for
% % % % % %
% % % % % % nCmax=0;
% % % % % % for iCond=1:nCond
% % % % % %     nC=sum(compil_patchDynamic(:,end)==iCond);
% % % % % %     if (nC>nCmax); nCmax=nC;end
% % % % % % end%for
% % % % % %
% % % % % % tab_diffCoeff=NaN(nCmax,nCond);
% % % % % % tab_speed=NaN(nCmax,nCond);
% % % % % % %tab_pDensity=NaN(nCmax,nCond);
% % % % % % for iCond=1:nCond
% % % % % %     tab_patchDynamic=compil_patchDynamic(compil_patchDynamic(:,end)==iCond,1:(end-1));
% % % % % %     z=tab_patchDynamic(:,4);
% % % % % %     tab_diffCoeff(1:numel(z),iCond)=z;
% % % % % %     z=tab_patchDynamic(:,2);
% % % % % %     tab_speed(1:numel(z),iCond)=z;
% % % % % % end
% % % % % %
% % % % % % nCmax=0;
% % % % % % for iCond=1:nCond
% % % % % %     nC=sum(compil_patchDensityDyn(:,end)==iCond);
% % % % % %     if (nC>nCmax); nCmax=nC;end
% % % % % % end%for
% % % % % %
% % % % % % tab_pDensity=NaN(nCmax,nCond);
% % % % % % for iCond=1:nCond
% % % % % %     tab_patchDensityDyn=compil_patchDensityDyn(compil_patchDensityDyn(:,end)==iCond,1:(end-1));
% % % % % %     z=sum(tab_patchDensityDyn,2);
% % % % % %     tab_pDensity(1:numel(z),iCond)=z;
% % % % % % end
% % % % % %
% % % % % % tabOut={};
% % % % % % %% Trajectory dynamics distribtion
% % % % % % kColor=[0 0 0]/255;
% % % % % % bColor=[0 130 254]/255;
% % % % % % oColor=[255 128 1]/255;
% % % % % % gColor=[47 172 102]/255;
% % % % % % mColor=[255 0 255]/255;
% % % % % %
% % % % % % figure(100);clf
% % % % % % y=results_final_patchDensity(:,3:6);
% % % % % % plotOrder=[1,2,4,3];
% % % % % % y=y(:,plotOrder);
% % % % % % tabOut{1}=y;
% % % % % % compil_label_Bar=compil_label;
% % % % % % if (nCond==1)
% % % % % %     y(2,:)=NaN;
% % % % % %     compil_label_Bar{2}=' ';
% % % % % % end
% % % % % % hbar=bar(y,'stacked');
% % % % % % set(gca,'xticklabel',compil_label_Bar)
% % % % % %
% % % % % % hbar(1).FaceColor=bColor;
% % % % % % hbar(2).FaceColor=oColor;
% % % % % % hbar(4).FaceColor=gColor;
% % % % % % hbar(3).FaceColor=205*[1 1 1]/255;
% % % % % % hbar(1).EdgeColor='none';
% % % % % % hbar(2).EdgeColor='none';
% % % % % % hbar(3).EdgeColor='none';
% % % % % % hbar(4).EdgeColor='none';
% % % % % %
% % % % % % hold on;
% % % % % % yerr=results_final_patchDensity(:,10:13);
% % % % % % yerr=yerr(:,plotOrder);
% % % % % %
% % % % % % for i=1:nCond
% % % % % %     for j=1:4
% % % % % %         errorbar(i,sum(y(i,1:j)),yerr(i,j),'k')
% % % % % %     end
% % % % % % end%for
% % % % % % %xlim([0 3])
% % % % % % ylim([0 120])
% % % % % % legend({'dir.','diff.','uncl.','constr.'},'Location','eastoutside')
% % % % % %
% % % % % % pause(0.5)
% % % % % %
% % % % % %
% % % % % % %% Patch speed
% % % % % % %
% % % % % % % figure(110);clf;
% % % % % % % y = results_final_patchDensity(:,[7,14]);hold on
% % % % % % % hbar=bar(y(:,1),'k');
% % % % % % % for i=1:nCond
% % % % % % %     errorbar(i,y(i,1),y(i,2),'k')
% % % % % % % end
% % % % % % % ylabel('speed (nm/s)')
% % % % % % % %xlim([0 3])
% % % % % %
% % % % % % figure(111);clf;
% % % % % % boxplot(tab_speed,'Color','k','Symbol','k.','Labels',compil_label);
% % % % % % ylabel('speed (nm/s) ')
% % % % % % ylim([0 100])
% % % % % % pause(0.5)
% % % % % % tabOut{2}=tab_speed;
% % % % % %
% % % % % % %% Patch diffusion coefficient
% % % % % % %
% % % % % % % figure(120);clf;
% % % % % % % y = 1000*results_final_patchDensity(:,[8,15]);hold on
% % % % % % % hbar=bar(y(:,1),'k');
% % % % % % % for i=1:nCond
% % % % % % %     errorbar(i,y(i,1),y(i,2),'k')
% % % % % % % end
% % % % % % % ylabel('diff. coeff (1e-3 Âµm2/s) ')
% % % % % % % %xlim([0 3])
% % % % % %
% % % % % % figure(121);clf;
% % % % % % boxplot(1000*tab_diffCoeff,'Color','k','Symbol','k.','Labels',compil_label);
% % % % % % ylabel('diff. coeff (1e-3 Âµm2/s) ')
% % % % % % ylim([0 10])
% % % % % % pause(0.5);
% % % % % % tabOut{3}=tab_diffCoeff;
% % % % % %
% % % % % % %% Patch density
% % % % % % %
% % % % % % % figure(150);clf;
% % % % % % % y = results_final_patchDensity(:,[2,9]);hold on
% % % % % % % hbar=bar(y(:,1),'k');
% % % % % % % for i=1:nCond
% % % % % % %     errorbar(i,y(i,1),y(i,2),'k')
% % % % % % % end
% % % % % % % ylabel('patch density (1/Âµm2) ')
% % % % % % % %xlim([0 3])
% % % % % %
% % % % % % figure(151);clf;
% % % % % % boxplot(tab_pDensity,'Color','k','Symbol','k.','Labels',compil_label);
% % % % % % ylabel('patch density (1/Âµm2) ')
% % % % % % ylim([0 10])
% % % % % % tabOut{4}=tab_pDensity;
% % % % % %
% % % % % % % - Display modifications
% % % % % % scrsz = get(groot,'ScreenSize');
% % % % % % figure(151);fCur=gcf();fCurPos=fCur.Position;
% % % % % % fCur.Position=[1 1 fCurPos(3) fCurPos(4)];
% % % % % %
% % % % % % figure(100);fCur=gcf();fCurPos=fCur.Position;
% % % % % % fCur.Position=[1 scrsz(4)-fCurPos(4)-100 fCurPos(3) fCurPos(4)];
% % % % % %
% % % % % % figure(121);fCur=gcf();fCurPos=fCur.Position;
% % % % % % fCur.Position=[scrsz(3)-fCurPos(3) 1 fCurPos(3) fCurPos(4)];
% % % % % %
% % % % % % figure(111);fCur=gcf();fCurPos=fCur.Position;
% % % % % % fCur.Position=[scrsz(3)-fCurPos(3) scrsz(4)-fCurPos(4)-100 fCurPos(3) fCurPos(4)];
% % % % % %
% % % % % % prompt = {'Minimal patch density (1/Âµm2)','Maximal patch density (1/Âµm2)','Minimal patch speed (nm/s)','Maximal patch speed (nm/s)','Minimal patch diffusion (1e-3 Âµm2/s)','Maximal patch diffusion (1e-3 Âµm2/s)','Save results? (0=no / 1=yes)'};
% % % % % % dlg_title = 'Figures display parameters';
% % % % % % num_lines = 1;
% % % % % % PATCH_DENSITY_MIN=0;
% % % % % % PATCH_DENSITY_MAX=10;
% % % % % % PATCH_SPEED_MIN=0;
% % % % % % PATCH_SPEED_MAX=100;
% % % % % % PATCH_DIFF_MIN=0;
% % % % % % PATCH_DIFF_MAX=10;
% % % % % % DO_SAVE=1;
% % % % % %
% % % % % % defaultans = {num2str(PATCH_DENSITY_MIN),num2str(PATCH_DENSITY_MAX),num2str(PATCH_SPEED_MIN),num2str(PATCH_SPEED_MAX),num2str(PATCH_DIFF_MIN),num2str(PATCH_DIFF_MAX),num2str(DO_SAVE)};
% % % % % % %defaultans = {'3','1'};
% % % % % % answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
% % % % % % PATCH_DENSITY_MIN=str2double(answer{1});
% % % % % % PATCH_DENSITY_MAX=str2double(answer{2});
% % % % % % PATCH_SPEED_MIN=str2double(answer{3});
% % % % % % PATCH_SPEED_MAX=str2double(answer{4});
% % % % % % PATCH_DIFF_MIN=str2double(answer{5});
% % % % % % PATCH_DIFF_MAX=str2double(answer{6});
% % % % % % DO_SAVE=str2double(answer{7});
% % % % % % figure(151);ylim([PATCH_DENSITY_MIN PATCH_DENSITY_MAX]);
% % % % % % figure(111);ylim([PATCH_SPEED_MIN PATCH_SPEED_MAX]);
% % % % % % figure(121);ylim([PATCH_DIFF_MIN PATCH_DIFF_MAX]);
% % % % % % figure(100);
% % % % % %
% % % % % % %% Saving results
% % % % % % if (DO_SAVE)
% % % % % %     pathOut=uigetdir('Save all figs in a specific folder? ');
% % % % % %     if (pathOut ~=0)
% % % % % %         cd(pathOut);
% % % % % %         print(100,'dynamicBehavior.svg','-dsvg');
% % % % % %         print(111,'speed.svg','-dsvg');
% % % % % %         print(121,'diffusionCoeff.svg','-dsvg');
% % % % % %         print(151,'patchDensity.svg','-dsvg');
% % % % % %
% % % % % %         if ispc
% % % % % %             filenameXLS='0_compilationResults.xls';
% % % % % %             A={'dir.','diff.','uncl.','constr.'};
% % % % % %             xlswrite(filenameXLS,A,'dynamicBehavior','A1');
% % % % % %             xlswrite(filenameXLS,tabOut{1},'dynamicBehavior','A2');
% % % % % %
% % % % % %             xlswrite(filenameXLS,compil_label,'patchDensity','A1');
% % % % % %             xlswrite(filenameXLS,tabOut{4},'patchDensity','A2');
% % % % % %
% % % % % %             xlswrite(filenameXLS,compil_label,'speed','A1');
% % % % % %             xlswrite(filenameXLS,tabOut{2},'speed','A2');
% % % % % %
% % % % % %             xlswrite(filenameXLS,compil_label,'diffusionCoeff','A1');
% % % % % %             xlswrite(filenameXLS,tabOut{3},'diffusionCoeff','A2');
% % % % % %
% % % % % %         else if isunix
% % % % % %                 tmpData=tabOut{1};save('dynamicBehavior.txt', 'tmpData','-ascii')
% % % % % %                 tmpData=tabOut{2};save('speed.txt', 'tmpData','-ascii')
% % % % % %                 tmpData=tabOut{3};save('diffusionCoeff.txt', 'tmpData','-ascii')
% % % % % %                 tmpData=tabOut{4};save('patchDensity.txt', 'tmpData','-ascii')
% % % % % %             end
% % % % % %         end
% % % % % %     end%if
% % % % % %
% % % % % % end%if
end%function