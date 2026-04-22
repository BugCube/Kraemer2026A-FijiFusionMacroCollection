// Fiji Macro by Franziska Krämer and Dr. Frederic Strobl
// (4) of the FijiFusionMacroCollection
// Associated with the Krämer et al. 2026A Data Descriptor Study
// Macro Version 1.1 - Tested with ImageJ 1.54p
// -------------------------------------------------------------
//
// Purpose:
// Batch-process all z stacks in a selected input folder to generate
// rotated and spatially cropped stacks.
//
// Workflow:
// - The user selects an input folder containing multi-page TIFF stacks.
//   >>> In the associated study, this corresponded to folders P4 or P5.
// - The user selects an output folder.
//   >>> In the associated study, this corresponded to folders F1 or D1.
// - For each stack, the macro rotates the stack around x, y, and z
//   and subsequently restricts the x, y, and z ranges.
// - For each stack, the macro saves:
//     <filename>_RotCrop.tif in the selected output folder
//
// Parameters:
// - The rotation angles in the first three parameter input sections should be set
//   to align the specimen as seen fit.
//   >>> In the associated study, these values were dataset-specific and used to align
//       the embryonic axes with the images axes
// - The values for 'width', 'height', 'x', 'y', 'first', and 'last' in the fourth and
//   fifth parameter input section should be set to restrict the x, y, and z ranges of
//   the rotated stack.
//   >>> In the associated study, these values were dataset-specific and used to crop
//       the image to 600x1000x600 or 600x1100x600 voxels.
//
// Notes:
// - Processing is performed in pixel/voxel units. No physical calibration is applied.
// - The macro processes only files ending in .tif or .TIF.
// - This macro is intended for single-channel stacks.
// - Rotation involves interpolation, meaning that all voxel
//   intensities in the transformed stack are interpolated.

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

		// Store the file name without extension and generate the output name.
		fName = File.nameWithoutExtension;
		print(fName);

		// Reslice the original stack to prepare the first reorientation step.
		run("Reslice [/]...", "output=1 start=Top flip");

		// --- FIRST PARAMETER INPUT SECTION (###) ---
		// Define the rotation angle for reorientation around the y axis.
		run("Rotate... ", "angle=### grid=1 interpolation=Bilinear stack");
		run("Reslice [/]...", "output=1 start=Top");

		// --- SECOND PARAMETER INPUT SECTION (###) ---
		// Define the rotation angle for reorientation around the z axis.
		run("Rotate... ", "angle=### grid=1 interpolation=Bilinear stack");
		run("Rotate 90 Degrees Left");
		run("Reslice [/]...", "output=1 start=Top");

		// --- THIRD PARAMETER INPUT SECTION (###) ---
		// Define the rotation angle for reorientation around the x axis.
		run("Rotate... ", "angle=### grid=1 interpolation=Bilinear stack");
		run("Reslice [/]...", "output=1 start=Top");
		run("Rotate 90 Degrees Right");

		// --- FOURTH PARAMETER INPUT SECTION (###) ---
		// Define the x and y range of the cropped rotated stack.
		run("Specify...", "width=### height=### x=### y=### slice=1");
		run("Crop");

		// --- FIFTH PARAMETER INPUT SECTION (###) ---
		// Define the z range of the cropped rotated stack.
		run("Slice Keeper", "first=### last=### increment=1");

		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");

		// Save the rotated and cropped stack.
		saveAs("Tiff", outputDir + fName + "_RotCrop.tif");

		// Close all remaining open images before processing the next file.
		while (nImages > 0) {
			selectImage(nImages);
			close();
		}
	}
}