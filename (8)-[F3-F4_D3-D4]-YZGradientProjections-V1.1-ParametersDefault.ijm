// Fiji Macro by Franziska Krämer and Dr. Frederic Strobl
// (8) of the FijiFusionMacroCollection
// Associated with the Krämer et al. 2026A Data Descriptor Study
// Macro Version 1.1 - Tested with ImageJ 1.54p
// -------------------------------------------------------------

// Purpose:
// Batch-process all z stacks in a selected input folder to calculate
// two gradient projections for each stack:
// 1) a z projection through the original z stack ("_ZGrad")
// 2) a y projection after top reslicing ("_YGrad")
// The weighting is applied slice-wise by progressively reducing slice
// intensities from the chosen starting slice onward.
//
// Workflow:
// - The user selects an input folder containing multi-page TIFF stacks.
//   >>> In the associated study, this corresponded to folders F1 and D1.
// - The user selects an output folder.
//   >>> In the associated study, this corresponded to folders F2 and D2.
// - The macro creates two subfolders in the output folder: "YGrad" and "ZGrad".
// - For each stack, the macro calculates the z and y gradient projections.
// - For each stack, the macro saves:
//     <filename>_ZGrad.tif in the "ZGrad" subfolder
//     <filename>_YGrad.tif in the "YGrad" subfolder
//
// Parameters:
// - The divisor used in the two parameter input sections below determines the
//   slice at which gradient weighting begins.
// - Smaller divisors shift the start of weighting toward earlier slices,
//   whereas larger divisors shift it toward later slices.
//   >>> In the associated study, the divisor is 3, meaning that weighting begins
//   after the first third of the stack depth.
//
// Notes:
// - Processing is performed in pixel/voxel units. No physical calibration is applied.
// - The macro processes only files ending in .tif or .TIF.
// - This macro is intended for single-channel stacks.

setBatchMode(true);

// Ask the user to select input and output directories.
inputDir = getDirectory("Choose the Input Directory");
outputDir = getDirectory("Choose the Output Directory");

// Create separate output subfolders for the two projection types.
outputDir1 = outputDir + "/ZGrad/";
File.makeDirectory(outputDir1);

outputDir2 = outputDir + "/YGrad/";
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

		// Read image dimensions for use in the weighting steps.
		Stack.getDimensions(imageWidth, imageHeight, numChannels, numSlices, frames);

		// --- PARAMETER INPUT (###) ---
		// Define the divisor controlling the start of gradient weighting.
		// Default: 3 (weighting starts after the first third of the stack).
		divisor = 3;

		// Generate the gradient-weighted projection through the original z stack.
		currentSliceZ = (numSlices / divisor) + 1;
		summandZ = 1 / (numSlices - (currentSliceZ - 1));
		z = summandZ;

		// Apply a progressively increasing attenuation to successive z slices.
		for (k = currentSliceZ; k <= numSlices; k++) {
			setSlice(k);
			b = 1 - z;
			run("Multiply...", "value=" + b + " slice");
			z = z + summandZ;
		}
		
		// Generate a gradient projection through the z stack.
		run("Z Project...", "projection=[Max Intensity]");
		
		// Remove slice labels that may be added during reslicing or projection.
		run("Remove Slice Labels");
		
		// Save the standard projection and close it.
		saveAs("Tiff", outputDir1 + fName + "_ZGrad.tif");
		close();

		// Generate a top-resliced stack for the orthogonal projection.
		run("Reslice [/]...", "output=1 start=Top flip");

		// Define the slice at which gradient weighting begins in the resliced stack.
		currentSliceY = (imageHeight / divisor) + 1;
		summandY = 1 / (imageHeight - (currentSliceY - 1));
		y = summandY;

		// Apply a progressively increasing attenuation to successive slices.
		for (j = currentSliceY; j <= imageHeight; j++) {
			setSlice(j);
			a = 1 - y;
			run("Multiply...", "value=" + a + " slice");
			y = y + summandY;
		}

		// Generate a gradient projection from the resliced stack.
		run("Z Project...", "projection=[Max Intensity]");
		
		// Remove slice labels to ensure clean output.
		run("Remove Slice Labels");
		
		// Save the orthogonal projection.
		saveAs("Tiff", outputDir2 + fName + "_YGrad.tif");

		// Close all remaining open images before processing the next file.
		while (nImages > 0) {
			selectImage(nImages);
			close();
		}
	}
}