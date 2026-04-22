# FijiFusionMacroCollection

### FijiFusionMacroCollection by Franziska Krämer and Dr. Frederic Strobl  
### Associated with the Krämer *et al.* 2026A Data Descriptor Study  
### Version 1.1 – Tested with ImageJ 1.54p  

---

## 1) Purpose

The FijiFusionMacroCollection comprises nine ImageJ/Fiji macros written in the ImageJ Macro language that provide a streamlined workflow for the registration and fusion of 3D image data acquired along multiple imaging directions.

The macros support (i) preparation of raw image data for multi-view fusion (macros 1–2), e.g. by using the Multi-View Fusion plugin [1], and (ii) post-processing of fused 3D images to a publication-ready state (macros 3–8). The macros are numbered in order of application. The file names indicate the corresponding input and output folders, as well as whether parameter input is required.

[1] https://imagej.net/imagej-wiki-static/Multi-View_Fusion

---

## 2) Starting Material and Scope

The proposed workflow requires at least two raw z-stacks (multi-page TIFF files) acquired along different directions of the same specimen (or imaging volume), including spatially identifiable landmarks (e.g. fluorescent microspheres). The workflow is compatible with time-series data and is primarily designed for single-channel acquisitions. Multi-channel datasets can be processed sequentially or with minor adaptations to the code.

---

## 3) Workflow Walkthrough

### A)
Download the FijiFusionMacroCollection, including the ProcessingFolderTemplate, from the Git repository. Copy the raw z stacks into the P1 folder. Rename the files as needed [the only hard requirement is that directions and time points follow a logical pattern]. Please note that the ProcessingFolderTemplate also contains folders for the basic (i.e. non-fusion) processing branch (B).

### B)
Use the `(1)-(P1-P2)-YZMaximumProjections-V1.1-Parameters.ijm` macro on P1 (input) and P2 (output) to calculate z and y maximum projections of the raw z stacks.

### C)
Manually concatenate the z and y maximum projections in the P2 subfolders into time (t) stacks and store them in the P2 folder, then delete the subfolders (optional, but recommended). Use the z projections for manual imaging quality control [drift, bleaching, other issues] and the y projections to estimate the mutual x–z quadratic footprints of all z stacks in the multi-view acquisition.

### D)
Use the `(2)-(P1-P3)-QCropAndBOut-V1.1-Parameters.ijm` macro on P1 (input) and P3 (output) to generate cropped z stacks with a mutual x–z quadratic footprint and (optionally) corresponding stacks with a defined region blacked out.

### E)
Use the Bead-Based Registration function of the Multi-View Fusion plugin  
*(Plugins → SPIM Registration → Bead-Based Registration)*  
on either the QCrop (if the specimen is not expected to cause registration issues) or the BOut (if it is) subfolder within the P3 folder (input). Store the fusion metadata in the B0 folder.

### F)
Use the Multi-View Fusion and/or Multi-View Deconvolution function of the Multi-View Fusion plugin  
*(Plugins → SPIM Registration → Multi-View Fusion or Multi-View Deconvolution)*  
on the QCrop subfolder within the P3 folder (input). Store weighted-average raw fused 3D images in the P4 folder and/or fusion-deconvolution raw fused 3D images in the P5 folder.

### G)
To set the image origin (0,0,0) to the left-top-front voxel, use the  
`(3.1)-(P4-Sub)-SetOrigin-V1.1-Universal.ijm` macro on P4 (input) for weighted-average fused images, and/or the  
`(3.2)-(P5-Sub)-SetOriginAnd16BitConversion-V1.1-Universal.ijm` macro on P5 (input) for fusion-deconvolution images.  
After manual quality control, replace the original files with the files in the subfolder via cut & paste, then delete the subfolders.

### H)
Use the `(4)-(P4-F1_P5-D1)-AxisAlignmentAndCrop-V1.1-Parameters.ijm` macro on P4 and/or P5 (input) and F1 and/or D1 (output) to rotate the fused 3D images around all three spatial axes and crop them to appropriate sizes.

### I)
Use the `(5)-(F1-F1_D1-D1)-OneToFourDirections-V1.1-Universal.ijm` on F1 and/or D1 (input) to generate corresponding stacks along four orientations spaced 90° apart.

### J)
Use the `(6)-(F1-F2_D1-D2)-YZGradientProjections-V1.1-ParametersDefault.ijm` macro on F1 and/or D1 (input) and F2 and/or D2 (output) to calculate z and y gradient projections for each stack.

### K)
Manually concatenate the z and y gradient projections in the subfolders of F2 and/or D2 into t-stacks and store them in the F2 and/or D2 folders, then delete the subfolders (optional, but recommended). Use the z projections to estimate suitable minimum and maximum intensity values for brightness and contrast adjustment.

### L)
Manually concatenate the axis-aligned and cropped 3D images into t–z hyperstacks  
*(Image → Hyperstacks → Stack to Hyperstack)*, perform histogram correction  
*(Image → Adjust → Bleach Correction → Histogram Matching)*, and save the corrected 3D images separately in the HCorr subfolders of F3 and/or D3  
*(Plugins → BioFormats → BioFormats Exporter)*.

### M)
Use the `(7)-(F3HCorr-F3_D3HCorr-D3)-BrightnessContrastAdjustment-V1.1-Parameters.ijm` macro on the HCorr subfolders of F3 and/or D3 (input) and F3 and/or D3 (output) to adjust brightness + contrast.

### N)
Apply 3D masks along the x and z axes to remove background artifacts (optional).

### O)
Use the `(8)-(F3-F4_D3-D4)-YZGradientProjections-V1.1-ParametersDefault.ijm` macro on F3 and/or D3 (input) and F4 and/or D4 (output) to calculate z and y gradient projections for each stack.

### P)
Manually concatenate the z and y gradient projections in the subfolders of F4 and/or D4 into t stacks and store them in the F4 and/or D4 folders, then delete the subfolders (optional, but recommended).

### Q)
Manually combine the t stacks into horizontal and vertical t stack montages and store them in the F5 and/or D5 folders (optional, but recommended).

### R)
Delete intermediate files as desired, then compress all files using either TIFF-intrinsic compression or by zipping some or all folders (optional, but recommended). Rename files and sort into custom subfolders as needed.
