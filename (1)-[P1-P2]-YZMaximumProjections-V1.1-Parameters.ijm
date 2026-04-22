// Fiji Macro by Franziska Krämer and Dr. Frederic Strobl
// (1) of the FijiFusionMacroCollection
// Associated with the Krämer et al. 2026A Data Descriptor Study
// Macro Version 1.1 - Tested with ImageJ 1.54p
// -------------------------------------------------------------
//
// Purpose:
// Batch-process all z stacks in a selected input folder to calculate
// two maximum projections for each stack:
// 1) a z projection through the original z stack ("_ZMax")
// 2) a y projection after top reslicing ("_YMax")
//
// Workflow:
// - The user selects an input folder containing multi-page TIFF stacks.
//   >>> In the associated study, this corresponded to folder P1.
// - The user selects an output folder.
//   >>> In the associated study, this corresponded to folder P2.
// - The macro creates two subfolders in the output folder: "ZMax" and "YMax".
// - For each stack, the macro calculates the z and y maximum projections.
// - For each stack, the macro saves:
//     <filename>_ZMax.tif in the "ZMax" subfolder
//     <filename>_YMax.tif in the "YMax" subfolder
//
// Parameters:
// - The value for 'voxel_depth' in the parameter input section should
//   be set to match the xy-to-z sampling ratio of the dataset.
//   >>> In the associated study, voxel_depth=4 reflected a z spacing four times
//   larger than the lateral pixel pitch.
//
// Notes:
// - Processing is performed in pixel/voxel units. No physical calibration is applied.
// - The macro processes only files ending in .tif or .TIF.
// - This macro is intended for single-channel stacks.
// - Depending on the xy-to-z sampling ratio of the dataset,
//   reslicing may involve interpolation, meaning that some voxel
//   intensities in the transformed stack are interpolated rather than
//   directly measured values.

setBatchMode(true);

// Ask the user to select input and output directories.
inputDir = getDirectory("Choose the Input Directory");
outputDir = getDirectory("Choose the Output Directory");

// Create separate output subfolders for the two projection types.
outputDir1 = outputDir + "/ZMax/";
File.makeDirectory(outputDir1);

outputDir2 = outputDir + "/YMax/";
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

		// Read stack dimensions and store the number of z-slices.
		Stack.getDimensions(imageWidth, imageHeight, numChannels, numSlices, frames);
		s = numSlices;

		// --- PARAMETER INPUT SECTION (###) ---
		// Define image properties before reslicing.
		run("Properties...", "channels=1 slices=" + s + " frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=### origin=0,0,0");

		// Generate a maximum-intensity projection through the z stack.
		run("Z Project...", "start=1 projection=[Max Intensity]");
		
		// Save the z projection and close it.
		saveAs("Tiff", outputDir1 + fName + "_ZMax.tif");
		close();

		// Reslice the stack from the top to generate an orthogonal view.
		run("Reslice [/]...", "output=1 start=Top flip");

		// Generate a maximum-intensity projection from the resliced stack.
		run("Z Project...", "start=1 projection=[Max Intensity]");

		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");

		// Save the y projection.
		saveAs("Tiff", outputDir2 + fName + "_YMax.tif");

		// Close all remaining open images before processing the next file.
		while (nImages > 0) {
			selectImage(nImages);
			close();
		}
	}
}