# Bryant et al 2021 Code/Data Repository
Data, code, and hardware specs associated with the Bryant *et al* 2021 manuscript, "Neural basis of temperature-driven host seeking in the human threadworm *Strongyloides stercoralis*." Includes files related to the version in BioRxiv, as well as submissions to peer-reviewed journals. (The BioRxiv version can be accessed at this link.)[https://www.biorxiv.org/content/10.1101/2021.06.23.449647v1]

## Code
Custom code for data acquisition and analysis. Folder includes the following subfolders:   

- **Calcium Imaging Preprocessing and Analysis:** Used to align raw fluorescence values and temperature reads, plot traces, and quantify specific parameters related to calcium imaging.
- **Plotting in R:** Code written in R that generates various plots shown in the manuscript.
- **Thermotaxis Worm Tracker v3:** Matlab codebase for worm tracking using the thermotaxis area (version 3).
- **Thermotaxis Worm Tracker v4:** Matlab codebase for worm tracking using the thermotaxis area (version 4).
- **Worm Tracking Camera Controls:** Matlab functions for generating TTL pulse sequences via a Labjack USB DAQ device.
- **Worm Tracking Preprocessing:** FIJI/ImageJ Scripts for post hoc processing of worm tracking image sequences.
- **Zeiss Zen Scripts:** Scripts for aligning CFP/YFP signals following calcium imaging.

## Hardware
Includes parts lists and wiring diagrams for custom behavioral and imaging setups. Folder includes the following subfolders:  

- **Large Format Thermotaxis Arena:** diagrams/parts lists/wiring diagrams related to the large format thermotaxis assay arena.
- **Thermal Stimulator:** parts lists for custom thermal stimulator, 3D printing a custom stage clamp, and Zeiss Zen scripts for preprocessing/aligning CFP/YFP raw acquisition data. 

## Data
Includes data files containing raw data as well as processed/quantified data. Folder includes the following subfolders: 

- **Calcium Imaging:** includes CVS files with CFP/YFP intensity values at soma and background regions of interest. Generated using Zeiss Zen scripts. Also includes .dat files with collated temperature recordings generated by ATEC302 software. Also includes Matlab .mat objects containing preprocessed and aligned imaging and temperature data. 
- **Worm Tracking:** contains .xlsx files with raw data for worm tracking experiments (including: Ss-tax-4, Sr-gcy-23.2p::strHisCl1, reversal behaviors, and example positive thermotaxis). See internal readme file for more information.

## Supplemental Data Files
Contains supplemental data files for BioRxiv-submitted manuscript version.

- **Supplemental Data File 1:** This file includes the results of statistical tests and exact p values, as well as the data used for statistical analyses. 

- **Supplemental Data File 2:** This file includes all primers, plasmids, worm strains, and thermal ramps used in this study. 

## License
Shield: [![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg
