/* 
 * End MicroVIP workflow for VIP platform deployment.
 * VIP allows multiple execution of MicroVIP in parallel. When they complete,
 * we gather individual output archives into a larger archive, ordered with
 * separated folders for each type of output file: biomarkers positions .csv,
 * ground truth .tif image, final microscopy .tif image, and extracted features
 * .json file.
 */
// Extract individual executions output archives.
String unzipCommand = "unzip -j "+downloadedZIP;
System.out.println("Executing " + unzipCommand);
Runtime.getRuntime().exec(unzipCommand);
String[] untarCommand = {"/bin/sh", "-c", "cat *.tar | tar -ixf - "};
System.out.println("Executing " + untarCommand);
Runtime.getRuntime().exec(untarCommand);
// Sort files in appropriate directories.
Dictionary sortFiles = new Hashtable();
sortFiles.put("markers_coordinates", ".csv");
sortFiles.put("ground_truth_images", ".GT.tif");
sortFiles.put("final_images", ".img.tif");
sortFiles.put("extracted_features", ".json");
String tarCommand = "tar -cf microVipOut.tar "; // Final archive command.
for (Enumeration j = sortFiles.keys(); j.hasMoreElements();) {
  folderName = j.nextElement();
  System.out.println("Creating folder " + folderName);
  tarCommand += folderName + " ";
  // Create the directory.
  folder = new File(folderName);
  folder.mkdir();
  // Move appropriate files to directory.
  filter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.endsWith(sortFiles.get(folderName));
    }
  };
  File[] matchingFileList = new File(".").listFiles(filter);
  for (File currentFile:matchingFileList) {
    destinationFile = new File(folder, currentFile.getName());
    currentFile.renameTo(destinationFile);
	  System.out.println("Moved " + currentFile.toString() + " to "
	                     + destinationFile.toString());
  }
}
// Archive generated directories.
System.out.println("Executing " + tarCommand);
Runtime.getRuntime().exec(tarCommand);
