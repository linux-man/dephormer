/*
Dephormer is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Dephormer is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Dephormer.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
Method
0 - Segment
1 - Constant
2 - Logistic Auto
3 - Linear Auto
4 - Logistic Manual
5 - Linear Manual

Calc
0 - Weight
1 - Max
2 - Sum

(x, y) Marks coords
(px, py) field coords
px = x - w / 2 + dx
py = y - h / 2 + dy
x = px + w / 2 - dx
y = py + h / 2 - dy
*/

import com.hamoid.*;
Render render;

PImage img1, img2, i1, i2, renderImg, originalImg;
PImage[] previewImg;

int method = 0;
int calc = 0;
int duration = 3;
int mixDuration = 3;
int fps = 25;
int steps = 2;
float cycles = 1;
boolean renderVideo = true;
boolean renderImages = false;

boolean hide = false;
boolean preview = false;
String imagesPath, videoPath, tempPath, morphPath, path;

int moving = -1;

boolean renderBox = false;
int renderBoxX, renderBoxY, renderBoxW, renderBoxH;

//images
boolean showFirst = true;
boolean imgChanged = false;
boolean showTransp = false;
int deltaImg = 100;
int i1Width, i2Width, i1dx, i1dy, i2dx, i2dy;
float screenScale;

ArrayList<Mark> marks = new ArrayList<Mark>();
PVector[][] field;

void setup() {
  size(800, 600);
  imageMode(CENTER);
  rectMode(CENTER);
  makeResizable();

  initP5();
  initDrop();

  init();
}

void draw() {
  background(0);

  if(preview) {
    image(previewImg[int(previewSlider.getValue())], sX(renderBoxX), sY(renderBoxY), renderBoxW * screenScale, renderBoxH * screenScale);
    return;//Stops here if previewing
  }

  if(imgChanged) imgChanged();

  if(showFirst) {//draw images
    if(showTransp) {
      if(i2 != null) image(i2, sX(i2dx), sY(i2dy), i2.width * screenScale, i2.height * screenScale);
      tint(255, 192);
    }
    if(i1 != null) image(i1, sX(i1dx), sY(i1dy), i1.width * screenScale, i1.height * screenScale);
  }
  else {
    if(showTransp) {
      if(i1 != null) image(i1, sX(i1dx), sY(i1dy), i1.width * screenScale, i1.height * screenScale);
      tint(255, 192);
    }
    if(i2 != null) image(i2, sX(i2dx), sY(i2dy), i2.width * screenScale, i2.height * screenScale);
  }
  noTint();
  stroke(255, 192);
  noFill();
/*//screen limits
  line(deltaImg / 2, 0, deltaImg / 2, height);
  line(width - deltaImg / 2, 0, width - deltaImg / 2, height);
  line(0, deltaImg / 2, width, deltaImg / 2);
  line(0, height - deltaImg / 2, width, height - deltaImg / 2);
*/
  if(i1 != null) rect(sX(i1dx), sY(i1dy), i1.width * screenScale, i1.height * screenScale);//draw image boxes
  if(i2 != null) rect(sX(i2dx), sY(i2dy), i2.width * screenScale, i2.height * screenScale);

  stroke(255, 0, 0);
  if(i1 != null) rect(sX(renderBoxX), sY(renderBoxY), renderBoxW * screenScale , renderBoxH * screenScale);//draw render box

  if(hide) return; //Stops here if rendering

  stroke(255, 192);
  if(renderBox) {//draw render box marks
    if(mouseOver(renderBoxX, renderBoxY)) fill(255, 0, 0, 128);
    else fill(128, 0, 0, 128);
    ellipse(sX(renderBoxX), sY(renderBoxY), 20, 20);
    if(mouseOver(renderBoxX + renderBoxW / 2, renderBoxY + renderBoxH / 2)) fill(255, 0, 0, 128);
    else fill(128, 0, 0, 128);
    ellipse(sX(renderBoxX + renderBoxW / 2), sY(renderBoxY + renderBoxH / 2), 20, 20);
  }
  else {//draw marks
    for(Mark m: marks) {
      if(mouseOver(m.start.x, m.start.y)) {
        if((method == 2 || method == 4) && keyPressed && keyCode == CONTROL) {//draw smooth curve
          stroke(255);
          int hsig = 1;
          if(sX(m.start.x) > width / 2) hsig = -1;
          int vsig = 1;
          if(sY(m.start.y) > height / 4) vsig = -1;
          for(int n = 0; n < m.manualRange; n++) {
            line(sX(m.start.x) + hsig * n * screenScale, sY(m.start.y), sX(m.start.x) + hsig * n * screenScale, sY(m.start.y) + vsig * logisticStrength(n, m.manualRange, m.rate) * m.manualRange / 4 * screenScale);
          }
        }
        fill(0, 170, 255, 128);//hover mark
      }
      else fill(0, 45, 90, 128);//normal color
      stroke(255, 192);
      ellipse(sX(m.start.x), sY(m.start.y), 20, 20);
      if(m.start.dist(m.stop) > 0) {
        fill(255, 116, 217, 128);
        line(sX(m.start.x), sY(m.start.y), sX(m.stop.x), sY(m.stop.y));
        ellipse(sX(m.stop.x), sY(m.stop.y), 20, 20);
      }
      
      if(method == 4 || method == 5) {
        noFill();
        ellipse(sX(m.start.x), sY(m.start.y), 2 * m.manualRange * screenScale, 2 * m.manualRange * screenScale);
      }
    }
  }
}

void mouseClicked(MouseEvent evt) {
  if(hide) return;
  boolean over = false;
  if (i1 != null && evt.getCount() == 2) {//Double click
    for(Mark m: marks) {
      if(mouseOver(m.start.x, m.start.y)) {
        marks.remove(m);
        over = true;
        break;
      }
    }
    if (!over) marks.add(new Mark(mX(mouseX), mY(mouseY)));
  }
}

void mousePressed() {
  if(hide) return;
  moving = -1;//move image
  if(renderBox) {
    if(mouseOver(renderBoxX, renderBoxY)) moving = -2;//move center
    if(mouseOver(renderBoxX + renderBoxW / 2, renderBoxY + renderBoxH / 2)) moving = -3;//move corner
  }
  else for(Mark m: marks) if(mouseOver(m.start.x, m.start.y)) moving = marks.indexOf(m);//move mark
}

void mouseDragged() {
  if(hide) return;
  if(moving == -2) {
    renderBoxX = min(max(mX(mouseX), mX(deltaImg / 2)), mX(width - deltaImg / 2));
    renderBoxY = min(max(mY(mouseY), mY(deltaImg / 2)), mY(height - deltaImg / 2));
    fixRenderBox();
  }
  else if(moving == -3) {
    renderBoxW = max((min(mX(mouseX) - renderBoxX, mX(width - deltaImg / 2) - renderBoxX)) * 2, 100);
    renderBoxH = max((min(mY(mouseY) - renderBoxY, mY(height - deltaImg / 2) - renderBoxY)) * 2, 100);
    fixRenderBox();
  }
  else if(moving >= 0) {
    Mark m = marks.get(moving);
    if(mouseButton == LEFT) {//move start mark
      float mx = min(max(mX(mouseX), mX(deltaImg / 2)), mX(width - deltaImg / 2));
      float my = min(max(mY(mouseY), mY(deltaImg / 2)), mY(height - deltaImg / 2));
      m.stop = m.stop.add(PVector.sub(new PVector(mx, my), m.start));
      m.start.x = mx;
      m.start.y = my;
    }
    else {//move stop mark
      m.stop.x = min(max(mX(mouseX), mX(deltaImg / 2)), mX(width - deltaImg / 2));
      m.stop.y = min(max(mY(mouseY), mY(deltaImg / 2)), mY(height - deltaImg / 2));
    }
  }
  else if(mouseButton == LEFT) {
    if(showFirst) {
      i1dx += (mouseX - pmouseX) / screenScale;
      i1dy += (mouseY - pmouseY) / screenScale;
      i1dx = min(max(i1dx, mX(deltaImg / 2)), mX(width - deltaImg / 2));
      i1dy = min(max(i1dy, mY(deltaImg / 2)), mY(height - deltaImg / 2));
    }
    else {
      i2dx += (mouseX - pmouseX) / screenScale;
      i2dy += (mouseY - pmouseY) / screenScale;
      i2dx = min(max(i2dx, mX(deltaImg / 2)), mX(width - deltaImg / 2));
      i2dy = min(max(i2dy, mY(deltaImg / 2)), mY(height - deltaImg / 2));
    }
    imgChanged = true;//call imgChanged() on draw
  }
}

void mouseReleased() {
  if(hide) return;
  moving = -1;
}

void mouseWheel(MouseEvent event) {
  if(hide) return;
  boolean overMark = false;
  for(Mark m: marks) {
    if(mouseOver(m.start.x, m.start.y)) {
      if((method == 2 || method == 4) && keyPressed && keyCode == CONTROL) m.rate = min(max(m.rate + event.getCount() / 10.0, 0.1), 12);//change smooth curve
      else if(method == 4 || method == 5) m.manualRange = max(m.manualRange + event.getCount(), 0);//change range
      overMark = true;
      break;
    }
  }
  if(!overMark) {//resize images
    if(showFirst && i1 != null) i1Width = max(i1Width + event.getCount(), 100);
    else if(i2 != null) i2Width = max(i2Width + event.getCount(), 100);
    imgChanged = true;
  }
}

void keyPressed() {
  if (keyCode == 27) key = 0;

  if(preview) {
    if(keyCode == LEFT) previewSlider.setValue(previewSlider.getValue() - 1);
    if(keyCode == RIGHT) previewSlider.setValue(previewSlider.getValue() + 1);
  }
  else {
    if(hide) return;
    if(key == ' ') {
      if(i1 == null) showFirst = true;
      else showFirst = !showFirst;
      imgChanged();
    }
    if(keyCode == 'T') showTransp = !showTransp;
    if(keyCode == 'B' && i1 != null) renderBox = !renderBox;
    if(keyCode == 'S') switchImg();
    if(keyCode == '2') {
      img2 = null;
      i2 = null;
      showFirst = true;
      imgChanged();
    }
    if(keyCode == '0') marks.clear();
  }
}
