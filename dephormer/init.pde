void initImg1() {
  i1dx = 0;
  i1dy = 0;  
  if(img1 == null) {
    i1 = null;
    i1Width = 0;
  }
  else {
    i1 = img1.copy();
    i1Width = i1.width;
    renderBoxX = 0;
    renderBoxY = 0;
    renderBoxW = i1.width;
    renderBoxH = i1.height;
    fixRenderBox();
  }
}

void initImg2() {
  i2dx = 0;
  i2dy = 0;
  if(img2 == null) {
    i2 = null;
    i2Width = 0;
  }
  else {
    i2 = img2.copy();
    i2Width = i2.width;
    fixRenderBox();
  }
}

void init() {
  try {
    Path temp = Files.createTempDirectory("dephorm");
    tempPath = temp.normalize().toString();
  } catch (IOException e) {
    tempPath = ".";
  };

  method = 0;
  calc = 0;
  methodList.setValue(0);
  calcList.setValue(0);

  showFirst = true;
  showTransp = false;
  renderBox = false;
  morphPath = null;
  img1 = null;
  img2 = null;
  showFirst = true;
  marks.clear();
  initImg1();
  initImg2();
  imgChanged();
  menuGroup.setVisible(true);
  footerGroup.setVisible(true);
  renderingGroup.setVisible(false);
  renderMsgBox.setVisible(false);
  path = null;
  morphPath = null;
}
