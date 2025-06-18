function patchTrackingClassification_GUI()

%--------------------------------------------------------------------------
%% function patchTrackingClassification_GUI()
%% HEADER HAS TO BE COMPLETED

%% ================================================= %%
%% ================================================= %%
%% ================================================= %%
disp('================= patchTrackingClassification_GUI =================');
%% ================================================= %%
%% ================================================= %%
%% ================================================= %%

%% ================================================= %%
%% ================================================= %%
%% ================================================= %%

% User interface default colors
colorFgd=[0 0 0];
colorBgd=[204 204 204]/255; %% "Natural" color background
%colorBgd=[1 1 1]; %% White color background
%text_size = 0.70;
text_size_column = 0.10;
edit_text_size = 0.1;
width_column_menu=0.20;

% Create and hide the GUI as it is being constructed.
frontpanel = figure('Visible','on','Position',[00,000,1180,708],...
    'Color',colorBgd,'Resize','on',...
    'Name', 'Patch Tracking Classification 1.2 - ProCeD (Micalis/INRAE)',...  % Title figure
    'NumberTitle', 'off',... % Do not show figure number
    'MenuBar', 'none');
movegui(frontpanel, 'center');

global NUM_FIG_GUI
NUM_FIG_GUI = frontpanel;

%% ================================================= %%
% Parameters related to the interface (mainly the display)
setappdata(gcf,'colorBgd',colorBgd);
setappdata(gcf,'colorFgd',colorFgd);
setappdata(gcf,'width_column_menu',width_column_menu);

%% ================================================= %%
% Parameters specific to the analysis
ALL_LOG={'======================================== Log ========================================'};
LST_FILES='';
TRACKING_METHOD=1;% default is UTrack
EXPORT_RES_4_TRACKMATE=0;% Default: no export
AVERAGING_METHOD_FOR_COMBINE=1;% Default: average per cell

displayParams = struct( ...
    'statusPlot',{-2}, ...
    'cellID',{0}, ...
    'trajSpeed_selection',{0}, ...
    'trajSpeed_min',{0}, ...
    'trajSpeed_max',{1000}, ...
    'trajDiff_selection',{0}, ...
    'trajDiff_min',{0}, ...
    'trajDiff_max',{1000}, ...
    'trajDuration_selection',{0}, ...
    'trajDuration_min',{0}, ...
    'trajDuration_max',{1000});

STATUS_PLOT=displayParams.statusPlot;
CELL_ID_PLOT=displayParams.cellID;

TRAJ_SPEED_SELECTION_PLOT=displayParams.trajSpeed_selection;
TRAJ_SPEED_MIN_PLOT=displayParams.trajSpeed_min;
TRAJ_SPEED_MAX_PLOT=displayParams.trajSpeed_max;

TRAJ_DIFF_SELECTION_PLOT=displayParams.trajDiff_selection;
TRAJ_DIFF_MIN_PLOT=displayParams.trajDiff_min;
TRAJ_DIFF_MAX_PLOT=displayParams.trajDiff_max;

TRAJ_DURATION_SELECTION_PLOT=displayParams.trajDuration_selection;
TRAJ_DURATION_MIN_PLOT=displayParams.trajDuration_min;
TRAJ_DURATION_MAX_PLOT=displayParams.trajDuration_max;

setappdata(gcf,'ALL_LOG',ALL_LOG);
setappdata(gcf,'LST_FILES',LST_FILES);
setappdata(gcf,'TRACKING_METHOD',TRACKING_METHOD);
setappdata(gcf,'EXPORT_RES_4_TRACKMATE',EXPORT_RES_4_TRACKMATE);
setappdata(gcf,'displayParams',displayParams);
setappdata(gcf,'STATUS_PLOT',STATUS_PLOT);
setappdata(gcf,'CELL_ID_PLOT',CELL_ID_PLOT);
setappdata(gcf,'AVERAGING_METHOD_FOR_COMBINE',AVERAGING_METHOD_FOR_COMBINE);


setappdata(gcf,'TRAJ_SPEED_SELECTION_PLOT',TRAJ_SPEED_SELECTION_PLOT);
setappdata(gcf,'TRAJ_SPEED_MIN_PLOT',TRAJ_SPEED_MIN_PLOT);
setappdata(gcf,'TRAJ_SPEED_MAX_PLOT',TRAJ_SPEED_MAX_PLOT);

setappdata(gcf,'TRAJ_DIFF_SELECTION_PLOT',TRAJ_DIFF_SELECTION_PLOT);
setappdata(gcf,'TRAJ_DIFF_MAX_PLOT',TRAJ_DIFF_MAX_PLOT);
setappdata(gcf,'TRAJ_DIFF_MAX_PLOT',TRAJ_DIFF_MAX_PLOT);

setappdata(gcf,'TRAJ_DURATION_SELECTION_PLOT',TRAJ_DURATION_SELECTION_PLOT);
setappdata(gcf,'TRAJ_DURATION_MIN_PLOT',TRAJ_DURATION_MIN_PLOT);
setappdata(gcf,'TRAJ_DURATION_MAX_PLOT',TRAJ_DURATION_MAX_PLOT);

%% ================================================= %%
% The command line below defined the spatial structure of the user
% interface. Their related functions are defined at the end of this file.

%% ================================================= %%
%
%                       Panel Menu
%
%% ================================================= %%

%% ================================================= %%
pTCpanel = uipanel('Parent',frontpanel,'Title','Automatic Classification of Dynamics',...
    'Position',[.03 .50 .96 .48],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

%% ================================================= %%
FileLst_pushbutton=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','1-Input data','HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.03,0.85,width_column_menu,0.10],...
    'TooltipString', 'Define list of files to be processed',...
    'Callback',{@FileLst_pushbutton_Callback});

%% ================================================= %%
selectTrackingMethod_PUM=uicontrol('Parent',pTCpanel,'Style','popupmenu',...
    'String',{'2.1 - Tracking method:', 'UTrack - comet detection (default)','Trackmate'},...
    'Units','normalized','Position',[0.03,0.73,width_column_menu,0.10],...
    'TooltipString', 'Select tracking software used',...
    'Callback',{@selectTrackingMethod_PUM_Callback});

%% ================================================= %%
exportResultForTrackmate_PUM=uicontrol('Parent',pTCpanel,'Style','popupmenu',...
    'String',{'2.2 - Export results for trackmate:', 'No export (default)','Yes'},...
    'Units','normalized','Position',[0.03,0.66,width_column_menu,0.10],...
    'TooltipString', 'Select tracking software used',...
    'Callback',{@exportResultForTrackmate_PUM_Callback});

%% ================================================= %%
CheckFileList_pushbutton=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','3-Data checking',...
    'Units','normalized','Position',[0.03,0.58,width_column_menu,0.10],...
    'TooltipString', 'Check if required data exist and spec file correctly defined before MSD analysis',...
    'Callback',{@CheckFileList_pushbutton_Callback});

%% ================================================= %%
run_patch_trackingClassificationDynamic_pushbutton=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','4-Dynamic classification (MSD)',...
    'Units','normalized','Position',[0.03,0.46,width_column_menu,0.10],...
    'TooltipString', 'Dynamic classification of patches (based on MSD)',...
    'Callback',{@run_patch_trackingClassificationDynamic_pushbutton_Callback});

%% ================================================= %%
selectPoolMethod_PUM=uicontrol('Parent',pTCpanel,'Style','popupmenu',...
    'String',{'5.0 - Averaging method:', 'Results with cell averaging (default)','Results with full image averaging'},...
    'Units','normalized','Position',[0.03,0.30,width_column_menu,0.10],...
    'TooltipString', 'Specify if results should be averaged by cells',...
    'Callback',{@selectPoolMethod_PUM_Callback});

%% ================================================= %%
plotCombineCompare_patch_trackingClassificationDynamic_PB=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','5-Combine/Compare - Plot & Save',...
    'Units','normalized','Position',[0.03,0.22,width_column_menu,0.10],...
    'TooltipString', 'Combine and plot results of processed data',...
    'Callback',{@plotCombineCompare_pushbutton_Callback});

%% ================================================= %%
displayLOG_Text = uicontrol('Parent',pTCpanel,'Style','text',...
    'String',ALL_LOG,'Visible','on','Tag','displayLOG_Text',...
    'HorizontalAlignment','left',...
    'Units','normalized','Position',[width_column_menu+0.05,0.05,width_column_menu*3,0.9],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

%% ================================================= %%
ClearLog_pushbutton=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','Clear Log','HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.03+4*width_column_menu,0.85,width_column_menu*0.75,0.10],...
    'TooltipString', 'Clear lines displayed in log',...
    'Callback',{@ClearLog_pushbutton_Callback});

%% ================================================= %%
pTC_Tools_panel = uipanel('Parent',frontpanel, ...
    'Title','Export tracks and dynamic classification for visualization using Trackmate',...
    'Position',[.03 .02 .96 .47],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

%% ================================================= %%
pTC_Tools_Param_panel_CellSel_PUM=uicontrol('Parent',pTC_Tools_panel,'Style','popupmenu',...
    'String',{'Cell to be exported:', 'Cell: all (default)','Cell: single'},...
    'Units','normalized','Position',[0.03,0.81,width_column_menu,0.10],...
    'TooltipString', 'Select cells to be exported',...
    'Callback',{@pTC_Tools_Param_panel_CellSel_PUM_Callback});

%% ================================================= %%
pTC_Tools_Param_panel_DynSel_PUM=uicontrol('Parent',pTC_Tools_panel,'Style','popupmenu',...
    'String',{'Tracks to be exported:', 'Dynamic: all of them (default)','Dynamic: directed','Dynamic: diffusing','Dynamic: constrained','Dynamic: unclassified','Dynamic: untreated'},...
    'Units','normalized','Position',[0.03,0.71,width_column_menu,0.10],...
    'TooltipString', 'Select dynamic behavior of tracks to be exported',...
    'Callback',{@pTC_Tools_Param_panel_DynSel_PUM_Callback});

%% ================================================= %%
pTC_Tools_Param_panel_DurationSel_PUM=uicontrol('Parent',pTC_Tools_panel,'Style','popupmenu',...
    'String',{'Filter tracks based on duration:', 'Duration : no selection (default)' , 'Duration: Traj will be selected based on min/max duration criteria'},...
    'Units','normalized','Position',[0.03,0.61,width_column_menu,0.10],...
    'TooltipString', 'Defined track duration to be exported',...
    'Callback',{@pTC_Tools_Param_panel_DurationSel_PUM_Callback});

%% ================================================= %%
pTC_Tools_Param_panel_SpeedSel_PUM=uicontrol('Parent',pTC_Tools_panel,'Style','popupmenu',...
    'String',{'Filter tracks based on velocity:', 'Velocity : no selection (default)' , 'Velocity: Traj will be selected based on min/max speed criteria'},...
    'Units','normalized','Position',[0.03,0.51,width_column_menu,0.10],...
    'TooltipString', 'Defined directed track to be exported',...
    'Callback',{@pTC_Tools_Param_panel_SpeedSel_PUM_Callback});

%% ================================================= %%
pTC_Tools_Param_panel_DiffSel_PUM=uicontrol('Parent',pTC_Tools_panel,'Style','popupmenu',...
    'String',{'Filter tracks based on diffusion:', 'Diffusion : no selection (default)' , 'Diffusion: Traj will be selected based on min/max diff coef criteria'},...
    'Units','normalized','Position',[0.03,0.41,width_column_menu,0.10],...
    'TooltipString', 'Defined diffusing track to be exported',...
    'Callback',{@pTC_Tools_Param_panel_DiffSel_PUM_Callback});

%% ================================================= %%
% % % pTC_Tools_Param_panel = uipanel('Parent',pTC_Tools_panel,...
% % %     'Title','Tracks and dynamic selection',...
% % %     'Position',[0.08+width_column_menu 0.20 3*width_column_menu+0.05 .8],...
% % %     'BackgroundColor',colorBgd,...
% % %     'ForegroundColor',colorFgd);

% % % % COL 1 (traj status / cellID)
col1_posW=0.35;
pTC_Tools_C1_Param2_Text = uicontrol('Parent',pTC_Tools_panel,'Style','text',...
    'String','Cell ID','Visible','off',...
    'Units','normalized','Position',[col1_posW,0.80,text_size_column,0.15],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C1_Param2_editText = uicontrol('Parent',pTC_Tools_panel,'Style','edit',...
    'String',num2str(CELL_ID_PLOT),'Visible','off',...
    'Units','normalized','Position',[col1_posW,0.70,edit_text_size,0.12],...
    'TooltipString', '0 : select all of them; otherwise select Cell ID shown in Fig 50',...
    'Callback',{@pTC_Tools_C1_Param2_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

setappdata(gcf,'pTC_Tools_C1_Param2_Text',pTC_Tools_C1_Param2_Text);
setappdata(gcf,'pTC_Tools_C1_Param2_editText',pTC_Tools_C1_Param2_editText);

% COL 2 (duration sel/min/max)
col2_posW=0.50;

pTC_Tools_C2_Param2_Text = uicontrol('Parent',pTC_Tools_panel,'Style','text',...
    'String','Max duration (frame)','Visible','off',...
    'Units','normalized','Position',[col2_posW,0.80,text_size_column,0.15],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C2_Param2_editText = uicontrol('Parent',pTC_Tools_panel,'Style','edit',...
    'String',num2str(TRAJ_DURATION_MAX_PLOT),'Visible','off',...
    'Units','normalized','Position',[col2_posW,0.70,edit_text_size,0.12],...
    'TooltipString', 'Max duration value for traj selection (frame)',...
    'Callback',{@pTC_Tools_C2_Param2_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C2_Param3_Text = uicontrol('Parent',pTC_Tools_panel,'Style','text',...
    'String','Min duration (frame)','Visible','off',...
    'Units','normalized','Position',[col2_posW,0.50,text_size_column,0.15],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C2_Param3_editText = uicontrol('Parent',pTC_Tools_panel,'Style','edit',...
    'String',num2str(TRAJ_DURATION_MIN_PLOT),'Visible','off',...
    'Units','normalized','Position',[col2_posW,0.40,edit_text_size,0.12],...
    'TooltipString', 'Min duration value for traj selection (frame)',...
    'Callback',{@pTC_Tools_C2_Param3_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

setappdata(gcf,'pTC_Tools_C2_Param2_Text',pTC_Tools_C2_Param2_Text);
setappdata(gcf,'pTC_Tools_C2_Param2_editText',pTC_Tools_C2_Param2_editText);
setappdata(gcf,'pTC_Tools_C2_Param3_Text',pTC_Tools_C2_Param3_Text);
setappdata(gcf,'pTC_Tools_C2_Param3_editText',pTC_Tools_C2_Param3_editText);

% COL 3 (speed sel/min/max)
col3_posW=0.65;
pTC_Tools_C3_Param2_Text = uicontrol('Parent',pTC_Tools_panel,'Style','text',...
    'String','Max speed (nm/s)','Visible','off',...
    'Units','normalized','Position',[col3_posW,0.80,text_size_column,0.15],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C3_Param2_editText = uicontrol('Parent',pTC_Tools_panel,'Style','edit',...
    'String',num2str(TRAJ_SPEED_MAX_PLOT),'Visible','off',...
    'Units','normalized','Position',[col3_posW,0.70,edit_text_size,0.12],...
    'TooltipString', 'Max speed value for traj selection (nm/s)',...
    'Callback',{@pTC_Tools_C3_Param2_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C3_Param3_Text = uicontrol('Parent',pTC_Tools_panel,'Style','text',...
    'String','Min speed (nm/s)','Visible','off',...
    'Units','normalized','Position',[col3_posW,0.50,text_size_column,0.15],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C3_Param3_editText = uicontrol('Parent',pTC_Tools_panel,'Style','edit',...
    'String',num2str(TRAJ_SPEED_MIN_PLOT),'Visible','off',...
    'Units','normalized','Position',[col3_posW,0.40,edit_text_size,0.12],...
    'TooltipString', 'Min speed value for traj selection (nm/s)',...
    'Callback',{@pTC_Tools_C3_Param3_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

setappdata(gcf,'pTC_Tools_C3_Param2_Text',pTC_Tools_C3_Param2_Text);
setappdata(gcf,'pTC_Tools_C3_Param2_editText',pTC_Tools_C3_Param2_editText);
setappdata(gcf,'pTC_Tools_C3_Param3_Text',pTC_Tools_C3_Param3_Text);
setappdata(gcf,'pTC_Tools_C3_Param3_editText',pTC_Tools_C3_Param3_editText);

% COL 4 (diff sel/min/max)
col4_posW=0.80;

pTC_Tools_C4_Param2_Text = uicontrol('Parent',pTC_Tools_panel,'Style','text',...
    'String','Max D (µm2/s)','Visible','off',...
    'Units','normalized','Position',[col4_posW,0.80,text_size_column,0.15],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C4_Param2_editText = uicontrol('Parent',pTC_Tools_panel,'Style','edit',...
    'String',num2str(TRAJ_DIFF_MAX_PLOT),'Visible','off',...
    'Units','normalized','Position',[col4_posW,0.70,edit_text_size,0.12],...
    'TooltipString', 'Max D value for traj selection (µm2/s)',...
    'Callback',{@pTC_Tools_C4_Param2_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C4_Param3_Text = uicontrol('Parent',pTC_Tools_panel,'Style','text',...
    'String','Min D (µm2/s)','Visible','off',...
    'Units','normalized','Position',[col4_posW,0.50,text_size_column,0.15],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_C4_Param3_editText = uicontrol('Parent',pTC_Tools_panel,'Style','edit',...
    'String',num2str(TRAJ_DIFF_MIN_PLOT),'Visible','off',...
    'Units','normalized','Position',[col4_posW,0.40,edit_text_size,0.12],...
    'TooltipString', 'Min D value for traj selection (µm2/s)',...
    'Callback',{@pTC_Tools_C4_Param3_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

setappdata(gcf,'pTC_Tools_C4_Param2_Text',pTC_Tools_C4_Param2_Text);
setappdata(gcf,'pTC_Tools_C4_Param2_editText',pTC_Tools_C4_Param2_editText);
setappdata(gcf,'pTC_Tools_C4_Param3_Text',pTC_Tools_C4_Param3_Text);
setappdata(gcf,'pTC_Tools_C4_Param3_editText',pTC_Tools_C4_Param3_editText);

%% ================================================= %%
check_patch_trackingClassificationDynamic_pushbutton=uicontrol('Parent',pTC_Tools_panel,'Style','pushbutton',...
    'String','Export tracks with classification',...
    'Units','normalized','Position',[0.03,0.20,width_column_menu,0.10],...
    'TooltipString', 'Display tracks and its classification (single file)',...
    'Callback',{@check_patch_trackingClassificationDynamic_pushbutton_Callback});

end%function

%--------------------------------------------------------------------------
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% functions associated with patchTrackingClassification_GUI()
%%
%%

%% function FileLst_pushbutton_Callback(hObject, eventdata, handles)
% open a dialog box to choose the files to be processed
function FileLst_pushbutton_Callback(hObject, eventdata, handles)
imageFormatFile={ '*.tif','Tiff-files (Nikon/MM)';'*.czi', 'CarlZeissImage-files (Zeiss Elyra PS1/7)';'*.txt', 'All text files';'*.xml', 'All xml files (Trackmate)';'*.*', 'All files'};
LST_FILES=uipickfiles('Type',imageFormatFile);
%LST_FILES=uipickfiles('FilterSpec','*.tif;*.czi');
ALL_LOG=getappdata(gcbf,'ALL_LOG');

setappdata(gcbf,'LST_FILES',LST_FILES);
logTxt=strcat(['Step 1: ',num2str(numel(LST_FILES)),' files are selected for anaylsis']);

ALL_LOG{1+numel(ALL_LOG)}=logTxt;
setappdata(gcbf,'ALL_LOG',ALL_LOG);

displayLOG_Text = findobj(gcbf, 'Tag','displayLOG_Text');
set(displayLOG_Text,'String',ALL_LOG)
end

%% function selectTrackingMethod_PUM_Callback(source,eventdata)
% define the tracking algorithm used in order to import properly the tracks
% for the current analysis
function selectTrackingMethod_PUM_Callback(source,eventdata)
TRACKING_METHOD=(source.Value-1);
%disp(TRACKING_METHOD);
setappdata(gcbf,'TRACKING_METHOD',TRACKING_METHOD);

ALL_LOG=getappdata(gcbf,'ALL_LOG');
logTxt='';
switch (TRACKING_METHOD)
    case 1
        logTxt='Step 2.1: Tracking by UTrack - comet detection';
    case 2
        logTxt='Step 2.1: Tracking by Trackmate';
end%switch
if (~isempty(logTxt))
    ALL_LOG{1+numel(ALL_LOG)}=logTxt;
    setappdata(gcbf,'ALL_LOG',ALL_LOG);
    
    displayLOG_Text = findobj(gcbf, 'Tag','displayLOG_Text');
    set(displayLOG_Text,'String',ALL_LOG)
end%if
end

%% function exportResultForTrackmate_PUM_Callback(source,eventdata)
% specify if the results should be expoted in Trackmate format for
% visualization
function exportResultForTrackmate_PUM_Callback(source,eventdata)
if (source.Value==2);EXPORT_RES_4_TRACKMATE=0;end
if (source.Value==3);EXPORT_RES_4_TRACKMATE=1;end
%disp(EXPORT_RES_4_TRACKMATE);
setappdata(gcbf,'EXPORT_RES_4_TRACKMATE',EXPORT_RES_4_TRACKMATE);

ALL_LOG=getappdata(gcbf,'ALL_LOG');
switch (EXPORT_RES_4_TRACKMATE)
    case 0
        logTxt='Step 2.2: Classification results will not be exported for Trackmate';
    case 1
        logTxt='Step 2.2: Classification results will be exported for Trackmate';
end%switch
if (~isempty(logTxt))
    ALL_LOG{1+numel(ALL_LOG)}=logTxt;
    setappdata(gcbf,'ALL_LOG',ALL_LOG);
    
    displayLOG_Text = findobj(gcbf, 'Tag','displayLOG_Text');
    set(displayLOG_Text,'String',ALL_LOG)
end%if
end

%% function CheckFileList_pushbutton_Callback(hObject, eventdata, handles)
% run the checkNeededData_patch_trackingClassificationDynamic_v190103
% function to check if all required files exist and in unsual values are
% not present in spec files.
function CheckFileList_pushbutton_Callback(hObject, eventdata, handles)
LST_FILES=getappdata(gcbf,'LST_FILES');
TRACKING_METHOD=getappdata(gcbf,'TRACKING_METHOD');
ALL_LOG=getappdata(gcbf,'ALL_LOG');
[text_error,i_err]=checkNeededData_patch_trackingClassificationDynamic_v210721(LST_FILES,TRACKING_METHOD);
if i_err>0
    fprintf('\n\n');
    for i=1:i_err
        disp(strcat(['--------- Error #',num2str(i),'/',num2str(i_err)]));
        disp(text_error{i});
        
        logTxt=strcat(['Step 3: --------- Error #',num2str(i),'/',num2str(i_err)]);
        ALL_LOG{1+numel(ALL_LOG)}=logTxt;
        logTxt=text_error{i};
        ALL_LOG{1+numel(ALL_LOG)}=logTxt;
        
    end%for
else
    fprintf('\n\n');
    disp('no error found');
    logTxt='Step 3: no error found';
    ALL_LOG{1+numel(ALL_LOG)}=logTxt;
end
setappdata(gcbf,'ALL_LOG',ALL_LOG);
displayLOG_Text = findobj(gcbf, 'Tag','displayLOG_Text');
set(displayLOG_Text,'String',ALL_LOG)
end

%% function run_patch_trackingClassificationDynamic_pushbutton_Callback(hObject, eventdata, handles)
% run the function run_patch_trackingClassificationDynamic_v210721 which
% load cell mask, tracks and spec files to classify automatically each
% tracks (using MSD)
function run_patch_trackingClassificationDynamic_pushbutton_Callback(hObject, eventdata, handles)
LST_FILES=getappdata(gcbf,'LST_FILES');
TRACKING_METHOD=getappdata(gcbf,'TRACKING_METHOD');
EXPORT_RES_4_TRACKMATE=getappdata(gcbf,'EXPORT_RES_4_TRACKMATE');
ALL_LOG=getappdata(gcbf,'ALL_LOG');

displayLOG_Text = findobj(gcbf, 'Tag','displayLOG_Text');
logTxt=strcat(['Step 4: Classification analysis started at: ',datestr(datetime('now'))]);
ALL_LOG{1+numel(ALL_LOG)}=logTxt;
set(displayLOG_Text,'String',ALL_LOG)

run_patch_trackingClassificationDynamic_v210721(LST_FILES,TRACKING_METHOD,EXPORT_RES_4_TRACKMATE);

logTxt=strcat(['Step 4: Classification analysis finished at: ',datestr(datetime('now'))]);
ALL_LOG{1+numel(ALL_LOG)}=logTxt;
set(displayLOG_Text,'String',ALL_LOG)
setappdata(gcbf,'ALL_LOG',ALL_LOG);


end

%% function selectPoolMethod_PUM_Callback(source,eventdata)
% define
function selectPoolMethod_PUM_Callback(source,eventdata)
AVERAGING_METHOD_FOR_COMBINE=(source.Value-1);
%disp(AVERAGING_METHOD_FOR_COMBINE);
setappdata(gcbf,'AVERAGING_METHOD_FOR_COMBINE',AVERAGING_METHOD_FOR_COMBINE);

ALL_LOG=getappdata(gcbf,'ALL_LOG');
logTxt='';
switch (AVERAGING_METHOD_FOR_COMBINE)
    case 1
        logTxt='Averaging of results per cell';
    case 2
        logTxt='averaging of results per image';
end%switch
if (~isempty(logTxt))
    ALL_LOG{1+numel(ALL_LOG)}=logTxt;
    setappdata(gcbf,'ALL_LOG',ALL_LOG);
    
    displayLOG_Text = findobj(gcbf, 'Tag','displayLOG_Text');
    set(displayLOG_Text,'String',ALL_LOG)
end%if
end

%% function plotCombineCompare_pushbutton_Callback(hObject, eventdata, handles)
% run the function
% plotCombineCompare_patch_trackingClassificationDynamic_v190103 to
% generate figures and tables from differents experimental conditions
function plotCombineCompare_pushbutton_Callback(hObject, eventdata, handles)

AVERAGING_METHOD_FOR_COMBINE=getappdata(gcbf,'AVERAGING_METHOD_FOR_COMBINE');
plotCombineCompare_patch_trackingClassificationDynamic_v211117(AVERAGING_METHOD_FOR_COMBINE);
end

%% function ClearLog_pushbutton_Callback(hObject, eventdata, handles)
% Clean lines of the log
function ClearLog_pushbutton_Callback(hObject, eventdata, handles)
ALL_LOG={'======================================== Log ========================================'};
displayLOG_Text = findobj(gcbf, 'Tag','displayLOG_Text');
set(displayLOG_Text,'String',ALL_LOG)
setappdata(gcbf,'ALL_LOG',ALL_LOG);
end

%% function pTC_Tools_Param_panel_CellSel_PUM_Callback(source,eventdata)
% define cell selection to be exported in trackmate 
function pTC_Tools_Param_panel_CellSel_PUM_Callback(source,eventdata)
userChoice=(source.Value-1);
disp(userChoice);

pTC_Tools_C1_Param2_Text=getappdata(gcbf,'pTC_Tools_C1_Param2_Text');
pTC_Tools_C1_Param2_editText=getappdata(gcbf,'pTC_Tools_C1_Param2_editText');

switch(userChoice)
    case 1
        CELL_ID_PLOT = 0;
        disp('No selection based on cell');
        set(pTC_Tools_C1_Param2_Text,'Visible','off');
        set(pTC_Tools_C1_Param2_editText,'Visible','off');
    case 2
        CELL_ID_PLOT = 1;
        disp('Selection of tracks belonging to a specific cell');
        set(pTC_Tools_C1_Param2_Text,'Visible','on');
        set(pTC_Tools_C1_Param2_editText,'Visible','on');
end%switch

setappdata(gcbf,'CELL_ID_PLOT',CELL_ID_PLOT);

end

%% function pTC_Tools_Param_panel_DynSel_PUM_Callback(source,eventdata)
% define class of dynamic behavior to be exported in trackmate 
function pTC_Tools_Param_panel_DynSel_PUM_Callback(source,eventdata)
userChoice=(source.Value-1);
%disp(userChoice);
switch(userChoice)
    case 1        
        STATUS_PLOT = -2;
    case 2
        STATUS_PLOT = 1;
    case 3
        STATUS_PLOT = 2;
    case 4
        STATUS_PLOT = 3;
    case 5
        STATUS_PLOT = 0;
    case 6
        STATUS_PLOT = -1;
end%switch
%disp(STATUS_PLOT);
setappdata(gcbf,'STATUS_PLOT',STATUS_PLOT);

end

%% function pTC_Tools_Param_panel_DurationSel_PUM_Callback(source,eventdata)
% define track duration selection to be exported in trackmate 
function pTC_Tools_Param_panel_DurationSel_PUM_Callback(source,eventdata)
userChoice=(source.Value-1);
%disp(userChoice);

pTC_Tools_C2_Param2_Text=getappdata(gcbf,'pTC_Tools_C2_Param2_Text');
pTC_Tools_C2_Param2_editText=getappdata(gcbf,'pTC_Tools_C2_Param2_editText');
pTC_Tools_C2_Param3_Text=getappdata(gcbf,'pTC_Tools_C2_Param3_Text');
pTC_Tools_C2_Param3_editText=getappdata(gcbf,'pTC_Tools_C2_Param3_editText');


switch(userChoice)
    case 1
        TRAJ_DURATION_SELECTION_PLOT = 0;
        disp('No selection based on duration');
        set(pTC_Tools_C2_Param2_Text,'Visible','off');
        set(pTC_Tools_C2_Param2_editText,'Visible','off');
        set(pTC_Tools_C2_Param3_Text,'Visible','off');
        set(pTC_Tools_C2_Param3_editText,'Visible','off');
    case 2
        disp('Selection of tracks based on duration')
        TRAJ_DURATION_SELECTION_PLOT = 1;
        set(pTC_Tools_C2_Param2_Text,'Visible','on');
        set(pTC_Tools_C2_Param2_editText,'Visible','on');
        set(pTC_Tools_C2_Param3_Text,'Visible','on');
        set(pTC_Tools_C2_Param3_editText,'Visible','on');
end%switch

setappdata(gcbf,'TRAJ_DURATION_SELECTION_PLOT',TRAJ_DURATION_SELECTION_PLOT);

end

%% function pTC_Tools_Param_panel_SpeedSel_PUM_Callback(source,eventdata)
% define track velocity selection to be exported in trackmate 
function pTC_Tools_Param_panel_SpeedSel_PUM_Callback(source,eventdata)
userChoice=(source.Value-1);
%disp(userChoice);

pTC_Tools_C3_Param2_Text=getappdata(gcbf,'pTC_Tools_C3_Param2_Text');
pTC_Tools_C3_Param2_editText=getappdata(gcbf,'pTC_Tools_C3_Param2_editText');
pTC_Tools_C3_Param3_Text=getappdata(gcbf,'pTC_Tools_C3_Param3_Text');
pTC_Tools_C3_Param3_editText=getappdata(gcbf,'pTC_Tools_C3_Param3_editText');

switch(userChoice)
    case 1
        TRAJ_SPEED_SELECTION_PLOT = 0;
        disp('No selection based on velocity');
        set(pTC_Tools_C3_Param2_Text,'Visible','off');
        set(pTC_Tools_C3_Param2_editText,'Visible','off');
        set(pTC_Tools_C3_Param3_Text,'Visible','off');
        set(pTC_Tools_C3_Param3_editText,'Visible','off');
    case 2
        disp('Selection of tracks based on velocity')
        TRAJ_SPEED_SELECTION_PLOT = 1;
        set(pTC_Tools_C3_Param2_Text,'Visible','on');
        set(pTC_Tools_C3_Param2_editText,'Visible','on');
        set(pTC_Tools_C3_Param3_Text,'Visible','on');
        set(pTC_Tools_C3_Param3_editText,'Visible','on');
end%switch

setappdata(gcbf,'TRAJ_SPEED_SELECTION_PLOT',TRAJ_SPEED_SELECTION_PLOT);

end

%% function pTC_Tools_Param_panel_DiffSel_PUM_Callback(source,eventdata)
% define track with selected diffusion properties to be exported in trackmate 
function pTC_Tools_Param_panel_DiffSel_PUM_Callback(source,eventdata)
userChoice=(source.Value-1);
%disp(userChoice);

pTC_Tools_C4_Param2_Text=getappdata(gcbf,'pTC_Tools_C4_Param2_Text');
pTC_Tools_C4_Param2_editText=getappdata(gcbf,'pTC_Tools_C4_Param2_editText');
pTC_Tools_C4_Param3_Text=getappdata(gcbf,'pTC_Tools_C4_Param3_Text');
pTC_Tools_C4_Param3_editText=getappdata(gcbf,'pTC_Tools_C4_Param3_editText');


switch(userChoice)
    case 1
        TRAJ_DIFF_SELECTION_PLOT = 0;
        disp('No selection based on diffusion');
        set(pTC_Tools_C4_Param2_Text,'Visible','off');
        set(pTC_Tools_C4_Param2_editText,'Visible','off');
        set(pTC_Tools_C4_Param3_Text,'Visible','off');
        set(pTC_Tools_C4_Param3_editText,'Visible','off');
    case 2
        disp('Selection of tracks based on diffusion')
        TRAJ_DIFF_SELECTION_PLOT = 1;
        set(pTC_Tools_C4_Param2_Text,'Visible','on');
        set(pTC_Tools_C4_Param2_editText,'Visible','on');
        set(pTC_Tools_C4_Param3_Text,'Visible','on');
        set(pTC_Tools_C4_Param3_editText,'Visible','on');
end%switch

setappdata(gcbf,'TRAJ_DIFF_SELECTION_PLOT',TRAJ_DIFF_SELECTION_PLOT);

end


%% function check_patch_trackingClassificationDynamic_pushbutton_Callback(hObject, eventdata, handles)
% run the function visualize_patch_trackingClassificationDynamic_v210721 to
% display tracks and their classification superimposed on time-lapse
% movies.
function check_patch_trackingClassificationDynamic_pushbutton_Callback(hObject, eventdata, handles)

TRACKING_METHOD=getappdata(gcbf,'TRACKING_METHOD');

STATUS_PLOT=getappdata(gcbf,'STATUS_PLOT');
CELL_ID_PLOT=getappdata(gcbf,'CELL_ID_PLOT');

TRAJ_SPEED_SELECTION_PLOT=getappdata(gcbf,'TRAJ_SPEED_SELECTION_PLOT');
TRAJ_SPEED_MIN_PLOT=getappdata(gcbf,'TRAJ_SPEED_MIN_PLOT');
TRAJ_SPEED_MAX_PLOT=getappdata(gcbf,'TRAJ_SPEED_MAX_PLOT');

TRAJ_DIFF_SELECTION_PLOT=getappdata(gcbf,'TRAJ_DIFF_SELECTION_PLOT');
TRAJ_DIFF_MIN_PLOT=getappdata(gcbf,'TRAJ_DIFF_MIN_PLOT');
TRAJ_DIFF_MAX_PLOT=getappdata(gcbf,'TRAJ_DIFF_MAX_PLOT');

TRAJ_DURATION_SELECTION_PLOT=getappdata(gcbf,'TRAJ_DURATION_SELECTION_PLOT');
TRAJ_DURATION_MIN_PLOT=getappdata(gcbf,'TRAJ_DURATION_MIN_PLOT');
TRAJ_DURATION_MAX_PLOT=getappdata(gcbf,'TRAJ_DURATION_MAX_PLOT');

displayParams=getappdata(gcbf,'displayParams');

displayParams.statusPlot=STATUS_PLOT;
displayParams.cellID=CELL_ID_PLOT;

displayParams.trajSpeed_selection=TRAJ_SPEED_SELECTION_PLOT;
displayParams.trajSpeed_min=TRAJ_SPEED_MIN_PLOT;
displayParams.trajSpeed_max=TRAJ_SPEED_MAX_PLOT;

displayParams.trajDiff_selection=TRAJ_DIFF_SELECTION_PLOT;
displayParams.trajDiff_min=TRAJ_DIFF_MIN_PLOT;
displayParams.trajDiff_max=TRAJ_DIFF_MAX_PLOT;

displayParams.trajDuration_selection=TRAJ_DURATION_SELECTION_PLOT;
displayParams.trajDuration_min=TRAJ_DURATION_MIN_PLOT;
displayParams.trajDuration_max=TRAJ_DURATION_MAX_PLOT;

setappdata(gcbf,'displayParams',displayParams);

displayParams
visualize_patch_trackingClassificationDynamic_v210721(displayParams,TRACKING_METHOD);

end

% % % %% function pTC_Tools_C1_Param1_editText_Callback(source,eventdata)
% % % % Get the value of STATUS_PLOT
% % % function pTC_Tools_C1_Param1_editText_Callback(source,eventdata)
% % % str=get(source,'String');
% % % %val=get(source,'value');
% % % disp('pTC_Tools_C1_Param1_editText_Callback');
% % % disp(str);
% % % setappdata(gcbf,'STATUS_PLOT',str2num(str));
% % % end


%% function pTC_Tools_C1_Param2_editText_Callback(source,eventdata)
% Get the value of CELL_ID_PLOT
function pTC_Tools_C1_Param2_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');
setappdata(gcbf,'CELL_ID_PLOT',str2num(str));

end


%% function pTC_Tools_C2_Param1_editText_Callback(source,eventdata)
% Get the value of TRAJ_DURATION_SELECTION_PLOT
function pTC_Tools_C2_Param1_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'TRAJ_DURATION_SELECTION_PLOT',str2num(str));
end


%% function pTC_Tools_C2_Param2_editText_Callback(source,eventdata)
% Get the value of TRAJ_DURATION_MAX_PLOT
function pTC_Tools_C2_Param2_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'TRAJ_DURATION_MAX_PLOT',str2num(str));

end


%% function pTC_Tools_C2_Param3_editText_Callback(source,eventdata)
% Get the value of TRAJ_DURATION_MIN_PLOT
function pTC_Tools_C2_Param3_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'TRAJ_DURATION_MIN_PLOT',str2num(str));

end

%% function pTC_Tools_C3_Param1_editText_Callback(source,eventdata)
% Get the value of TRAJ_SPEED_SELECTION_PLOT
function pTC_Tools_C3_Param1_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'TRAJ_SPEED_SELECTION_PLOT',str2num(str));
end


%% function pTC_Tools_C3_Param2_editText_Callback(source,eventdata)
% Get the value of TRAJ_SPEED_MAX_PLOT
function pTC_Tools_C3_Param2_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'TRAJ_SPEED_MAX_PLOT',str2num(str));

end


%% function pTC_Tools_C3_Param3_editText_Callback(source,eventdata)
% Get the value of TRAJ_SPEED_MIN_PLOT
function pTC_Tools_C3_Param3_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'TRAJ_SPEED_MIN_PLOT',str2num(str));

end

% % % %% function pTC_Tools_C4_Param1_editText_Callback(source,eventdata)
% % % % Get the value of TRAJ_DIFF_SELECTION_PLOT
% % % function pTC_Tools_C4_Param1_editText_Callback(source,eventdata)
% % % str=get(source,'String');
% % % %val=get(source,'value');
% % % 
% % % setappdata(gcbf,'TRAJ_DIFF_SELECTION_PLOT',str2num(str));
% % % end


%% function pTC_Tools_C4_Param2_editText_Callback(source,eventdata)
% Get the value of TRAJ_DIFF_MAX_PLOT
function pTC_Tools_C4_Param2_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'TRAJ_DIFF_MAX_PLOT',str2num(str));

end


%% function pTC_Tools_C4_Param3_editText_Callback(source,eventdata)
% Get the value of TRAJ_DIFF_MIN_PLOT
function pTC_Tools_C4_Param3_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'TRAJ_DIFF_MIN_PLOT',str2num(str));
end