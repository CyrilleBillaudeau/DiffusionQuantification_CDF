%% Add all script in matlab path 
scriptPath = matlab.desktop.editor.getActiveFilename;
folderLibMTL=scriptPath(1:max(strfind(scriptPath, filesep)))
addpath(genpath(folderLibMTL));

%% 1 - Generate all required files to perform MSD analysis
clear all
lstXML=uipickfiles('Prompt','Select tracks exported with Trackmate','REFilter','Tracks.xml'); 
nFile=numel(lstXML);

% Copy msk & img
for iFile=1:nFile
    xml_path=lstXML{iFile};
    xml_path_split=strsplit(xml_path,'Tracks.xml');
    frame_avg=xml_path_split{1};frame_avg=frame_avg(strfind(frame_avg,'_avg')+4:end);
    
    msk_path=replace(xml_path,'03_runTM_withMaskROI','01_segmentCell_BF_FL');
    msk_path=replace(msk_path,'\outputTrackmate\','\');    
    msk_path=replace(msk_path,strcat('_subMin_avg',frame_avg,'Tracks.xml'),'_msk.txt');
    
    dest_msk_path=replace(msk_path,'01_segmentCell_BF_FL','04_patchTrackingClassification_GUI');    
    dest_msk_path=replace(dest_msk_path,'_msk.txt',strcat('_subMin_avg',replace(frame_avg,'_',''),'.txt'));

    % Mask that have been corrected ('DC') will be used then after in the
    % analysis
    if (exist(replace(msk_path,'_msk.txt','_msk_DC.txt'))==2)
        msk_path=replace(msk_path,'_msk.txt','_msk_DC.txt')
    end

    %copyfile(msk_path,dest_msk_path)
    dest_msk_folder=dest_msk_path(1:max(strfind(dest_msk_path,filesep)));
    if (exist(dest_msk_folder)~=7)
        mkdir(dest_msk_folder)
    end
    copyfile(msk_path,dest_msk_path);
    
    %template_img_path=strsplit(xml_path,'04_Pipeline');template_img_path=template_img_path{1};
    template_img_path=strsplit(xml_path,'03_runTM_withMaskROI');template_img_path=template_img_path{1};
    template_img_path=fullfile(template_img_path,'00_Code','04_patchTrackingClassification_GUI','img.tif');
    
    dest_img_path=replace(dest_msk_path,'.txt','.tif');
    copyfile(template_img_path,dest_img_path);
end%for
disp('Copy msk & img: done!')

% Copy xml
for iFile=1:nFile
    xml_path=lstXML{iFile};
    
    dest_xml_path=replace(xml_path,'03_runTM_withMaskROI','04_patchTrackingClassification_GUI');
    dest_xml_folder=dest_xml_path(1:max(strfind(dest_xml_path,filesep)));
    
    if (exist(dest_xml_folder)~=7)
        mkdir(dest_xml_folder)
    end
    copyfile(xml_path,dest_xml_path);    
end
disp('Copy xml: done!')

% Copy the 'spec.txt' file from the template folder '00_Code/04_patchTrackingClassification_GUI' 
% containing the image specifications for the time-lapse. This file contains 
% three lines corresponding to the parameters used in the MSD analysis: 
% - the total number of frames in the stack; 
% - the interval between images; 
% - the pixel size in microns.
% Edit the final spec file if any of the corresponding acquisitions have different parameters.
for iFile=1:nFile
    xml_path=lstXML{iFile};

    template_spec_path=strsplit(xml_path,'03_runTM_withMaskROI');template_spec_path=template_spec_path{1};
    template_spec_path=fullfile(template_spec_path,'00_Code','04_patchTrackingClassification_GUI','spec.txt');
    
    desp_spec_path=replace(xml_path,'\outputTrackmate\','\');
    desp_spec_path=replace(desp_spec_path,'03_runTM_withMaskROI','04_patchTrackingClassification_GUI');
    desp_spec_path=replace(desp_spec_path,'_Tracks.xml','_spec.txt');
    
    copyfile(template_spec_path,desp_spec_path);    

end
disp('Copy spec: done!')

%% 2 - Run MSD analysis:
patchTrackingClassification_GUI