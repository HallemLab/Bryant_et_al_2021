//User Inputs
call("java.lang.System.gc");
Folderpath="Dana/DanaS" // Path to data folder that contains subfolders with all the images for a single experimental run
UID="200114_01" // Name of subfolder containing all the images for a single experimental run (e.g. a single worm). Best practice: this folder is a unique ID corresponding to the experiment/worm

// Which Camera do you want to process images from? 0 = no, 1 = yes
	runCamR="1"
	runCamL="1"

// How many frames should be used for background subtraction?
	BackgroundWindowStart="0"
	BackgroundWindowStop="600"

// How many images do you want to process? (This should probably match the total number of images in your experiment, but it doesn't have it.)
	NumImages="600" //number of images to import

// Set the pixels per cm camera scales. You should keep track of this number in your notes. Calculate the number by taking a photo of a ruler using the two cameras, then measuring the pixels in a 1 cm distance in FIJI. 
	// Post August 2019 settings:
	CamRScale="235" //pixels per cm, Camera R
	CamLScale="231" //pixels per cm, Camera L

	// Post Feb 12 2020 settings:
	CamRScale="214" //pixels per cm, Camera R
	CamLScale="202" //pixels per cm, Camera L

	// Pre August 2019 settings:
	//CamRScale="209" //pixels per cm, Camera R
	//CamLScale="179" //pixels per cm, Camera L

// What size of grid should be drawn? This is determined by the Calculator tab in the Thermotaxis Worksheets Excel file. You should keep track of this number in your notes
	GridSize="100000" // If set to 100000 this is an arbitrarily large number that ensures grid lines won't be visible for worm tracking where a grid isn't necessary.

// Set the distance in pixels to shift the cameras to align the grid to the edge of the plate. You should keep track of this number in your notes
	TranslateR="0" // distance in pixels to shift Camera R images to align grid to edge of plate 
	TranslateL="0" // distance in pixels to shift Camera L images image to align grid to edge of plate 
	
	// Pre August 2019 settings
	//TranslateR="200" // distance in pixels to shift Camera R images to align grid to edge of plate -100
	//TranslateL="-120" // distance in pixels to shift Camera L images image to align grid to edge of plate -200

setOption("BlackBackground", true);

//Program Generated Variables
	avgfile= "AVG_" + UID
	filepath="/Volumes/" + Folderpath + "/" + UID + "/"

// Process Left Camera Images
call("java.lang.System.gc");
	if (runCamL>0){	
		run("Image Sequence...", "open=["+filepath+ "] number="+NumImages+" file=CamL sort"); //Import Sequences
			call("java.lang.System.gc");
		run("Z Project...", "start="+BackgroundWindowStart+ " stop="+BackgroundWindowStop+" projection=[Average Intensity]"); // Take Average of Image Sequence
			call("java.lang.System.gc");
		imageCalculator("Subtract create stack", UID, avgfile); // Subtract Average from Every Image in Stack
			setBatchMode(true); 
				selectWindow(UID); 
				run("Close");
				selectWindow("AVG_"+UID);
				run("Close"); 
			setBatchMode(false); 
			call("java.lang.System.gc");
			run("Flip Horizontally", "stack");
			run("Flip Vertically", "stack");
			call("java.lang.System.gc");
		run("Enhance Contrast", "saturated=0.4 process_all"); //Readjust Contrast
			call("java.lang.System.gc");
		run("Set Scale...", "distance="+CamLScale+" known=1 unit=cm"); //Set Scale for Images
		run("Grid...", "grid=Lines area="+GridSize+" color=Cyan"); //Draw Grid
			call("java.lang.System.gc");
		run("Translate...", "x="+TranslateL+" y=0 interpolation=None stack"); //If necessary, adjust image so grid aligns to edge of gel
			call("java.lang.System.gc");
		run("Save", "save=[/Volumes/" + Folderpath + "/" + UID + "_CL.tif]"); //Save Image
		close();	
	}

// Process Right Camera Images
call("java.lang.System.gc");
	if (runCamR>0){
		run("Image Sequence...", "open=["+filepath+ "] number="+NumImages+" file=CamR sort");
			call("java.lang.System.gc");
		run("Z Project...", "start="+BackgroundWindowStart+ " stop="+BackgroundWindowStop+" projection=[Average Intensity]");
			call("java.lang.System.gc");
		imageCalculator("Subtract create stack", UID ,avgfile);
				setBatchMode(true); 
					selectWindow(UID); 
					run("Close");
					selectWindow("AVG_"+UID);
					run("Close"); 
				setBatchMode(false);
				call("java.lang.System.gc");
		run("Enhance Contrast", "saturated=0.4 process_all"); //Readjust Contrast
			call("java.lang.System.gc");
		run("Set Scale...", "distance="+CamRScale+" known=1 unit=cm");
		run("Grid...", "grid=Lines area="+GridSize+" color=Cyan");
			call("java.lang.System.gc");
		run("Translate...", "x="+TranslateR+" y=0 interpolation=None stack");
			call("java.lang.System.gc");
		run("Save", "save=[/Volumes/" + Folderpath + "/" + UID + "_CR.tif]");
		close();

	}
call("java.lang.System.gc");
