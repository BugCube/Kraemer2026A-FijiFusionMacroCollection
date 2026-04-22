// Fiji Macro by Franziska Krämer and Dr. Frederic Strobl
// (2) of the FijiFusionMacroCollection
// Associated with the Krämer et al. 2026A Data Descriptor Study
// Macro Version 1.1 - Tested with ImageJ 1.54p
// -------------------------------------------------------------
//
// Purpose:
// Batch-process all z stacks in a selected input folder to generate:
// 1) cropped z stacks that have mutual x-z quadratic footprints ("_QCrop")
// 2) corresponding z stacks with defined regions blacked out,
//    i.e. regions where all pixel intensities set to zero ("_BOut")
//
// Workflow:
// - The user selects an input folder containing multi-page TIFF stacks.
//   >>> In the associated study, this corresponded to folder P1.
// - The user selects an output folder.
//   >>> In the associated study, this corresponded to folder P3.
// - The macro creates two subfolders in the output folder: "QCrop" and "BOut".
// - For each stack, the macro restricts the x and z ranges
//   while retaining the full y range.
// - For each cropped stack, the macro generates a modified version
//   in which a user-defined region is blacked out.
// - For each stack, the macro saves:
//     <filename>_QCrop.tif in the "QCrop" subfolder
//     <filename>_BOut.tif in the "BOut" subfolder
//
// Parameters:
// - The values for 'width', 'x', 'first', and 'last' in the first parameter input
//   section should be set to define the desired x and z ranges.
//   >>> In the associated study, these values were dataset-specific.
// - The values for 'height' and 'y' in the second parameter input section
//   can be used to set selected voxel intensities to zero and thereby remove
//   unwanted regions from downstream processing (optional).
//   >>> In the associated study, these values were dataset-specific, and
//   this step was used to remove large parts of the embryo while retaining
//   a small part of the pole at the side opposite the fluorescent
//   microsphere-containing agarose column.
//
// Notes:
// - Processing is performed in pixel/voxel units. No physical calibration is applied.
// - The macro processes only files ending in .tif or .TIF.
// - This macro is intended for single-channel stacks.

setBatchMode(true);

// Ask the user to select input and output directories.
inputDir = getDirectory("Choose the Input Directory");
outputDir = getDirectory("Choose the Output Directory");

// Create separate output subfolders.
outputDir1 = outputDir + "/QCrop/";
File.makeDirectory(outputDir1);

outputDir2 = outputDir + "/BOut/";
File.makeDirectory(outputDir2);

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

		// Read image dimensions for use in the cropping steps.
		Stack.getDimensions(imageWidth, imageHeight, numChannels, numSlices, frames);

		// --- FIRST PARAMETER INPUT SECTION (###) ---
		// Define the x range of the cropped stack while retaining the full
		// image height in y, then restrict the stack to the desired z range.
		run("Specify...", "width=### height=" + imageHeight + " x=### y=0 slice=1");
		run("Crop");
		run("Slice Keeper", "first=### last=### increment=1");

		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");

		// Save the cropped stack.
		saveAs("Tiff", outputDir1 + fName + "_QCrop.tif");
		
		// Read current image dimensions after cropping.
		Stack.getDimensions(imageWidth, imageHeight, numChannels, numSlices, frames);
		
		// --- SECOND PARAMETER INPUT SECTION (###) ---
		// Define a region to be blacked out.
		// The black-out is applied across the full width of the cropped image.
		// Note: Set height and y to 0 to disable this step.
		run("Specify...", "width=" + imageWidth + " height=### x=0 y=### slice=1");

		// Set all voxel intensities within the selected region to zero.
		run("Multiply...", "value=0 stack");

		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");

		// Save the modified (black-out) stack.
		saveAs("Tiff", outputDir2 + fName + "_BOut.tif");

		// Close all remaining open images before processing the next file.
		while (nImages > 0) {
			selectImage(nImages);
			close();
		}
	}
}