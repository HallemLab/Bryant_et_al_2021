//User Inputs
call("java.lang.System.gc");
HD_id="E:/"
UID="190603C"
Species=""

runCamN="1" // logical statement 0= no, 1=yes
runCamS="0" // logical statement 0= no, 1=yes

// Configuration Variables

//GridSize="5.0625"
GridSize="4.183884298"
BackgroundWindowStart="0"
BackgroundWindowStop="300"
NumImages="600" //number of images to import
CamNScale="234" //pixels per cm, Northern Camera
CamSScale="228" //pixels per cm, Southern Camera
TranslateN="100" // distance in pixels to shift Camera R images to align grid to edge of plate -100
TranslateS="0" // distance in pixels to shift Camera L images image to align grid to edge of plate -200
setOption("BlackBackground", true);

//Program Generated Variables
avgfile= "AVG_" + UID
filepath= HD_id + Species + "/" + UID + "/"

// Process Northern Camera Images

if (runCamN>0){
	call("java.lang.System.gc");
	run("Image Sequence...", "open=["+filepath+ "] number="+NumImages+" file=CamN sort"); //Import Sequences
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
	run("Enhance Contrast", "saturated=0.4 process_all"); //Readjust Contrast
	call("java.lang.System.gc");
	run("Rotate 90 Degrees Right");
	call("java.lang.System.gc");
	run("Canvas Size...", "width=2592 height=2592 position=Top-Left");
	call("java.lang.System.gc");
	run("Set Scale...", "distance="+CamNScale+" known=1 unit=cm"); //Set Scale for Images
	run("Grid...", "grid=Lines area="+GridSize+" color=Cyan"); //Draw Grid
	run("Translate...", "x="+TranslateN+" y=0 interpolation=None stack"); //If necessary, adjust image so grid aligns to edge of gel
	call("java.lang.System.gc");
	run("Save", "save=[/" + HD_id + Species + "/" + UID + "_CN.tif]"); //Save Image
	close ();
}


// Process Southern Camera Images
call("java.lang.System.gc");
if (runCamS>0){
	run("Image Sequence...", "open=["+filepath+ "] number="+NumImages+" file=CamS sort");
	run("Z Project...", "start="+BackgroundWindowStart+ " stop="+BackgroundWindowStop+" projection=[Average Intensity]");
	call("java.lang.System.gc");
	imageCalculator("Subtract create stack", UID ,avgfile);
	setBatchMode(true); 
		selectWindow(UID); 
		run("Close");
		selectWindow("AVG_"+UID);
		run("Close"); 
	setBatchMode(false);
	run("Enhance Contrast", "saturated=0.4 process_all");
	run("Set Scale...", "distance="+CamSScale+" known=1 unit=cm");
	run("Grid...", "grid=Lines area="+GridSize+" color=Cyan");
	run("Translate...", "x="+TranslateS+" y=0 interpolation=None stack");
	call("java.lang.System.gc");
	run("Save", "save=[/" + HD_id + Species + "/" + UID + "_CS.tif]");
	close();
}

call("java.lang.System.gc");
run("TIFF Virtual Stack...", "open=[/"+HD_id + Species + "/" + UID + "_CN.tif]");
//run("TIFF Virtual Stack...", "open=[/" + HD_id + Species + "/" + UID + "_CS.tif]");
