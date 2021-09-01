import fr.insalyon.creatis.grida.client.GRIDAClient;
import fr.insalyon.creatis.grida.client.GRIDAClientException;
import fr.insalyon.creatis.grida.common.bean.GridData;
import java.util.ArrayList;
import java.util.List;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public void launchProcess(String command){
  System.out.println("Executing " + command);
  p = Runtime.getRuntime().exec(command);
  printOutputs(p);
}

public void launchProcess(String[] command){
  System.out.println("Executing " + String.join(" ", command));
  p = Runtime.getRuntime().exec(command);
  printOutputs(p);
  
}

public void printOutputs(Process p){
  p.waitFor();
  StringBuilder sdtOut = new StringBuilder();
  for (int iByte; (iByte = p.getInputStream().read()) != -1; ) {
    sdtOut.append((char) iByte);
  }
  System.out.println(sdtOut);
  StringBuilder sdtErr = new StringBuilder();
  for (int iByte; (iByte = p.getErrorStream().read()) != -1; ) {
    sdtErr.append((char) iByte);
  }
  System.out.println(sdtErr);
  System.err.println(sdtErr);
}

String proxyPath = "/var/www/html/workflows/x509up_robot";

//begin by downloading all input files
//String inputFolder = "/biomed/user/c/creatis/vip/data/users/vanel_guillaume/29-05-2021_02:49:10";

int index = inputFolder.lastIndexOf("/");
String resultDir = inputFolder.substring(0, index);
System.out.println("[mergeResults]: begin by downloading all input files from folder " + inputFolder);
String userDir=System.getProperty("user.dir").toString();
String userDownloadDir=System.getProperty("user.dir").toString()+"/download";
String downloadedZIP;
try {
  GRIDAClient vc = new GRIDAClient("localhost", 9006, proxyPath);
	System.out.println("making grida call getRemoteFolder from " + inputFolder + " to " + userDownloadDir);
  vc.getRemoteFolder(inputFolder, userDownloadDir, false);
  launchProcess(new String[] {"/bin/sh", "-c", "ls download/*.tar |  wc -l"});
  launchProcess(new String[] {"/bin/sh", "-c", "if [ -f download/README.txt ]; then cat doanload/README.txt | wc -l; fi"});
  tar_filter = new FilenameFilter(){
    public boolean accept(File dir, String name) {
      return name.endsWith(".tar");
    }
  };
  tar_files = new File("download").listFiles(tar_filter);
  for (File current_tar:tar_files){
    launchProcess("tar --directory=download -xvf " + current_tar.toString());
  }
  //now process data
  Dictionary sort_files = new Hashtable();
  sort_files.put("markers_coordinates", ".csv");
  sort_files.put("ground_truth_images", ".gt.tif");
  sort_files.put("final_images", ".img.tif");
  sort_files.put("extracted_features", ".json");
  String tar_command = "tar -cf microVipOut.tar ";
String rmCommand = "rm -rf download microVipOut.tar ";
  for (Enumeration j = sort_files.keys(); j.hasMoreElements();) {
    folder_name = j.nextElement();
    System.out.println("enumeration folder name " + folder_name);
    tar_command += folder_name + " ";
    rmCommand += folder_name + " ";
    folder = new File(folder_name);
    folder.mkdir();
    filter = new FilenameFilter() {
      public boolean accept(File dir, String name) {
        return name.endsWith(sort_files.get(folder_name));
      }
    };
    File[] matching_files = new File("download").listFiles(filter);
    for (File current_file:matching_files) {
      new_file = new File(folder, current_file.getName());
      current_file.renameTo(new_file);
	  System.out.println("Renamed "+current_file.toString() +" to "+new_file.toString());
    }
  }
  launchProcess(tar_command);
  launchProcess("ls -lh microVipOut.tar");
  //upload results
  microVipOut = new URI(inputFolder+"microVipOut.tar");
  System.out.println("making grida call uploadFile "+userDir+"/microVipOut.tar"+ " to "+inputFolder);
  vc.uploadFile(userDir+"/microVipOut.tar", inputFolder);
  launchProcess(rmCommand);
  System.out.println("Beanshell completed");
} catch (GRIDAClientException ex) {
  ex.printStackTrace(System.out);
}
 
