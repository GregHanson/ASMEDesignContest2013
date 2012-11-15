PrintWriter writer;
boolean fileIsOpen = false;

void openFile() {
  writer = createWriter("data/" + outputFileName + ".csv");
  fileIsOpen = true;
}
void writeData(String thisString) {
 writer.println(thisString); 
}
void closeFile() {
  writer.flush(); 
  writer.close();
}

