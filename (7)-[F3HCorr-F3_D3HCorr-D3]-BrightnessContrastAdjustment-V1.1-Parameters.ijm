// Fiji Macro by Franziska Krämer and Dr. Frederic Strobl
// (7) of the FijiFusionMacroCollection
// Associated with the Krämer et al. 2026A Data Descriptor Study
// Macro Version 1.1 - Tested with ImageJ 1.54p
// -------------------------------------------------------------
//
// Purpose:
// Batch-process all z stacks in a selected input folder to adjust brightness + contrast.
//
// Workflow:
// - The user selects an input folder containing multi-page TIFF stacks.
//   >>> In the associated study, this corresponded to folders F1 and D1.
// - The user selects an output folder.
//   >>> In the associated study, this corresponded to folders F3 and D3.
// - For each stack, the macro applies a user-defined minimum and maximum 
//   intensity range to the full stack.
// - For each stack, the macro saves:
//     <modified_filename>_AdjS).tif in the selected output folder
//
// Parameters:
// - The 'setMinAndMax' minimum and maximum intensity values in the parameter
//   input section should be set manually based on the desired adjustment range.
//   >>> In the associated study, these values were dataset-specific and determined
//   manually in Fiji.
//
// Notes:
// - Processing is performed in pixel units. No physical calibration is applied.
// - The macro processes only files ending in .tif or .TIF.
// - This macro is intended for single-channel stacks.
// - The command "Apply LUT" converts the displayed intensity mapping into
//   pixel values across the full stack.

setBatchMode(true);

// Ask the user to select input and output directories.
inputDir = getDirectory("Choose the Input Directory");
outputDir = getDirectory("Choose the Output Directory");
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

		// --- PARAMETER INPUT SECTION (###) ---
		// Define the minimum and maximum intensity values for stack adjustment.
		setMinAndMax(###, ###);

		// Apply the intensity values to all slices in the stack.
		run("Apply LUT", "stack");

		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");

		// Save the intensity-adjusted stack.
		saveAs("Tiff", outputDir + fName + "_AdjS.tif");

		// Close all remaining open images before processing the next file.
		while (nImages > 0) {
			selectImage(nImages);
			close();
		}
	}
}