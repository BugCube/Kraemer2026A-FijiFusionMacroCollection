// Fiji Macro by Franziska Krämer and Dr. Frederic Strobl
// (3.2) of the FijiFusionMacroCollection
// Associated with the Krämer et al. 2026A Data Descriptor Study
// Macro Version 1.1 - Tested with ImageJ 1.54p
// -------------------------------------------------------------
//
// Purpose:
// Batch-process all z stacks in a selected input folder to set the
// image origin (0,0,0) to the left-top-front voxel
// and convert the image type to 16 bit.
//
// Workflow:
// - The user selects an input folder containing multi-page TIFF stacks.
//   >>> In the associated study, this corresponded to folder P5.
// - The macro creates a subfolder within the input folder: "SetOrigin"
// - For each stack, the macro sets the coordinate origin to (0,0,0)
//   and converts the image type to 16 bit.
// - For each stack, the macro saves:
//     <filename>.tif in the "SetOrigin" subfolder (file name unchanged)
// - After manual quality control, the original files have to be manually
//   replaced by the files in the subfolder via cut & paste.  
//
// Parameters:
// - This macro is universal and does not require user-defined processing parameters.
//
// Notes:
// - Processing is performed in pixel units. No physical calibration is applied.
// - The macro processes only files ending in .tif or .TIF.
// - This macro is intended for single-channel stacks.

setBatchMode(true);

// Ask the user to select the input directory.
// Output will be written to a subfolder within this directory.
inputDir = getDirectory("Choose the Input Directory");
outputDir = inputDir + "/SetOrigin/";
File.makeDirectory(outputDir);

// Get a list of all files in the input directory.
list = getFileList(inputDir);

// Loop over all files in the input folder.
for (i = 0; i < list.length; i++) {

	// Process only TIFF files with extension .tif or .TIF.
	if (endsWith(list[i], "TIF") || endsWith(list[i], "tif")) {
		print(list[i]);
		open(inputDir + list[i]);

		// Store the file name without extension for output naming.
		fName = File.nameWithoutExtension;
		print(fName);

		// Read stack dimensions and store the number of z-slices.
		Stack.getDimensions(imageWidth, imageHeight, numChannels, numSlices, frames);
		s = numSlices;

		// Set image properties.
		run("Properties...", "channels=1 slices=" + s + " frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1 origin=0,0,0");

		// Convert the image to 16 bit.
		run("16-bit");
		
		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");

		// Save the modified stack with unchanged file name.
		saveAs("Tiff", outputDir + fName + ".tif");

		// Close all remaining open images before processing the next file.
		while (nImages > 0) {
			selectImage(nImages);
			close();
		}
	}
}