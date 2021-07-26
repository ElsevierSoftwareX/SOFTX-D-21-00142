/* 
 * End MicroVIP workflow for VIP platform deployment.
 * VIP allows multiple execution of MicroVIP in parallel. When they complete,
 * we gather individual output archives into a larger archive, ordered with
 * separated folders for each type of output file: biomarkers positions .csv,
 * ground truth .tif image, final microscopy .tif image, and extracted features
 * .json file.
 *
 *   MicroVIP, Microscopy image simulation and analysis tool
 *   Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
 *   CREATIS, Universite Lyon 1, Insa de Lyon, Lyon, France.
 *
 *   This file is part of MicroVIP.
 *   MicroVIP is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>./
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
