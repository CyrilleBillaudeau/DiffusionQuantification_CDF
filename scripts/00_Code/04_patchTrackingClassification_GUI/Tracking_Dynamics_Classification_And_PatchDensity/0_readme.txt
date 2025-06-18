Date: 190509
Title: To-do-list

Release version: 190403

Bugs when using display track using selected classification:
Folder Data: /home/cyrille/Share/Share_proced/microscopy/NIKON/Arnaud/2019-05-03 rodA LytE depletion GFPMreB/RodA/
Input Data: CcBs630-0,05iptg_GT80 40%_100ms_0,5s_1min 1.tif

Error display just after using in Command window:
----------------
Output argument "tab_cellID_convert" (and maybe others) not assigned during call to "getCellMask_Specifications".

Error in visualize_patch_trackingClassificationDynamic_v190403 (line 44)
    [cellMask,nCell,cellDescription,tab_cellID_convert]=getCellMask_Specifications(imgFilename);

Error in patchTrackingClassification_GUI>check_patch_trackingClassificationDynamic_pushbutton_Callback (line 434)
visualize_patch_trackingClassificationDynamic_v190403(displayParams);
 
Error while evaluating UIControl Callback
----------------
