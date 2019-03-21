import javax.swing.*;
import javax.swing.filechooser.*;

import java.nio.file.Path;
import java.nio.file.Files;

File selectFile(String title) {
  JFileChooser chooser = new JFileChooser();
  FileNameExtensionFilter f;
  if(title == "Load morph" || title == "Save morph") {
    f = new FileNameExtensionFilter("Morph files", "mor");
    chooser.addChoosableFileFilter(f);
    chooser.setFileFilter(f);
  }
  else if(title == "Load image") {
    f = new FileNameExtensionFilter("Media files", "jpg", "jpeg", "png", "gif", "bmp");
    chooser.addChoosableFileFilter(f);
    chooser.setFileFilter(f);
  }
  else if(title == "Save morph" && morphPath != null) chooser.setSelectedFile(new File(morphPath));
  else if(title == "Save render" && path != null) chooser.setSelectedFile(new File(path));
  chooser.setDialogTitle(title);
  int returnVal = chooser.showOpenDialog(this.frame);
  if (returnVal == JFileChooser.APPROVE_OPTION) return chooser.getSelectedFile();
  return null;
}

void loadMorph(File file) {
  if (file != null && file.exists()) {
    JSONObject json = loadJSONObject(file);
    marks.clear();
    morphPath = file.getPath();
    renderBoxX = json.getInt("renderBoxX");
    renderBoxY = json.getInt("renderBoxY");
    renderBoxW = json.getInt("renderBoxW");
    renderBoxH = json.getInt("renderBoxH");
    i1Width = json.getInt("i1Width");
    i2Width = json.getInt("i2Width");
    i1dx = json.getInt("i1dx");
    i1dy = json.getInt("i1dy");
    i2dx = json.getInt("i2dx");
    i2dy = json.getInt("i2dy");
    JSONArray jsonMarks = json.getJSONArray("marks");
    for(int n = 0; n < jsonMarks.size(); n++) {
      JSONObject jsonMark = jsonMarks.getJSONObject(n);
      marks.add(new Mark(jsonMark.getFloat("startX"), jsonMark.getFloat("startY"), jsonMark.getFloat("stopX"), jsonMark.getFloat("stopY"), jsonMark.getFloat("range"), jsonMark.getFloat("rate")));
    }
  }
  imgChanged();
  calcScreenScale();
  fixMarks();
}

void saveMorph(File file) {
  if (file != null) {
    String path = file.getPath();
    if(!path.endsWith(".mor")) path = path + ".mor";
    morphPath = path;
    JSONObject json = new JSONObject();
    json.setInt("renderBoxX", renderBoxX);
    json.setInt("renderBoxY", renderBoxY);
    json.setInt("renderBoxW", renderBoxW);
    json.setInt("renderBoxH", renderBoxH);
    json.setInt("i1Width", i1Width);
    json.setInt("i2Width", i2Width);
    json.setInt("i1dx", i1dx);
    json.setInt("i1dy", i1dy);
    json.setInt("i2dx", i2dx);
    json.setInt("i2dy", i2dy);
    JSONArray jsonMarks = new JSONArray();
    for(Mark m: marks) {
      JSONObject jsonMark = new JSONObject();
      jsonMark.setFloat("startX", m.start.x);
      jsonMark.setFloat("startY", m.start.y);
      jsonMark.setFloat("stopX", m.stop.x);
      jsonMark.setFloat("stopY", m.stop.y);
      jsonMark.setFloat("range", m.manualRange);
      jsonMark.setFloat("rate", m.rate);
      jsonMarks.setJSONObject(marks.indexOf(m), jsonMark);
    }
    json.setJSONArray("marks", jsonMarks);
    saveJSONObject(json, path);
  }
}

void insertMedia(File file) {
  if (file != null) {
    String path = file.getPath();
    if(showFirst) {
      img1 = loadImage(path);
      initImg1();
      previewButton.setVisible(true);
    }
    else {
      img2 = loadImage(path);
      initImg2();
    }
  imgChanged();
  }
}
