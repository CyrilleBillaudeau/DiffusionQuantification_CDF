function patchTrackingClassification_GUI()

%--------------------------------------------------------------------------
%% function patchTrackingClassification_GUI()
%% HEADER HAS TO BE COMPLETED 

%% ================================================= %%
disp('====================');

%% ================================================= %%
% User interface default colors
colorFgd=[0 0 0];
colorBgd=[204 204 204]/255; %% "Natural" color background
%colorBgd=[1 1 1]; %% White color background
text_size = 0.70;
edit_text_size = 0.20;
width_column_menu=0.20;

% Create and hide the GUI as it is being constructed.
frontpanel = figure('Visible','on','Position',[00,000,1180,708],...
    'Color',colorBgd,'Resize','on',...
    'Name', 'Patch Tracking Classification 1.0 - ProCeD (Micalis/INRA) (Still in Progress)',...  % Title figure
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
LST_FILES='';

displayParams = struct( ...
    'statusPlot',{-2}, ...
    'nRepet',{1}, ...
    'invertedCMAP',{0});

STATUS_PLOT=displayParams.statusPlot;
N_REPET=displayParams.nRepet;
INVERTED_CMAP=displayParams.invertedCMAP;

MESSAGE_TEXT=''; % to print a message in the GUI if necessary (analysis status, filename ...)

setappdata(gcf,'LST_FILES',LST_FILES);
setappdata(gcf,'displayParams',displayParams);
setappdata(gcf,'STATUS_PLOT',STATUS_PLOT);
setappdata(gcf,'N_REPET',N_REPET);
setappdata(gcf,'INVERTED_CMAP',INVERTED_CMAP);
setappdata(gcf,'MESSAGE_TEXT',MESSAGE_TEXT);

%% ================================================= %%
% The command line below defined the spatial structure of the user
% interface. Their related functions are defined at the end of this file.

%% ================================================= %%
%
%                       Panel Menu
%
%% ================================================= %%

%% ================================================= %%
pTCpanel = uipanel('Parent',frontpanel,'Title','Main Menu',...
    'Position',[.03 .50 .96 .50],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

%% ================================================= %%
FileLst_pushbutton=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','1-Input data','HorizontalAlignment','left', ...
    'Units','normalized','Position',[0.03,0.85,width_column_menu,0.10],...
    'TooltipString', 'Define list of files to be processed',...
    'Callback',{@FileLst_pushbutton_Callback});

%% ================================================= %%
CheckFileList_pushbutton=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','2-Data checking',...
    'Units','normalized','Position',[0.03,0.73,width_column_menu,0.10],...
    'TooltipString', 'Check if required data exist and spec file correctly defined before MSD analysis',...
    'Callback',{@CheckFileList_pushbutton_Callback});

%% ================================================= %%
run_patch_trackingClassificationDynamic_pushbutton=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','3-Dynamic classification (MSD)',...
    'Units','normalized','Position',[0.03,0.61,width_column_menu,0.10],...
    'TooltipString', 'Dynamic classification of patches (based on MSD)',...
    'Callback',{@run_patch_trackingClassificationDynamic_pushbutton_Callback});

%% ================================================= %%
plotCombineCompare_patch_trackingClassificationDynamic_PB=uicontrol('Parent',pTCpanel,'Style','pushbutton',...
    'String','4-Plot & Save',...
    'Units','normalized','Position',[0.03,0.49,width_column_menu,0.10],...
    'TooltipString', 'Combine and plot results of processed data',...
    'Callback',{@plotCombineCompare_pushbutton_Callback});

%% ================================================= %%
pTC_Tools_panel = uipanel('Parent',frontpanel, ...
    'Title','Display',...
    'Position',[.03 .05 .96 .45],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_Param_panel = uipanel('Parent',pTC_Tools_panel,...
    'Title','options',...
    'Position',[0.03 0.20 width_column_menu .8],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_Param1_Text = uicontrol('Parent',pTC_Tools_Param_panel,'Style','text',...
    'String','Status to plot','Visible','on',...
    'Units','normalized','Position',[0.05,0.65,text_size,0.20],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_Param1_editText = uicontrol('Parent',pTC_Tools_Param_panel,'Style','edit',...
    'String',num2str(STATUS_PLOT),'Visible','on',...
    'Units','normalized','Position',[text_size+0.05,0.70,edit_text_size,0.20],...
    'TooltipString', '1 = directed; 2 = diffused; 3 = constrained; 0 = unclassified; -1 = untreated; -2 = all of them',...
    'Callback',{@pTC_Tools_Param1_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_Param2_Text = uicontrol('Parent',pTC_Tools_Param_panel,'Style','text',...
    'String','Nb. of time-lapse repetition','Visible','on',...
    'Units','normalized','Position',[0.05,0.375,text_size,0.20],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_Param2_editText = uicontrol('Parent',pTC_Tools_Param_panel,'Style','edit',...
    'String',num2str(N_REPET),'Visible','on',...
    'Units','normalized','Position',[text_size+0.05,0.40,edit_text_size,0.20],...
    'TooltipString', 'Number of loops when runing time-lapse acquisitions',...
    'Callback',{@pTC_Tools_Param2_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_Param3_Text = uicontrol('Parent',pTC_Tools_Param_panel,'Style','text',...
    'String','Inverted LUT','Visible','on',...
    'Units','normalized','Position',[0.05,0.0,text_size,0.20],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_Param3_editText = uicontrol('Parent',pTC_Tools_Param_panel,'Style','edit',...
    'String',num2str(INVERTED_CMAP),'Visible','on',...
    'Units','normalized','Position',[text_size+0.05,0.05,edit_text_size,0.20],...
    'TooltipString', 'Grey LUT is used for visualization. By default background in black and higher signal in white (INVERTED LUT = 0). If INVERTED LUT is set to 1, then backgroound will be white and higher signal will be black.',...
    'Callback',{@pTC_Tools_Param3_editText_Callback},...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

%% ================================================= %%
check_patch_trackingClassificationDynamic_pushbutton=uicontrol('Parent',pTC_Tools_panel,'Style','pushbutton',...
    'String','Display tracks classification',...
    'Units','normalized','Position',[0.03,0.03,width_column_menu,0.10],...
    'TooltipString', 'Display tracks and its classification (single file)',...
    'Callback',{@check_patch_trackingClassificationDynamic_pushbutton_Callback});

%% ================================================= %%
pTC_Tools_summary_panel = uipanel('Parent',pTC_Tools_panel,...
    'Title','Summary (in progress ...)',...
    'Position',[width_column_menu+0.1 0.03 .69 .95],...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);

pTC_Tools_summary_panel_text1 = uicontrol('Parent',pTC_Tools_summary_panel,'Style','text',...
    'String','---','Visible','on',...
    'Units','normalized','Position',[0.01,0.75,0.18,0.20],...
    'Tag','pTC_Tools_summary_panel_text1',...
    'BackgroundColor',colorBgd,...
    'ForegroundColor',colorFgd);


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
    LST_FILES=uipickfiles('FilterSpec','*.tif');
    setappdata(gcbf,'LST_FILES',LST_FILES);
end

%% function CheckFileList_pushbutton_Callback(hObject, eventdata, handles)
% run the checkNeededData_patch_trackingClassificationDynamic_v190103 
% function to check if all required files exist and in unsual values are
% not present in spec files.
function CheckFileList_pushbutton_Callback(hObject, eventdata, handles)
    LST_FILES=getappdata(gcbf,'LST_FILES');
    [text_error,i_err]=checkNeededData_patch_trackingClassificationDynamic_v190103(LST_FILES);
    if i_err>0
        fprintf('\n\n\n\n\n');
        for i=1:i_err
            disp(strcat(['--------- Error #',num2str(i),'/',num2str(i_err)]));
            disp(text_error{i});
        end%for
    else
        fprintf('\n\n\n');
        disp('no error found');
    end
    
end

%% function run_patch_trackingClassificationDynamic_pushbutton_Callback(hObject, eventdata, handles)
% run the function run_patch_trackingClassificationDynamic_v190103 which
% load cell mask, tracks and spec files to classify automatically each
% tracks (using MSD)
function run_patch_trackingClassificationDynamic_pushbutton_Callback(hObject, eventdata, handles)
LST_FILES=getappdata(gcbf,'LST_FILES');
run_patch_trackingClassificationDynamic_v190103(LST_FILES);
end

%% function plotCombineCompare_pushbutton_Callback(hObject, eventdata, handles)
% run the function
% plotCombineCompare_patch_trackingClassificationDynamic_v190103 to
% generate figures and tables from differents experimental conditions
function plotCombineCompare_pushbutton_Callback(hObject, eventdata, handles)
plotCombineCompare_patch_trackingClassificationDynamic_v190103();
end

%% function check_patch_trackingClassificationDynamic_pushbutton_Callback(hObject, eventdata, handles)
% run the function visualize_patch_trackingClassificationDynamic_v190103 to
% display tracks and their classification superimposed on time-lapse
% movies.
function check_patch_trackingClassificationDynamic_pushbutton_Callback(hObject, eventdata, handles)

STATUS_PLOT=getappdata(gcbf,'STATUS_PLOT');
N_REPET=getappdata(gcbf,'N_REPET');
INVERTED_CMAP=getappdata(gcbf,'INVERTED_CMAP');
displayParams=getappdata(gcbf,'displayParams');

displayParams.statusPlot=STATUS_PLOT;
displayParams.nRepet=N_REPET;
displayParams.invertedCMAP=INVERTED_CMAP;
setappdata(gcbf,'displayParams',displayParams);

%displayParams

visualize_patch_trackingClassificationDynamic_v190103(displayParams);

end


%% function pTC_Tools_Param1_editText_Callback(source,eventdata)
% Get the value of STATUS_PLOT
function pTC_Tools_Param1_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'STATUS_PLOT',str2num(str));
end


%% function pTC_Tools_Param2_editText_Callback(source,eventdata)
% Get the value of N_REPET
function pTC_Tools_Param2_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'N_REPET',str2num(str));

end


%% function pTC_Tools_Param3_editText_Callback(source,eventdata)
% Get the value of INVERTED_CMAP
function pTC_Tools_Param3_editText_Callback(source,eventdata)
str=get(source,'String');
%val=get(source,'value');

setappdata(gcbf,'INVERTED_CMAP',str2num(str));

end