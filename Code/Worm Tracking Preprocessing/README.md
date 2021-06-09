#Worm Tracking Preprocessing Code
FIJI/ImageJ Scripts for post hoc processing of worm tracking image sequences.

These scripts convert an image sequence of .bmp files collected from a CMOS camera (e.g. Mightex) into a processed .tif file suitable for post hoc manual worm tracking.

Repository includes scripts for a dual camera Thermotaxis Tracking setup. This code assumes a camera configuration where the two cameras tile either  height (N-S config) or width (E-W config) of a thermotaxis plate. This code also assumes data were collected using dark field illumination.

Code written in the ImageJ Macro language (.ijm)