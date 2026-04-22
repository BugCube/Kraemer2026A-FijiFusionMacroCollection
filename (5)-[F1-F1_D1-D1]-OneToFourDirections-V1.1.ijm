// Fiji Macro by Franziska Krämer and Dr. Frederic Strobl
// (5) of the FijiFusionMacroCollection
// Associated with the Krämer et al. 2026A Data Descriptor Study
// Macro Version 1.1 - Tested with ImageJ 1.54p
// -------------------------------------------------------------
//
// Purpose:
// Batch-process all z stacks in a selected input folder to generate
// corresponding stacks along four orientations spaced 90° apart.
//
// Workflow:
// - The user selects an input folder containing multi-page TIFF stacks.
//   >>> In the associated study, this corresponded to folders F1 and D1.
// - For each stack, the macro generates additional stacks rotated by
//   either 90°, 180°, or 270° around the y axis.
// - For each stack, the macro renames/saves the stacks in the input folder
//   using modified file names:
//     <filename>_DR1.tif for the original stack
//     <filename>_DR2.tif for the stack that was rotated  90° around the y axis
//     <filename>_DR3.tif for the stack that was rotated 180° around the y axis
//     <filename>_DR4.tif for the stack that was rotated 270° around the y axis
//
// Parameters:
// - This macro is universal and does not require user-defined processing parameters.
//
// Notes:
// - Processing is performed in pixel/voxel units. No physical calibration is applied.
// - The macro processes only files ending in .tif or .TIF.
// - This macro is intended for single-channel stacks.
// - The rotated stacks are generated sequentially, i.e. each additional rotation
//   is derived from the previously rotated stack.

setBatchMode(true);

// Ask the user to select the input directory.
inputDir = getDirectory("Choose the Directory");

// Get a list of all files in the input directory.
list = getFileList(inputDir);

// Loop over all files in the input folder.
for (i = 0; i < list.length; i++) {

	// Process only TIFF files with extension .tif or .TIF.
	if (endsWith(list[i], "TIF") || endsWith(list[i], "tif")) {
		print(list[i]);

		// Store original name and open image.
		origPath = inputDir + list[i];
		open(origPath);

		// Store the file name without extension for output naming.
		fName = File.nameWithoutExtension;
		print(fName);

		// Rename the original file to _DR1.
		newPath = inputDir + fName + "_DR1.tif";
		File.rename(origPath, newPath);

		// Rotate the stack by 90°.
		run("Rotate 90 Degrees Left");
		run("Reslice [/]...", "output=1 start=Top flip");
		run("Rotate 90 Degrees Right");
		
		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");
		
		// Save the rotated stack.
		saveAs("Tiff", inputDir + fName + "_DR2.tif");

		// Rotate the stack by 90°.
		run("Rotate 90 Degrees Left");
		run("Reslice [/]...", "output=1 start=Top flip");
		run("Rotate 90 Degrees Right");
		
		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");
		
		// Save the rotated stack.
		saveAs("Tiff", inputDir + fName + "_DR3.tif");

		// Rotate the stack by 90°.
		run("Rotate 90 Degrees Left");
		run("Reslice [/]...", "output=1 start=Top flip");
		run("Rotate 90 Degrees Right");
		
		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");
		
		// Save the rotated stack.
		saveAs("Tiff", inputDir + fName + "_DR4.tif");

		// Close all images before next iteration.
		while (nImages > 0) {
			selectImage(nImages);
			close();
		}
	}
}