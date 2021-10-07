import controlP5.*;
import java.util.*;

import processing.awt.PSurfaceAWT.SmoothCanvas;
import javax.swing.JFrame;
import java.awt.Dimension;

ControlP5 cp5;

Group menuGroup, footerGroup, renderingGroup;
ButtonBar buttonBar;
ScrollableList methodList, calcList;

Textlabel imageLabel, boxLabel, renderingLabel;
Button previewButton;
Slider previewSlider;
ProgressBar progressBar;

Group renderMsgBox, helpMsgBox, aboutMsgBox;

int pW, pH;

void makeResizable() {
  SmoothCanvas sc = (SmoothCanvas)getSurface().getNative();
  JFrame jf = (JFrame)sc.getFrame();
  Dimension d = new Dimension(800, 600);
  jf.setMinimumSize(d);
  surface.setResizable(true);
  pW = width;
  pH = height;
}

void pre() {
  if (pW != width || pH != height) {
    pW = width ;
    pH = height ;
    cp5.setGraphics(this,0,0);
    menuGroup.setSize(width, 31);
    methodList.setPosition(width - 200, 0);
    calcList.setPosition(width - 100, 0);
    footerGroup.setPosition(0, height - 30)
      .setSize(width, 31);
    renderingGroup.setPosition(0, height - 30)
      .setSize(width, 31);
    previewSlider.setWidth(width - 300);
    progressBar.setWidth(width - 400);
    renderMsgBox.setPosition(width/2 - 75,100);
    calcScreenScale();
  }
}

void initP5() {
  registerMethod("pre", this);
  cp5 = new ControlP5(this);
//---------------------------------------- Menu ----------------------------------------
  menuGroup = cp5.addGroup("menuGroup", 0, 0)
    .setSize(width, 31)
    .hideBar()
    .setBackgroundColor(color(0, 45, 90))
    ;

  buttonBar = cp5.addButtonBar("buttonBar")
    .setPosition(0, 0)
    .setSize(600, 30)
    .addItems(split("New;Load image;Load morph;Save morph;Render;Help;About",";"))
    .setGroup(menuGroup)
    ;

  methodList = cp5.addScrollableList("methodList", width - 200, 0, 100, 300)
    .setBarHeight(30)
    .setItemHeight(30)
    .addItems(split("Segments;Constant;Smooth (auto);Linear (auto);Smooth (manual);Linear (manual)",";"))
    .setType(ScrollableList.DROPDOWN)
    .close()
    .setValue(0)
    .setGroup(menuGroup)
    ;

  calcList = cp5.addScrollableList("calcList", width - 100, 0, 100, 200)
    .setBarHeight(30)
    .setItemHeight(30)
    .addItems(split("Weight;Max;Sum",";"))
    .setType(ScrollableList.DROPDOWN)
    .close()
    .setValue(0)
    .setGroup(menuGroup)
    ;
//---------------------------------------- Footer ----------------------------------------
  footerGroup = cp5.addGroup("footerGroup", 0, height - 30)
    .setSize(width, 31)
    .hideBar()
    .setBackgroundColor(color(0, 45, 90))
    ;

  imageLabel = cp5.addTextlabel("imageLabel", "", 0, 10)
    .setGroup(footerGroup)
    ;

  boxLabel = cp5.addTextlabel("boxLabel", "", 100, 10)
    .setGroup(footerGroup)
    ;

  previewButton = cp5.addButton("previewButton")
    .setPosition(200, 0)
    .setSize(100,30)
    .setLabel("Preview")
    .setSwitch(true)
    .setVisible(false)
    .setGroup(footerGroup)
    ;

  previewSlider = cp5.addSlider("previewSlider", 0, 9, 0, 300, 0, width - 300, 20)
    .setNumberOfTickMarks(10)
    .setSliderMode(Slider.FLEXIBLE)
    .setLabelVisible(false)
    .setVisible(false)
    .setGroup(footerGroup)
    ;
//---------------------------------------- Render Menu ----------------------------------------
  renderingGroup = cp5.addGroup("renderingGroup", 0, height - 30)
    .setSize(width, 31)
    .hideBar()
    .setBackgroundColor(color(0, 45, 90))
    .hide()
    ;

  cp5.addButton("cancelRenderingButton")
    .setPosition(0, 0)
    .setSize(100,30)
    .setCaptionLabel("Cancel")
    .setGroup(renderingGroup)
    ;

  renderingLabel = cp5.addTextlabel("renderingLabel", "", 200, 10)
    .setGroup(renderingGroup)
    ;

  progressBar = new ProgressBar(cp5, "progressBar");
  progressBar.setPosition(400, 0)
    .setSize(width - 400, 30)
    .setRange(0, 1000)
    .setValue(0)
    .setGroup(renderingGroup)
    ;
//---------------------------------------- Render MsgBox ----------------------------------------
  renderMsgBox = cp5.addGroup("renderMsgBox", width/2 - 75, 100)
    .setSize(150, 200)
    .setBackgroundColor(color(128,192))
    .disableCollapse()
    .hideArrow()
    .setCaptionLabel("Render")
    .hide()
    ;

  cp5.addTextlabel("durationLabel","DURATION", 10, 13)
    .setGroup(renderMsgBox)
    ;

  cp5.addNumberbox("durationBox", 80, 10, 60, 14)
    .setCaptionLabel("")
    .setMin(1)
    .setMax(30)
    .setValue(3)
    .setGroup(renderMsgBox)
    ;

  cp5.addTextlabel("mixLabel","MIX DURATION", 10, 33)
    .setGroup(renderMsgBox)
    ;

  cp5.addNumberbox("mixBox", 80, 30, 60, 14)
    .setCaptionLabel("")
    .setMin(1)
    .setMax(30)
    .setValue(3)
    .setGroup(renderMsgBox)
    ;

  cp5.addTextlabel("fpsLabel","FPS", 10, 53)
    .setGroup(renderMsgBox)
    ;

  cp5.addNumberbox("fpsBox", 80, 50, 60, 14)
    .setCaptionLabel("")
    .setMin(10)
    .setMax(60)
    .setValue(25)
    .setMultiplier(5)
    .setGroup(renderMsgBox)
    ;

  cp5.addTextlabel("stepsLabel", "STEPS", 10, 73)
    .setGroup(renderMsgBox)
    ;

  cp5.addNumberbox("stepsBox", 80, 70, 60, 14)
    .setCaptionLabel("")
    .setMin(1)
    .setMax(4)
    .setValue(2)
    .setGroup(renderMsgBox)
    ;

  cp5.addTextlabel("cyclesLabel", "CYCLES", 10, 93)
    .setGroup(renderMsgBox)
    ;

  cp5.addNumberbox("cyclesBox", 80, 90, 60, 14)
    .setCaptionLabel("")
    .setMin(1)
    .setMax(5)
    .setValue(1)
    .setGroup(renderMsgBox)
    ;

  cp5.addTextlabel("labelRender","RENDER", 10, 113)
    .setGroup(renderMsgBox)
    ;

  cp5.addCheckBox("renderCB")
    .setPosition(80, 110)
    .setSize(40, 40)
    .setItemsPerRow(1)
    .setItemWidth(13)
    .setItemHeight(13)
    .setSpacingRow(6)
    .addItem("Video", 1)
    .addItem("Images", 1)
    .setGroup(renderMsgBox)
    .getItem(0).setState(true)
    ;

  cp5.addButton("saveRenderButton")
    .setPosition(10, 160)
    .setSize(60,30)
    .setCaptionLabel("Save as...")
    .setGroup(renderMsgBox)
    ;

  cp5.addButton("cancelRenderButton")
    .setPosition(80, 160)
    .setSize(60,30)
    .setCaptionLabel("Cancel")
    .setGroup(renderMsgBox)
    ;
//---------------------------------------- Help MsgBox ----------------------------------------
  helpMsgBox = cp5.addGroup("helpMsgBox", width/2 - 300, 50)
    .setSize(600, 450)
    .setBackgroundColor(color(128,192))
    .disableCollapse()
    .hideArrow()
    .setCaptionLabel("Help")
    .hide()
    ;

  cp5.addTextarea("txt")
    .setPosition(10, 10)
    .setSize(580, 390)
    .setFont(createFont("Ubuntu-R.ttf", 12))
    .setLineHeight(16)
    .setColor(color(255))
    .setColorBackground(color(0))
    .setColorForeground(color(255))
    .setGroup(helpMsgBox)
    .setText("KEYBOARD:\n"
      +"    SPACE - Switch Active Image\n"
      +"    T - Transparency On/Off\n"
      +"    B - Render Box Handles On/Off\n"
      +"    S - Switch Images Position\n"
      +"    2 - Delete Image 2\n"
      +"    0 - Delete All Marks\n"
      +"    LEFT/RIGHT on Preview - Navigate Images\n"
      +"    CONTROL + Mouse over Mark - Show Smooth Curve (Smooth Method)\n"
      +"\n"
      +"MOUSE:\n"
      +"    Double Click - Create/Remove Mark\n"
      +"    Left Click + Drag - Move Active Image\n"
      +"    Left Click + Drag over Mark - Move Start Mark/Render Box Handles\n"
      +"    Right Click + Drag over Mark - Place/Replace End Mark\n"
      +"    Mouse Wheel - Resize Active Image\n"
      +"    Mouse Wheel over Mark - Resize Range (Manual Methods)\n"
      +"    CONTROL + Mouse Wheel over Mark - Change Smooth Curve (Smooth Method)\n"
      +"\n"
      +"You can Drag & Drop images (switch active image before loading/dropping another one)\n"
      +"\n"
      +"More info at https://github.com/linux-man/dephormer\n"
      );
    ;

  cp5.addButton("closeHelpButton")
    .setPosition(530, 410)
    .setSize(60,30)
    .setCaptionLabel("Close")
    .setGroup(helpMsgBox)
    ;
//---------------------------------------- About MsgBox ----------------------------------------
  aboutMsgBox = cp5.addGroup("aboutMsgBox", width/2 - 75, 100)
    .setSize(150, 200)
    .setBackgroundColor(color(128,192))
    .disableCollapse()
    .hideArrow()
    .setCaptionLabel("About")
    .hide()
    ;

  cp5.addTextlabel("aboutLabel","DEPHORMER", 4, 13)
    .setFont(createFont("Ubuntu-R.ttf", 22))
    .setColor(color(0, 170, 255))
    .setGroup(aboutMsgBox)
    ;

  cp5.addTextlabel("verLabel","v0.9.1", 50, 43)
    .setFont(createFont("Ubuntu-RI.ttf",18))
    .setColor(color(255, 116, 217))
    .setGroup(aboutMsgBox)
    ;

  cp5.addTextlabel("copyLabel","© 2021 Caldas Lopes", 4, 83)
    .setFont(createFont("Ubuntu-R.ttf",14))
    .setGroup(aboutMsgBox)
    ;

  cp5.addTextlabel("licenseLabel","Dephormer is free software\nand is licensed under the\nGNU General Public License", 4, 113)
    .setSize(150, 60)
    .setFont(createFont("Ubuntu-RI.ttf",11))
    .setGroup(aboutMsgBox)
    ;

  cp5.addButton("closeAboutButton")
    .setPosition(80, 160)
    .setSize(60,30)
    .setCaptionLabel("Close")
    .setGroup(aboutMsgBox)
    ;
}

void buttonBar(int n) {
  for(HashMap s: (List<HashMap>)buttonBar.getItems()) buttonBar.changeItem((String)s.get("name"), "selected", false);
  switch(n) {
    case 0://New
      init();
      break;
    case 1://Load image
      insertMedia(selectFile("Load image"));
      break;
    case 2://Load morph
      if (i1 != null) loadMorph(selectFile("Load morph"));
      break;
    case 3://Save morph
      if(i1 != null && marks.size() > 0) saveMorph(selectFile("Save morph"));
      break;
    case 4://Render
      if(i1 != null) {
        hide = true;
        menuGroup.setVisible(false);
        footerGroup.setVisible(false);
        renderMsgBox.setVisible(true);
      }
      break;
    case 5://Help
      hide = false;
      menuGroup.setVisible(false);
      footerGroup.setVisible(false);
      helpMsgBox.setVisible(true);
      break;
    case 6://About
      hide = false;
      menuGroup.setVisible(false);
      footerGroup.setVisible(false);
      aboutMsgBox.setVisible(true);
      break;
  }
}

void methodList(int n) {
  method = n;
  try {calcList.setVisible(n != 0);} catch(Exception e) {};
}

void calcList(int n) {
  calc = n;
}

void renderCB(float[] cb) {
  renderVideo = cb[0] == 1;
  renderImages = cb[1] == 1;
}

void durationBox(float v) {
  duration = int(v);
}

void mixBox(float v) {
  mixDuration = int(v);
}

void fpsBox(float v) {
  fps = int(v);
}

void stepsBox(float v) {
  steps = int(v);
}

void cyclesBox(float v) {
  cycles = v;
}

void saveRenderButton() {
  boolean savePng, saveAvi;
  String ext;

  File file = selectFile("Save render");
  if(file != null) {
    path = file.getPath();
    savePng = path.endsWith(".png");
    saveAvi = path.endsWith(".avi");
    path = path.replaceFirst("[.][^.]+$", "");
    if(path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".avi") || path.endsWith(".mp4")) {
      savePng = savePng || path.endsWith(".png");
      saveAvi = saveAvi || path.endsWith(".avi");
      path = path.replaceFirst("[.][^.]+$", "");
    }
    if(savePng) ext = ".png";
    else ext = ".jpg";

    if(renderImages) imagesPath = path + "%03d" + ext;
    
    if(renderVideo) {
      if(saveAvi) ext = ".avi";
      else ext = ".mp4";
      videoPath = path + ext;
    }
    renderingGroup.setVisible(true);
    renderMsgBox.setVisible(false);
    renderingLabel.setText("");
    progressBar.setValue(0);
    render = new Render(duration, fps, steps, cycles);
    render.start();
  }
}

void cancelRenderButton() {
  menuGroup.setVisible(true);
  footerGroup.setVisible(true);
  renderingGroup.setVisible(false);
  renderMsgBox.setVisible(false);
  hide = false;
}

void cancelRenderingButton() {
  render.interrupt();
  render = null;
  menuGroup.setVisible(true);
  footerGroup.setVisible(true);
  //renderingGroup.setVisible(false);
  renderMsgBox.setVisible(false);
  hide = false;
}

void closeHelpButton() {
  menuGroup.setVisible(true);
  footerGroup.setVisible(true);
  helpMsgBox.setVisible(false);  
  hide = false;
}

void closeAboutButton() {
  menuGroup.setVisible(true);
  footerGroup.setVisible(true);
  aboutMsgBox.setVisible(false);  
  hide = false;
}

void previewButton(boolean on) {
  preview = on;
  hide = on;
  menuGroup.setVisible(!on);
  previewSlider.setVisible(on);
  imageLabel.setVisible(!on);
  boxLabel.setVisible(!on);

  if(on) {
    previewImg = new PImage[10];
    cursor(WAIT);
    if(method == 0) calcSegMorph(true, true);
    else calcPointMorph(true);
    morph(true, 9, 1, 1);
    if(i2 != null) {
      if(method == 0) calcSegMorph(false, true);
      else calcPointMorph(false);
      morph(false, 9, 1, 1);
      mixMorph(10, 10);
    }
    for(int f = 0; f < 10; f++) previewImg[f] = loadImage(String.format(tempPath + "/1%04d.png", f));
    cursor(ARROW);
    previewSlider.setValue(0);
  }
}
