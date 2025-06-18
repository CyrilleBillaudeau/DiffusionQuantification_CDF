//=============================================================================
// 01_segmentCell_BF_FL.ijm
//=============================================================================
/**
 * Segment bacteria from filament chains into single cells based on 
 * brightfield (BF) and time-lapse TIRF (Fluo) images. A dialogue box will ask 
 * for the location of the TL images and will automatically find the BF images 
 * in the same folder (provided the BF filename remains similar, 
 * e.g. by swapping "TIRF" for "BF"), or a dialogue box will open to ask 
 * for the location of the BF image.
 *  
 * Cells are segmented using a classical approach with two different pipelines:
 * 1: Background subtraction and automatic intensity thresholding;
 * 2: Laplacian of Gaussian (LoG) filtering, background subtraction and user-defined 
 * intensity thresholding. An extra step can be performed to identify 
 * cell septa on a high-quality BF image.
 * 
 * Small ROIs are filtered out of the mask. The user is then prompted to perform 
 * a manual operation to keep only the correct chain of cells and separate them 
 * at the septa position.
 * 
 * The resulting images are saved in the 01_segmentCell_BF_FL folder.
 *  
 * input: BF.czi + FL_TL.czi  (same folder)
 * outputs: FL_TL_msk.txt and FL_TL_infoLog.txt
 * requirements: morpholibJ
 * 
 * version: 1.4
 * date: 250618
 * author: Cyrille Billaudeau
 * institute: ProCeD - MICALIS - INRAE
 */

// Parameters:
classicSeg=false;

// Load data 
run("Close All");
pathImgSeq=File.openDialog("Select TIRF time-lapse");
print(pathImgSeq);

pathImg=replace(pathImgSeq,"TIRF","BF");
if (!File.exists(pathImg) || (indexOf(pathImg, "BF")==-1))  {
	print("File not found: "+pathImg);	
	pathImg=File.openDialog("Select correponding Brigh-field");
}
print(pathImg);

run("Bio-Formats Importer", "open=["+pathImg+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
imgBF=getInfo("image.filename");
img_path=getInfo("image.directory");
rename("Mask");

run("Bio-Formats Importer", "open=["+pathImgSeq+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
imgFL=getInfo("image.filename");
rename("Fluo");

// Prepare output directory for saving results
out_path=img_path+File.separator+"01_segmentCell_BF_FL";
if (!File.exists(out_path)) {
	File.makeDirectory(out_path);	
	print("Folder created");
}

// Cell segmentation
selectImage("Mask");
run("Duplicate...", "title=BF");


selectImage("Mask");
if (classicSeg) {
	run("Subtract Background...", "rolling=10 light");
	setAutoThreshold("Default no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");	
} else {
	run("FeatureJ Laplacian", "compute smoothing=5");
	run("Subtract Background...", "rolling=20");
	run("Threshold...");	
	setAutoThreshold("Otsu dark no-reset");
	waitForUser("Check Thld");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	selectImage("Mask");
	close();
	selectImage("Mask Laplacian");
	rename("Mask");	
}

doSegEdges=getBoolean("Segment edges?", "Yes", "No");
if (doSegEdges) {
	selectImage("BF");
	run("FeatureJ Laplacian", "compute smoothing=1.5");
	setAutoThreshold("Default no-reset");
	waitForUser("Set Thld for edges");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	imageCalculator("Subtract", "Mask","BF Laplacian");
}

// Fluo_SubMin: stack projection to help user in next steps during manual editing of the mask 
selectImage("Fluo");
run("Z Project...", "projection=[Min Intensity]");
run("Median...", "radius=10");
imageCalculator("Subtract create stack", "Fluo","MIN_Fluo");
close("MIN_Fluo");
selectImage("Result of Fluo");
rename("Fluo_subMin");
//run("Z Project...", "projection=[Max Intensity]");
run("Z Project...", "projection=[Average Intensity]");

// Get ROI area in the current mask
selectImage("Mask");
run("Set Measurements...", "area redirect=None decimal=3");
selectImage("Mask");
run("Select None");
run("Analyze Particles...", "display clear add");
roiManager("Show None");

// Filter out smaller ROI in the ncurrent mask
selectImage("Mask");
nROI=roiManager("count");
for (iROI=0;iROI<nROI;iROI++) {
	curArea=getResult("Area", iROI);
	if (curArea<0.5) {
		roiManager("select", iROI);
		run("Multiply...", "value=0");
		run("Select None");		
	}
}
close("Fluo");

//run("Tile");

// Get all ROIs after removing small ones
selectImage("Mask");
run("Select None");

run("Analyze Particles...", "clear add");
selectImage("Mask");
roiManager("Show None");
roiManager("Show All");

setForegroundColor(0, 0, 0);
setBackgroundColor(255, 255, 255);

// Loop over all ROIs to edit manually the mask (modify, creation, deletion)
nROI=roiManager("count");
for (iROI=0;iROI<nROI;iROI++) {
	selectImage("BF");
	roiManager("select", iROI);
	run("To Selection");	
	run("Out [-]");
	run("Out [-]");

	selectImage("Mask");
	roiManager("select", iROI);
	run("To Selection");	
	run("Out [-]");
	run("Out [-]");
	setTool("line");
	msgWait="Correct mask of needed - "+d2s(iROI,0)+"/"+d2s(nROI,0);
	waitForUser(msgWait);
}

selectImage("Mask");
roiManager("reset");
run("Original Scale");
run("Fill Holes");

// Last chance to edit manually the mask (if something has been missed before)
setTool("line");
waitForUser("Last step to correct mask if needed");

// Generate final mask with different cell ID (integer value) for each cells
selectWindow("Mask");
run("Select None");
run("Connected Components Labeling", "connectivity=8 type=[16 bits]");
run("Set Label Map", "colormap=[Main Colors] background=Black shuffle");

selectWindow("Mask");
close();
selectWindow("Mask-lbl");

// Save mask in output folder 
imgfilename_mask=substring(imgFL, 0, lastIndexOf(imgFL, "."))+"_msk.txt";
rename(imgfilename_mask);
out_path_mask=out_path+File.separator+imgfilename_mask;
saveAs("Text Image", out_path_mask);

// Save path of input data (TL, BF and mask) in a text file ("*_infoLog.txt") used in next step of the workflow
print("\\Clear");
print(pathImgSeq);
print(pathImg);
print(out_path_mask);
out_path_infoLog=replace(out_path_mask, "msk.txt", "infoLog.txt");
selectWindow("Log");
saveAs("Text", out_path_infoLog);