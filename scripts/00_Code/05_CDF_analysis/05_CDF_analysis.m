clear all;
close all;

scriptPath = matlab.desktop.editor.getActiveFilename;
%fprintf('%s\n',scriptPath);
folderLibMTL=scriptPath(1:max(strfind(scriptPath, filesep)))
addpath(genpath(folderLibMTL));

cd(folderLibMTL);
cd ../../04_patchTrackingClassification_GUI/outputTrackmate/

%% =============== PARAMETERS =============== %%

% Add extra analysis with CDF
doCDF_perTrajDuration=0; % 0 = to skip CDF analysis per traj duration
doCDF_perTrajPoleDistance=0; % 0 = to skip CDF analysis with traj-cell pole distance
doCDF_perTrajStatus=0; % 0 = to skip CDF analysis per traj status
doCDF_perSingleTrajStatus=1; % 0 = to skip CDF analysis per single traj and status

% Remove short tracks
removeShortTraj=1; % 0 = all files are kept; 1=short tracks are removed
minTrajDuration=10; % minimal duration (in frame) of selected tracks if removeShortTraj=1

% CDF analysis parameters displacement
dtCDF=4;
pin=[0.5,0.01,0.00001,NaN];%pin=[0.5,0.010,0.1,NaN];
p_uper=[1,0.1,0.01,NaN];%p_uper=[1,0.1,10.0,NaN];

result_Fit=[];
result_Fit_cellAvg=[];
result_Fit_Full=[];
cond_result_Fit=[];
% cond_result_Fit_cellAvg=[];

%% Select all data to be grouped together

defineNewLst=1;
nCond=0;
compil_label={};

compil_result_Fit_Full_perFile=[];
% compil_result_Fit_DynDir=[];
% compil_result_Fit_DynDiff=[];
% compil_result_Fit_DynConst=[];
% compil_result_Fit_DynUncl=[];
lst_path_cond={};
%lstTmpSave_cond={};
nFile_perCond=[];

lst_path=uipickfiles('Prompt','Select XML file to analyze by CDF');
nFile=numel(lst_path);

% IMPORT DATA
[allData,allParamAcq,allDynStatus]=importDataTraj(lst_path);

% % GET CELL POLES
% [all_cellPole]=getCellPole(lst_path);
%
% % MEASURE TRAJ-POLE DISTANCE
% all_relativPosTrajCell=measure_distTrajPole(allData,all_cellPole,allParamAcq);
%

% TRAJ DURATION DISTRIBUTION
trajDuration=plotTrajDuration(allData);

% GET DISPLACEMENTS BETWEEN FRAMES
if (removeShortTraj)
    disp(strcat(['% of kept trajectories (above min duration): ',num2str(100*mean(allData(:,7)>minTrajDuration))]))
    allDynStatus=allDynStatus(allDynStatus(:,9)>minTrajDuration,:);
    allData=allData(allData(:,7)>minTrajDuration,:);
    
end%if
tab_r_disp=eval_r_disp_allFolder(allData,dtCDF);

%% CDF FULL POPULATION PER FILE
%    result_Fit_Full=cdfAnalysis_all(tab_r_disp,dtCDF,allParamAcq, pin, p_uper);
result_Fit_Full_perFile=cdfAnalysis_perFile(tab_r_disp,dtCDF,allParamAcq, pin, p_uper);

%% CDF PER DYNAMIC STATUS PER FILE
if (doCDF_perTrajStatus)
    [result_Fit_Full_perFile_DynDir, result_Fit_Full_perFile_DynDiff, result_Fit_Full_perFile_DynConst, result_Fit_Full_perFile_DynUncl]=cdfAnalysis_perFile_andStatus(allData,dtCDF,allParamAcq, pin, p_uper);
end%if

%% CDF PER DYNAMIC STATUS PER TRAJ
if (doCDF_perSingleTrajStatus)
    statusID=2;
    result_Fit_perTraj_Status_DynDiff=cdfAnalysis_perTraj_andStatus(allData,dtCDF,allParamAcq, pin, p_uper,statusID);
    
    statusID=3;
    result_Fit_perTraj_Status_DynConst=cdfAnalysis_perTraj_andStatus(allData,dtCDF,allParamAcq, pin, p_uper,statusID);    

    statusID=1;
    result_Fit_perTraj_Status_DynDir=cdfAnalysis_perTraj_andStatus(allData,dtCDF,allParamAcq, pin, p_uper,statusID);

    statusID=0;
    result_Fit_perTraj_Status_DynUncl=cdfAnalysis_perTraj_andStatus(allData,dtCDF,allParamAcq, pin, p_uper,statusID);
end%if

%% CREATE FOLDER FOR SAVING
folderOutput=folderLibMTL;
folderOutputSplit=strsplit(folderOutput,"00_Code");
folderOutput=fullfile(folderOutputSplit{1},folderOutputSplit{2});
if (exist(folderOutput, "dir")~=7)
    mkdir(folderOutput);
end

folderOutputCompilation=fullfile(folderOutput,'1_Compilation');
if (exist(folderOutputCompilation, "dir")~=7); mkdir(folderOutputCompilation); end

if (doCDF_perTrajStatus)
    folderOutputDyn=fullfile(folderOutput,'2_Res_byDynamicBehavior');
    if (exist(folderOutputDyn, "dir")~=7); mkdir(folderOutputDyn); end
end%if

if (doCDF_perSingleTrajStatus)
    folderOutputDynSingleTraj=fullfile(folderOutput,'3_Res_byDynamicBehavior_SingleTraj');
    if (exist(folderOutputDynSingleTraj, "dir")~=7); mkdir(folderOutputDynSingleTraj); end
end%if

%% Saving results
for iFile=1:nFile
    curPath=lst_path{iFile};
    curFilename=strsplit(curPath,strcat(['outputTrackmate',filesep]));curFilename=curFilename{2};
    curFilename=strsplit(curFilename,"Tracks.xml");curFilename=curFilename{1};

    resCDF=result_Fit_Full_perFile(result_Fit_Full_perFile(:,8)==iFile,:);
    figID=resCDF(1);
    resCDF=resCDF([2:6]);
    resultPath=fullfile(folderOutput,strcat(curFilename,'resCDF.txt'));
    save(resultPath,'resCDF','-ascii');    
    figPath=fullfile(folderOutput,strcat(curFilename,'fitCDF.svg'));
    saveas(figID,figPath,'svg');
    close(figID)

    if (doCDF_perTrajStatus)
        resultPath=fullfile(folderOutputDyn,strcat(curFilename,'resCDF_dir.txt'));
        resCDF=result_Fit_Full_perFile_DynDir(result_Fit_Full_perFile_DynDir(:,8)==iFile,:);
        if (~isempty(resCDF));
            resCDF=resCDF([2:6]);
            save(resultPath,'resCDF','-ascii');
        end

        resultPath=fullfile(folderOutputDyn,strcat(curFilename,'resCDF_diff.txt'));
        resCDF=result_Fit_Full_perFile_DynDiff(result_Fit_Full_perFile_DynDiff(:,8)==iFile,:);
        if (~isempty(resCDF));
            resCDF=resCDF([2:6]);
            save(resultPath,'resCDF','-ascii');
        end

        resultPath=fullfile(folderOutputDyn,strcat(curFilename,'resCDF_const.txt'));
        resCDF=result_Fit_Full_perFile_DynConst(result_Fit_Full_perFile_DynConst(:,8)==iFile,:);
        if (~isempty(resCDF));
            resCDF=resCDF([2:6]);
            save(resultPath,'resCDF','-ascii');
        end

        resultPath=fullfile(folderOutputDyn,strcat(curFilename,'resCDF_uncl.txt'));
        resCDF=result_Fit_Full_perFile_DynUncl(result_Fit_Full_perFile_DynUncl(:,8)==iFile,:);
        if (~isempty(resCDF));
            resCDF=resCDF([2:6]);
            save(resultPath,'resCDF','-ascii');
        end        
    end

    if (doCDF_perSingleTrajStatus)
        resultPath=fullfile(folderOutputDynSingleTraj,strcat(curFilename,'resCDF_singleTrajdiff.txt'));
        resCDF=result_Fit_perTraj_Status_DynDiff(result_Fit_perTraj_Status_DynDiff(:,9)==iFile,:);
        if (~isempty(resCDF))
            resCDF=resCDF(:,[2:6]);
            save(resultPath,'resCDF','-ascii');
        end

        resultPath=fullfile(folderOutputDynSingleTraj,strcat(curFilename,'resCDF_singleTrajconst.txt'));
        resCDF=result_Fit_perTraj_Status_DynConst(result_Fit_perTraj_Status_DynConst(:,9)==iFile,:);
        if (~isempty(resCDF))
            resCDF=resCDF(:,[2:6]);
            save(resultPath,'resCDF','-ascii');
        end

        resultPath=fullfile(folderOutputDynSingleTraj,strcat(curFilename,'resCDF_singleTrajdir.txt'));
        resCDF=result_Fit_perTraj_Status_DynDir(result_Fit_perTraj_Status_DynDir(:,9)==iFile,:);
        if (~isempty(resCDF))
            resCDF=resCDF(:,[2:6]);
            save(resultPath,'resCDF','-ascii');
        end

        resultPath=fullfile(folderOutputDynSingleTraj,strcat(curFilename,'resCDF_singleTrajuncl.txt'));
        resCDF=result_Fit_perTraj_Status_DynUncl(result_Fit_perTraj_Status_DynUncl(:,9)==iFile,:);
        if (~isempty(resCDF))
            resCDF=resCDF(:,[2:6]);
            save(resultPath,'resCDF','-ascii');
        end
    end
end

cd(folderOutput)
defineNewLst=1;
nCond=0;
compil_result_Fit_Full_perFile=[];
compil_result_Fit_Full_perFile_Dyn=[];
compil_result_Fit_perTraj_Status_DynDiff=[];
compil_result_Fit_perTraj_Status_DynConst=[];
compil_result_Fit_perTraj_Status_DynDir=[];
compil_result_Fit_perTraj_Status_DynUncl=[];

while (defineNewLst>0)

    % DEFINE LIST TO ANALYSE
    lst_path=uipickfiles('Prompt','Select resCDF files from the same condition that are to be compiled','REFilter','_resCDF.txt');
    nFile=numel(lst_path);
    nCond=nCond+1;   
    
    for iFile=1:nFile
        curFile=lst_path{iFile};
        D=load(curFile);
        compil_result_Fit_Full_perFile=[compil_result_Fit_Full_perFile;D,nCond,iFile];

        if (doCDF_perTrajStatus)
            curFileDir=replace(curFile,'05_CDF_analysis',fullfile('05_CDF_analysis','2_Res_byDynamicBehavior'));
            curFileDir=replace(curFileDir,'resCDF.txt','resCDF_dir.txt');
            if (exist(curFileDir, "file")==2)
                D=load(curFileDir);
                compil_result_Fit_Full_perFile_Dyn=[compil_result_Fit_Full_perFile_Dyn;D,nCond,iFile,1];
            end

            curFileDiff=replace(curFileDir,'resCDF_dir.txt','resCDF_diff.txt');
            if (exist(curFileDiff, "file")==2)
                D=load(curFileDiff);
                compil_result_Fit_Full_perFile_Dyn=[compil_result_Fit_Full_perFile_Dyn;D,nCond,iFile,2];
            end
            
            curFileConst=replace(curFileDir,'resCDF_dir.txt','resCDF_const.txt');
            if (exist(curFileConst, "file")==2)
                D=load(curFileConst);
                compil_result_Fit_Full_perFile_Dyn=[compil_result_Fit_Full_perFile_Dyn;D,nCond,iFile,3];
            end

            curFileUncl=replace(curFileDir,'resCDF_dir.txt','resCDF_uncl.txt');
            if (exist(curFileUncl, "file")==2)
                D=load(curFileUncl);
                compil_result_Fit_Full_perFile_Dyn=[compil_result_Fit_Full_perFile_Dyn;D,nCond,iFile,0];
            end%if
        end

        if (doCDF_perSingleTrajStatus)
            curFileDiff=replace(curFile,'05_CDF_analysis',fullfile('05_CDF_analysis','3_Res_byDynamicBehavior_SingleTraj'));
            curFileDiff=replace(curFileDiff,'resCDF.txt','resCDF_singleTrajdiff.txt');
            if (exist(curFileDiff, "file")==2)
                D=load(curFileDiff);
                nRows=size(D,1);
                compil_result_Fit_perTraj_Status_DynDiff=[compil_result_Fit_perTraj_Status_DynDiff;D,[nCond,iFile,2].*ones(nRows,1)];
            end

            %compil_result_Fit_perTraj_Status_DynConst=[];
            curFileConst=replace(curFileDiff,'resCDF_singleTrajdiff.txt','resCDF_singleTrajconst.txt');
            if (exist(curFileConst, "file")==2)
                D=load(curFileConst);
                nRows=size(D,1);
                compil_result_Fit_perTraj_Status_DynConst=[compil_result_Fit_perTraj_Status_DynConst;D,[nCond,iFile,3].*ones(nRows,1)];
            end

            curFileDir=replace(curFileDiff,'resCDF_singleTrajdiff.txt','resCDF_singleTrajdir.txt');
            if (exist(curFileDir, "file")==2)
                D=load(curFileDir);
                nRows=size(D,1);
                compil_result_Fit_perTraj_Status_DynDir=[compil_result_Fit_perTraj_Status_DynDir;D,[nCond,iFile,1].*ones(nRows,1)];
            end

            curFileUncl=replace(curFileDiff,'resCDF_singleTrajdiff.txt','resCDF_singleTrajuncl.txt');
            if (exist(curFileUncl, "file")==2)
                D=load(curFileUncl);
                nRows=size(D,1);
                compil_result_Fit_perTraj_Status_DynUncl=[compil_result_Fit_perTraj_Status_DynUncl;D,[nCond,iFile,0].*ones(nRows,1)];
            end

        end
    end

    % ASK USER IF NEW LIST IS REQUIRED --
    prompt = {'Set condition name: (e.g.: WT, Mutants1, ...)','Define new list? (1:yes -> new selection / 0: no -> stop and generate final plot):'};
    dlg_title = 'Input';
    num_lines = 1;
    defaultans = {num2str(nCond),num2str(defineNewLst)};
    %defaultans = {'3','1'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    compil_label{nCond}=answer{1}
    defineNewLst=str2num(answer{2});
    if (defineNewLst>0)
        curFolder=lst_path{end};        
        cd(curFolder(1:max(strfind(curFolder, filesep))));
    end
    lst_path_cond{nCond}=lst_path;
end%while

% compil_result_Fit_Full_bak=compil_result_Fit_Full;
% compil_label_bak=compil_label;
% compil_result_Fit_Full=[compil_result_Fit_Full(1:3,:);NaN(1,9);compil_result_Fit_Full(4:6,:);NaN(1,9);compil_result_Fit_Full(7:9,:);NaN(1,9);compil_result_Fit_Full(10:13,:)]
% 

%% PLOT
% - Full population
YLIM_DIFF_FULL=0.025;
figure(100);clf;
subplot(1,4,(1:3))
X = categorical(compil_label);
X = reordercats(X,compil_label);
Y=NaN(nCond,3);
Y_err=NaN(nCond,3);
for iCond=1:nCond
    curRow=compil_result_Fit_Full_perFile(:,6)==iCond;
    Y(iCond,:)=mean(compil_result_Fit_Full_perFile(curRow,[3:4,2]))
    Y_err(iCond,:)=std(compil_result_Fit_Full_perFile(curRow,[3:4,2]))
end%for
%Y = [compil_result_Fit_Full_perFile(:,3)';compil_result_Fit_Full_perFile(:,4)']';
b=bar(X,Y(:,1:2))
b(1).FaceColor='k';
b(2).FaceColor='none';
b(1).EdgeColor='none';
b(2).EdgeColor='k';
ylabel('Diffusion coef. (µm/s)')
ylim([0 YLIM_DIFF_FULL])
title('All trajectories')

subplot(1,4,4)
X = categorical(compil_label);
X = reordercats(X,compil_label);
%Y = [compil_result_Fit_Full(:,2)];
b=bar(X,Y(:,3))
b.FaceColor='r';
b.EdgeColor='none';
ylim([0 1])
ylabel('Ratio fast')

%%--


edgeBin=[0:0.002:0.150];
paramModalDistrib=[];

tabD_fitSingleTraj1Comp=[compil_result_Fit_perTraj_Status_DynDiff;compil_result_Fit_perTraj_Status_DynConst;compil_result_Fit_perTraj_Status_DynDir;compil_result_Fit_perTraj_Status_DynUncl];
figure(88);clf;hold on
for iCond=1:nCond
    subplot(2,2,iCond)

    curD=log(tabD_fitSingleTraj1Comp(tabD_fitSingleTraj1Comp(:,6)==iCond,1));
    %histogram(curD,edgeBin, 'Normalization','pdf')
    
    histogram(curD,'Normalization','pdf')
    x=curD;paramEsts=fitDistrib_biModal(x);paramModalDistrib=[paramModalDistrib;paramEsts];
    %title("1445 - diffusing tracks")
    xlabel("D w/ 1 comp")
    %xlim([0 0.15])
end%for


%% Saving results
DO_SAVE=1;
if (DO_SAVE)
    %pathOut=uigetdir('title','Save all figs in a specific folder? ');
    pathOut=folderOutputCompilation;
    if (pathOut ~=0)
        cd(pathOut);
        print(100,'diffusion2Comp_CDFanalysis_Full.svg','-dsvg');
        % print(110,'diffusion2Comp_CDFanalysis_CellAvg.svg','-dsvg');

        if ispc
            filenameXLS='0_compilationResults.xls';
            
            % A={'trajID','D_1comp','w','Dfast_2comp','Dslow_2comp','nb Traj','cellID','folderID'};
            % xlswrite(filenameXLS,A,'tabResults','A1');
            % xlswrite(filenameXLS,compil_result_Fit_Full,'tabResults','A2');
            
            % - 
            tabResults_perFile=[-ones(size(compil_result_Fit_Full_perFile,1),1),compil_result_Fit_Full_perFile];
            A={'Exp. Day','D_1comp','w','Dfast_2comp','Dslow_2comp','nb Traj','ID_cond','folderID','label_cond'};
            xlswrite(filenameXLS,A,'tabResults_perFile','A1');
            xlswrite(filenameXLS,tabResults_perFile,'tabResults_perFile','A2');
            out_labelCond={};
            iOut=0;
            for iCond=1:nCond
                nRep=sum(tabResults_perFile(:,7)==iCond);
                for iRep=1:nRep
                    iOut=iOut+1;
                    out_labelCond{iOut,1}=compil_label{iCond};
                end
            end
            xlswrite(filenameXLS,out_labelCond,'tabResults_perFile','I2');

            % - 
            if (doCDF_perTrajStatus)
                tabResults_perFile_Dyn=[-ones(size(compil_result_Fit_Full_perFile_Dyn,1),1),compil_result_Fit_Full_perFile_Dyn];
                A={'Exp. Day','D_1comp','w','Dfast_2comp','Dslow_2comp','nb Traj','ID_cond','folderID','label_cond','DynStatus'};
                xlswrite(filenameXLS,A,'tabResults_perFile_Dyn','A1');
                xlswrite(filenameXLS,tabResults_perFile_Dyn(:,1:8),'tabResults_perFile_Dyn','A2');
                out_labelCond={};
                iOut=0;
                for iCond=1:nCond
                    nRep=sum(tabResults_perFile_Dyn(:,7)==iCond);
                    for iRep=1:nRep
                        iOut=iOut+1;
                        out_labelCond{iOut,1}=compil_label{iCond};
                    end
                end
                xlswrite(filenameXLS,out_labelCond,'tabResults_perFile_Dyn','I2');
                xlswrite(filenameXLS,tabResults_perFile_Dyn(:,9),'tabResults_perFile_Dyn','J2');
            end

            % -
            if (doCDF_perSingleTrajStatus)
                compil_result_Fit_perTraj_Status_Dyn=[compil_result_Fit_perTraj_Status_DynDiff;compil_result_Fit_perTraj_Status_DynConst;compil_result_Fit_perTraj_Status_DynDir;compil_result_Fit_perTraj_Status_DynUncl];
                tabResults_perTrajStatus_Dyn=[-ones(size(compil_result_Fit_perTraj_Status_Dyn,1),1),compil_result_Fit_perTraj_Status_Dyn];

                %compil_result_Fit_perTraj_Status_DynDiff
                %compil_result_Fit_perTraj_Status_DynConst

                A={'Exp. Day','D_1comp','w','Dfast_2comp','Dslow_2comp','traj_duration','ID_cond','folderID','label_cond','DynStatus'};
                xlswrite(filenameXLS,A,'tabResults_perTrajStatus_Dyn','A1');
                xlswrite(filenameXLS,tabResults_perTrajStatus_Dyn(:,1:8),'tabResults_perTrajStatus_Dyn','A2');

                out_labelCond={};
                iOut=0;
                for iCond=1:nCond
                    nRep=sum(compil_result_Fit_perTraj_Status_DynDiff(:,6)==iCond);
                    for iRep=1:nRep
                        iOut=iOut+1;
                        out_labelCond{iOut,1}=compil_label{iCond};
                    end
                end
                for iCond=1:nCond
                    nRep=sum(compil_result_Fit_perTraj_Status_DynConst(:,6)==iCond);
                    for iRep=1:nRep
                        iOut=iOut+1;
                        out_labelCond{iOut,1}=compil_label{iCond};
                    end
                end
                for iCond=1:nCond
                    nRep=sum(compil_result_Fit_perTraj_Status_DynDir(:,6)==iCond);
                    for iRep=1:nRep
                        iOut=iOut+1;
                        out_labelCond{iOut,1}=compil_label{iCond};
                    end
                end
                for iCond=1:nCond
                    nRep=sum(compil_result_Fit_perTraj_Status_DynUncl(:,6)==iCond);
                    for iRep=1:nRep
                        iOut=iOut+1;
                        out_labelCond{iOut,1}=compil_label{iCond};
                    end
                end
                xlswrite(filenameXLS,out_labelCond,'tabResults_perTrajStatus_Dyn','I2');
                xlswrite(filenameXLS,tabResults_perTrajStatus_Dyn(:,9),'tabResults_perTrajStatus_Dyn','J2');
            end
            
        else if isunix
                %{
                tmpData=tabOut{1};save('dynamicBehavior.txt', 'tmpData','-ascii')
                tmpData=tabOut{2};save('speed.txt', 'tmpData','-ascii')
                tmpData=tabOut{3};save('diffusionCoeff.txt', 'tmpData','-ascii')
                tmpData=tabOut{4};save('patchDensity.txt', 'tmpData','-ascii')
                %}
            end
        end
        
    end%if
end%if