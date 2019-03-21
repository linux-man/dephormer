boolean mouseOver(float x, float y) {
  return dist(sX(x), sY(y), mouseX, mouseY) < 10;
}

int sX(float x) {//to screen coords
  return int(width / 2  + x * screenScale);
}

int sY(float y) {
  return int(height / 2  + y * screenScale);
}

int mX(float x) {//to marks coords
  return int((x - width / 2) / screenScale);
}

int mY(float y) {
  return int((y - height / 2) / screenScale);
}

void calcScreenScale() {
  if(i1 == null && i2 == null) screenScale = 1;
  else if(i1 == null) screenScale = min((float)(width - deltaImg) / i2.width, (float)(height - deltaImg) / i2.height);
  else if(i2 == null) screenScale = min((float)(width - deltaImg) / i1.width, (float)(height - deltaImg) / i1.height);
  else screenScale = min((float)(width - deltaImg) / min(i1.width, i2.width), (float)(height - deltaImg) / min(i1.height, i2.height)); 
}

void imgChanged() {
  String i1Label = "Image 1";
  String i2Label = "Image 2";
  if(i1 != null) {
    i1.resize(i1Width, img1.height * i1Width / img1.width);
    i1.copy(img1, 0, 0, img1.width, img1.height, 0, 0, i1Width, img1.height * i1Width / img1.width);
    i1Label = i1Label + ": " + i1.width + "x" + i1.height;
  }
  if(i2 != null) {
    i2.resize(i2Width, img2.height * i2Width / img2.width);
    i2.copy(img2, 0, 0, img2.width, img2.height, 0, 0, i2Width, img2.height * i2Width / img2.width);
    i2Label = i2Label + ": " + i2.width + "x" + i2.height;
  }
  
  if(showFirst) imageLabel.setText(i1Label);
  else imageLabel.setText(i2Label);
  calcScreenScale();
  fixRenderBox();
  fixMarks();
  imgChanged = false;
}

void switchImg() {
  if(i1 != null && i2 != null) {
    PImage tImg = img1.copy();
    img1 = img2.copy();
    img2 = tImg.copy();
    int tWidth = i1Width;
    i1Width = i2Width;
    i2Width = tWidth;
    int tdx = i1dx;
    i1dx = i2dx;
    i2dx = tdx;
    int tdy = i1dy;
    i1dy = i2dy;
    i2dy = tdy;
    for(Mark m: marks) {
      PVector tstart = m.start.copy();
      m.start = m.stop.copy();
      m.stop = tstart.copy();
    }
    imgChanged();
  }
}

void fixRenderBox() {//renderbox inside images
  if(i1 != null) {
    while(renderBoxX - renderBoxW / 2 < i1dx - i1.width / 2) {renderBoxX++; renderBoxW-=2;}
    while(renderBoxY - renderBoxH / 2 < i1dy - i1.height / 2) {renderBoxY++; renderBoxH-=2;}
    while(renderBoxX + renderBoxW / 2 > i1dx + i1.width / 2) {renderBoxX--; renderBoxW-=2;}
    while(renderBoxY + renderBoxH / 2 > i1dy + i1.height / 2) {renderBoxY--; renderBoxH-=2;}
    renderBoxX = min(max(renderBoxX, i1dx - i1.width / 2 + 50), i1dx + i1.width / 2 - 50);
    renderBoxY = min(max(renderBoxY, i1dy - i1.height / 2+ 50), i1dy + i1.height / 2 - 50);
  }
  if(i2 != null) {
    while(renderBoxX - renderBoxW / 2 < i2dx - i2.width / 2) {renderBoxX++; renderBoxW-=2;}
    while(renderBoxY - renderBoxH / 2 < i2dy - i2.height / 2) {renderBoxY++; renderBoxH-=2;}
    while(renderBoxX + renderBoxW / 2 > i2dx + i2.width / 2) {renderBoxX--; renderBoxW-=2;}
    while(renderBoxY + renderBoxH / 2 > i2dy + i2.height / 2) {renderBoxY--; renderBoxH-=2;}
    renderBoxX = min(max(renderBoxX, i2dx - i2.width / 2 + 50), i2dx + i2.width / 2 - 50);
    renderBoxY = min(max(renderBoxY, i2dy - i2.height / 2+ 50), i2dy + i2.height / 2 - 50);
  }
  renderBoxW = max(renderBoxW, 100);
  renderBoxH = max(renderBoxH, 100);
  if(i1 == null) boxLabel.setText("");
  else boxLabel.setText("Render: " + renderBoxW + "x" + renderBoxH);
}

void fixMarks() {//marks inside screen limits
  for(Mark m: marks) {
    m.start.x = min(max(m.start.x, mX(deltaImg / 2)), mX(width - deltaImg / 2));
    m.start.y = min(max(m.start.y, mY(deltaImg / 2)), mY(height - deltaImg / 2));
    m.stop.x = min(max(m.stop.x, mX(deltaImg / 2)), mX(width - deltaImg / 2));
    m.stop.y = min(max(m.stop.y, mY(deltaImg / 2)), mY(height - deltaImg / 2));
  }
}
