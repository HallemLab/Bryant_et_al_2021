# TT Tracker v4 README
created by Astra S. Bryant
Feb. 21, 2020

This is the introduction file to the Thermotaxis Worm Tracker v4 Matlab codebase. Overall, the codebase analyzes and plots the tracks of worm migrating in the Hallem Lab Thermotaxis Rig (Bryant et al 2018). In order to function properly, the code requires a specifically formatted excel spreadsheet containing tracking data. The code can handle 4 different assay types: Pure Thermotaxis, Thermotaxis + Odor, Isothermal Odor, and Pure Isothermal. 

See below for specifics. 

Note: this code assumes that the frame rate of the video tracking is 1 frame/second. 

## Generating Worm Tracks:
For a detailed protocol, please read “Thermotaxis Worm Tracking Posthoc Processing” file.

## Dual Camera Alignment:
There are hardwired parameters for aligning tracks across two cameras placed in an east/west configuration across the x-axis of the assay field of view. If cameras or arena position have been adjusted, these parameters should be re-calculated using a printed version of the “Thermotaxis Arena Alignment Image.pdf” file. The X/Y coordinates (in cm) of two positions (Location 1, Location 2) from each camera should be added as a case in TT_AssayParams_vX.m, under a unique case handle (the “Collection Epoch”). I recommend using positions 2D and 8D - make sure both are visible on each camera and use the Measure function in ImageJ/FIJI to determine the centroid of the circle. The northern most position should be designated Location 1; the southern most position is Location 2. If the experimental images were X/Y translated by ImageJ/FIJI during tracking, the coordinates will need to be adjusted accordingly.

## For all assay types:
Inputs to the worm tracker come in the form of an excel spreadsheet containing an Index tab, and individual tabs containing the output of the ImageJ/FIJI Manual Tracking plugin, for each worm track on each camera. 

For tabs containing worm tracks: each tab should be named with the worms Unique ID (often the UID of the experiment followed by a numerical designation matching the Cell Counter track number from ImageJ/FIJI, followed by “_CL” or “_CR” to designate which camera the track was collected from. If a worm was only tracked on a single camera (e.g. _CL), the user does not have to generate a blank tab for the non-used camera (e.g. _CR). The results of the tracking plugin should be pasted into the tab such that the two columns that have the values -1 in row 1 are located in Excel columns F and G, and the final column is located in Excel column H. This will ensure that the X/Y coordinates (in pixels) are located in Excel columns D and E, and the frame information is located in Excel column C. 

Required elements on the Index tab (which must be named Index) are as follows:
Cell A2: number of worms to track. Should be <= number of UIDs
Cell A5: number of images per track.
Cell A8: Identity of the camera on which worms started the experiment. Either ‘L’ or ‘R’.
Cells B2:down: The worms’ Unique IDs. These much match exactly the names of the tabs, excluding the “_CL” or “_CR” endings. These values are used by Matlab to identify which tabs contain data for importing. 
Cells F2:down: The pixels per cm value for the Left Camera.
Cells G2:down: The pixels per cm value for the Right Camera.
Cells H2:down: Unique string designation that informs matlab which camera alignment parameters to use. Should match a unique “Collection Epoch” name included as a case in TT_AssayParas_vX.m

## For Pure Thermotaxis assays
Cells C2:down: The cm per degrees C value - aka the steepness of the gradient.
Cells D2:down: T(start) aka the temperature at which the worms were placed at the start of the experiment.
Cells E2:down: An integer indicating which experimental run the worm was collected from. E.g. 1 for all worms from Experiment 1; 2 for all worms from Experiment 2, etc…

## For Thermotaxis + Odor assays
Note: this may include both Thermotaxis + Odor assays *and* their matching controls.
Cell A11: Identity of the camera on which the odor is located. Either ‘L’ or ‘R’.
Cell A14: Shape of the odor scoring region. Either C or S (circle, square-ish).
Cells C2:down: The cm per degrees C value - aka the steepness of the gradient.
Cells D2:down: T(odor) aka the temperature at which the odor is placed.
Cells I2:down: X-coordinates of the center of the odor (in cm).
Cells J2:down: Y-coordinates of the center of the odor (in cm).

## For Isothermal Odor assays
Cell A11: Identity of the camera on which the odor is located. Either ‘L’ or ‘R’.
Cell A14: Shape of the odor scoring region. Either C or S (circle, square-ish).
Cells I2:down: X-coordinates of the center of the odor (in cm).
Cells J2:down: Y-coordinates of the center of the odor (in cm).

## For Pure Isothermal assays
Cells E2:down: An integer indicating which experimental run the worm was collected from. E.g. 1 for all worms from Experiment 1; 2 for all worms from Experiment 2, etc…

## Inputs into TT_AssayParams_vX.m
This function collects parameter variables that are specific for the different types of assays. Importantly, this is where the radius of the odor scoring region is defined. 
Also contains the X/Y coordinates (in cm) of two positions (Location 1, Location 2) from each camera, under a unique case handle.

