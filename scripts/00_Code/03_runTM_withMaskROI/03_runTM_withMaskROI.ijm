//=============================================================================
// 03_runTM_withMaskROI.ijm
//=============================================================================
/**
 * Run TrackMate analysis on pre-processed TIRF time-lapse images and 
 * by importing ROI of cell mask to reduce tracking analysis on cells only.
 * 
 * The resulting files are saved in 03_runTM_withMaskROI folder.
 *  
 * input: FL_msk.txt (in 01_segmentCell_BF) and FL_TL_subMin_avgX.tif (in 02_preProcess_FastTimeLapse)
 * outputs: FL_TL_subMin_avgX.xml and FL_TL_subMin_avgX_Tracks.xml (in subfolder 'outputTrackmate')
 * requirements: Trackmate
 * 
 * version: 1.1
 * date: 250618
 * author: Cyrille Billaudeau
 * institute: ProCeD - MICALIS - INRAE
 */
 
run("Close All");

// Load data (generated in steps #01 and #02)
pathMsk=File.openDialog("Select Mask Txt in '01_segmentCell_BF_FL' ");
run("Text Image... ", "open=["+pathMsk+"]");

imgMask_filename=substring(pathMsk, 1+lastIndexOf(pathMsk, File.separator));
imgMask_path=substring(pathMsk, 0,lastIndexOf(pathMsk, File.separator));
print(imgMask_path);
print(imgMask_filename);

setThreshold(1.0000, 1000000000000000000000000000000.0000);
run("Analyze Particles...", "clear include add");
roiManager("Show None");
nROI=roiManager("count");
//print(nROI);
if (nROI>1) {
	tabROI=newArray(nROI);
	for (iROI=0;iROI<nROI;iROI++) {
		tabROI[iROI]=iROI;
	}
	roiManager("Select", tabROI);
	roiManager("Combine");	
} else {
	roiManager("Select", 0);	
}

run("Enlarge...", "enlarge=2"); 

stepPipeline_mask="01_segmentCell_BF_FL";
stepPipeline_preProcess="02_preProcess_FastTimeLapse";

img_path=replace(imgMask_path,stepPipeline_mask,stepPipeline_preProcess);
print(img_path);

imgMask_filename=replace(imgMask_filename, "_msk_DC", "_msk");
path_subMin_avgInfo=img_path+File.separator+replace(imgMask_filename,"_msk.txt","_subMin_avgInfo.txt");
filestring=File.openAsString(path_subMin_avgInfo);
rows=split(filestring, "\n");
//Array.show(rows);
avgFrame=rows[1];

img_filename=replace(imgMask_filename,"_msk.txt","_subMin_avg"+d2s(avgFrame,0)+".tif");
print(img_filename);

pathImg=img_path+File.separator+img_filename;
if (File.exists(pathImg)) {
	run("Bio-Formats Importer", "open=["+pathImg+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
} else {
	pathImg=File.openDialog("Select TIRF time-lapse (after processing)");
	run("Bio-Formats Importer", "open=["+pathImg+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
}

// Prepare output directory for saving results
currentPipeline="03_runTM_withMaskROI";
out_path=replace(img_path,stepPipeline_preProcess,currentPipeline);
print(out_path);

if (!File.exists(out_path)) {
	File.makeDirectory(out_path);	
	print("Folder created");
}

out_path=out_path+File.separator+"outputTrackmate";
if (!File.exists(out_path)) {
	File.makeDirectory(out_path);	
	print("Folder created");
}

//print(out_path);

//imgFilename=getInfo("image.filename");
//print(imgFilename);

// Run Trackmate of TL only on cells ROIs
run("Restore Selection");
resetMinAndMax();
run("TrackMate");