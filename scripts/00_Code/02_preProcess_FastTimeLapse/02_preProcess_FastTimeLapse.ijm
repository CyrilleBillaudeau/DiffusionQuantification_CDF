//=============================================================================
// 02_preProcess_FastTimeLapse.ijm
//=============================================================================
/**
 * TIRF time-lapse images are pre-processed to enhance the signal-to-noise ratio 
 * by subtracting the minimum intensity projection of the stack from all frames 
 * and performing a local averaging process with a sliding window (the size of 
 * which is set in the parameters section).
 * 
 * An optional method has been implemented to correct drift during time 
 * lapse (if needed set skipDC to 'false').
 * 
 * The resulting images are saved in the 02_preProcess_FastTimeLapse folder.
 *  
 * input: FL_TL.czi
 * outputs: FL_TL_subMin_avgX.tif and FL_TL_subMin_avgInfo.txt where X is 
 * the size of the window.
 * 
 * requirements: none
 * 
 * version: 1.1
 * date: 250618
 * author: Cyrille Billaudeau
 * institute: ProCeD - MICALIS - INRAE
 */
 
// Parameters
avgFrame=2;
skipDC=true;

run("Close All");
pathImg=File.openDialog("Select TIRF time-lapse' ");
//open(pathImg);
run("Bio-Formats Importer", "open=["+pathImg+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

imgFilename=getInfo("image.filename");
img_path=getInfo("image.directory");
img_format=substring(imgFilename, lastIndexOf(imgFilename, "."));
print(imgFilename);
//print(img_path);
print(img_format);
rename("orig");


// Prepare output directory for saving results
currentPipeline="02_preProcess_FastTimeLapse";

out_path=img_path+File.separator+currentPipeline;
if (!File.exists(out_path)) {
	File.makeDirectory(out_path);	
	print("Folder created");
}
//print(out_path);

// Drift correction if required
if (!skipDC) {
	waitForUser("Check drift in TL");
	doDriftCorrection=0;
	Dialog.create("Drift?");
	Dialog.addNumber("Correct drift?:", doDriftCorrection);
	Dialog.show();
	doDriftCorrection = Dialog.getNumber();
	
	selectWindow("orig");
	if (doDriftCorrection>0) {
		print("Apply drift correction on TL");
		run("StackReg ", "transformation=[Rigid Body]");	
	}
}

selectWindow("orig");

run("Z Project...", "projection=[Min Intensity]");
run("Median...", "radius=4");
imageCalculator("Subtract create stack", "orig","MIN_orig");

close("MIN_orig");
selectImage("Result of orig");
rename("orig_subMin");

getDimensions(imW, imH, imCh, imS, imF);
//print(imW, imH, imCh, imS, imF);
if (imF<imS) {
		getPixelSize(pixUnit, pixW, pixH);
		lagTime=Stack.getFrameInterval();		
		print(pixUnit, pixW, pixH,lagTime);
		run("Properties...", "channels=1 slices=1 frames="+imS+" pixel_width="+pixW+" pixel_height="+pixH+" voxel_depth=1.0000000 frame=["+lagTime+" sec]");
		getDimensions(imW, imH, imCh, imS, imF);
}

selectWindow("orig_subMin");
getDimensions(imW, imH, imCh, imS, imF);

if (imF<imS) {
		getPixelSize(pixUnit, pixW, pixH);
		lagTime=Stack.getFrameInterval();		
		print(pixUnit, pixW, pixH,lagTime);
		run("Properties...", "channels=1 slices=1 frames="+imS+" pixel_width="+pixW+" pixel_height="+pixH+" voxel_depth=1.0000000 frame=["+lagTime+" sec]");
		getDimensions(imW, imH, imCh, imS, imF);
}

imF_avg=imF-avgFrame;
print(imF_avg,imF,avgFrame);
run("Duplicate...", "title=orig_subMin_avg duplicate range=1-"+imF_avg);
run("Multiply...", "value=0 stack");

setBatchMode(true);

for (iFrame=1;iFrame<=imF_avg;iFrame++) {
	selectWindow("orig_subMin");
	iStop=iFrame+avgFrame;
	run("Z Project...", "start="+iFrame+" stop="+iStop+" projection=[Average Intensity]");
	selectWindow("orig_subMin_avg");
	setSlice(iFrame);
	imageCalculator("Add", "orig_subMin_avg","AVG_orig_subMin");
	selectWindow("AVG_orig_subMin");
	close();	
}
setBatchMode(true);

selectWindow("orig_subMin_avg");
setBatchMode("show");
setSlice(1);
resetMinAndMax;

//Stack.setFrameInterval(lagTime*avgFrame);

// Save processed file in output folder 
endFilename="_subMin_avg"+d2s(avgFrame,0)+".tif";
res_imgFilename=replace(imgFilename,img_format,endFilename);
rename(res_imgFilename);
out_path_resImg=out_path+File.separator+res_imgFilename;
saveAs("Tiff", out_path_resImg);

// Save the filename of the input data (TL) and the size of the sliding window used to average 
// the TL in a text file named "*_subMin_avgInfo.txt" for future use in the next step of the workflow.
print("\\Clear");
print(imgFilename);
print(avgFrame);

endFilename="_subMin_avgInfo.txt";
out_path_infoLog=out_path+File.separator+replace(imgFilename,img_format,endFilename);
selectWindow("Log");
saveAs("Text", out_path_infoLog);