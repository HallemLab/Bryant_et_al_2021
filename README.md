# Bryant et al 2021 Code/Data Repository
Code and other files used in the Bryant *et al* 2021 manuscript, "Neural basis of temperature-driven host seeking in a human-parasitic nematode.""  

## Code
Custom code for data acquisition and analysis. Folder includes the following subfolders:   

- **Calcium Imaging Preprocessing and Analysis Code:** Used to align raw fluorescence values and temperature reads, plot traces, and quantify specific parameters related to calcium imaging.
- **Plotting in R:** Code written in R that generates various plots shown in Bryant *et al* 2021b manuscript.
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

- **Calcium Imaging:** includes CVS files with CFP/YFP intensity values at soma and background regions of interest. Generated using Zeiss Zen scripts. Also includes .dat files with collated temperature recordings generated by ATEC302 software.
- **Worm Tracking:** contains .xlsx files with raw data for worm tracking experiments (including: Ss-tax-4, Sr-gcy-23.2p::strHisCl1, reversal behaviors, and example positive thermotaxis). See internal readme file for more information.
