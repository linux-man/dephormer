int orientation(PVector p, PVector q, PVector r) {
  // See https://www.geeksforgeeks.org/orientation-3-ordered-points/ for details of below formula.
  float val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
  if (val == 0) return 0;  // colinear
  return (val > 0)? 1: 2; // clock or counterclock wise
}

boolean onSegment(PVector p, PVector q, PVector r) {
  if (q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y)) return true;
  return false;
}

boolean doIntersect(PVector p1, PVector p2, PVector q1, PVector q2) {
  //Discard duplicated segments 
  if(PVector.dist(p1, q1) == 0 && PVector.dist(p2, q2) == 0 || PVector.dist(p2, q1) == 0 && PVector.dist(p1, q2) == 0) return true;
  //Ignore segments with one shared vertice
  if(PVector.dist(p1, q1) == 0 || PVector.dist(p1, q2) == 0 || PVector.dist(p2, q1) == 0 || PVector.dist(p2, q2) == 0) return false;
  // Find the four orientations needed for general and special cases, From https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
  int o1 = orientation(p1, p2, q1);
  int o2 = orientation(p1, p2, q2);
  int o3 = orientation(q1, q2, p1);
  int o4 = orientation(q1, q2, p2);

  // General case
  if (o1 != o2 && o3 != o4) return true;
  // Special Cases
  if (o1 == 0 && onSegment(p1, q1, p2)) return true;
  if (o2 == 0 && onSegment(p1, q2, p2)) return true;
  if (o3 == 0 && onSegment(q1, p1, q2)) return true;
  if (o4 == 0 && onSegment(q1, p2, q2)) return true;
  return false; // Doesn't fall in any of the above cases
}

boolean doIntersect(Segment a, Segment b) {
  return doIntersect(a.p1, a.p2, b.p1, b.p2);
}

void calcSegMorph(boolean first, boolean preview) {
  ArrayList<Mark> marksCopy = new ArrayList<Mark>(marks);
  ArrayList<Segment> segments = new ArrayList<Segment>();
  int w, h, dx, dy;
  PVector p1 = new PVector(0, 0);
  PVector v1 = new PVector(0, 0);
  PVector p2 = new PVector(0, 0);
  PVector v2 = new PVector(0, 0);
  PVector dif;
  Segment seg;
  boolean add;
  int delta, fixedLeft, fixedRight, fixedTop, fixedBottom;
  float totalWeight;
  int dxy = 1;
  char i;

  if(first) {
    renderImg = i1.copy();
    originalImg = i1.copy();
    w = i1.width;
    h = i1.height;
    dx = i1dx;
    dy = i1dy;
    i = '1';
  }
  else {
    renderImg = i2.copy();
    originalImg = i2.copy();
    w = i2.width;
    h = i2.height;
    dx = i2dx;
    dy = i2dy;
    i = '2';
  }
  renderingLabel.setText("Calculating Image " + i);

  //add marks on edges
  marksCopy.add(new Mark(-w / 2 + dx, -h / 2 + dy));
  marksCopy.add(new Mark(w / 2 + dx - 1, - h / 2 + dy));
  marksCopy.add(new Mark(-w / 2 + dx, h / 2 + dy - 1));
  marksCopy.add(new Mark(w / 2 + dx - 1, h / 2 + dy - 1));
  segments.clear();

  for(Mark m: marksCopy) {//create segments
    if(first) {p1.set(m.start); v1 = PVector.sub(m.stop, m.start);}
    else {p1.set(m.stop); v1 = PVector.sub(m.start, m.stop);}
    for(Mark mm: marksCopy) {
      if(mm != m) {
        if(first) {p2.set(mm.start); v2 = PVector.sub(mm.stop, mm.start);}
        else {p2.set(mm.stop); v2 = PVector.sub(mm.start, mm.stop);}
        seg = new Segment(p1.copy(), v1.copy(), p2.copy(), v2.copy());
        add = true;
        for(Segment s: segments) {
          if(doIntersect(seg, s) && seg.d >= s.d) add = false;
        }
        if(add) {
          for(int n = segments.size() - 1; n >= 0; n--) {
            if(doIntersect(seg, segments.get(n)) && seg.d < segments.get(n).d) {segments.remove(n);}
          }
          segments.add(seg);
        }
      }
    }
  }
  field = new PVector[w][h];
  for(int y = 0; y < h; y++) for(int x = 0; x < w; x++) {//fill field
    if(y == 0 || x == 0 || y == h - 1 || x == w - 1) field[x][y] = new PVector(0, 0, 1);
    else field[x][y] = new PVector(0, 0, 0);
  }
  for(Segment s: segments) {//create segment vectors
    dif = PVector.sub(s.p2, s.p1);
    if(abs(dif.x) >= abs(dif.y)) {
      for(float n = 0; n <= abs(dif.x); n += 0.5) {
        int x = int(s.p1.x + w / 2 - dx + map(n, 0, abs(dif.x), 0, dif.x));
        int y = int(s.p1.y + h / 2 - dy + map(n, 0, abs(dif.x), 0, dif.y));
        int vX = int(map(n, 0, abs(dif.x), s.v1.x, s.v2.x));
        int vY = int(map(n, 0, abs(dif.x), s.v1.y, s.v2.y));
        try {field[x][y] = new PVector(vX, vY, 1);} catch (Exception e) {};
      }
    }
    else {
      for(float n = 0; n <= abs(dif.y); n += 0.5) {
        int y = int(s.p1.y + h / 2 - dy + map(n, 0, abs(dif.y), 0, dif.y));
        int x = int(s.p1.x + w / 2 - dx + map(n, 0, abs(dif.y), 0, dif.x));
        int vX = int(map(n, 0, abs(dif.y), s.v1.x, s.v2.x));
        int vY = int(map(n, 0, abs(dif.y), s.v1.y, s.v2.y));
        try {field[x][y] = new PVector(vX, vY, 1);} catch (Exception e) {};
      }
    }
  }
  if(preview) dxy = 12;//faster preview
  progressBar.setRange(0, w * h);
  for(int y = 1; y < h - 1; y += dxy) for(int x = 1; x < w - 1; x += dxy) {//fill the rest
    progressBar.setValue(x + y * w);
    if(field[x][y].z == 0) {
      totalWeight = 0;
      delta = 0;
      try {while(field[x - delta][y].z == 0) delta++;} catch (Exception e) {};
      fixedLeft = x - delta;
      totalWeight += (float)1 / delta;
      delta = 0;
      try {while(field[x + delta][y].z == 0) delta++;} catch (Exception e) {};
      fixedRight = x + delta;
      totalWeight += (float)1 / delta;
      delta = 0;
      try {while(field[x][y - delta].z == 0) delta++;} catch (Exception e) {};
      fixedTop = y - delta;
      totalWeight += (float)1 / delta;
      delta = 0;
      try {while(field[x][y + delta].z == 0) delta++;} catch (Exception e) {};
      fixedBottom = y + delta;
      totalWeight += (float)1 / delta;
      field[x][y] = PVector.add(PVector.add(PVector.add(
        PVector.mult(field[fixedLeft][y], min(1, 1 / ((x - fixedLeft) * totalWeight))),
        PVector.mult(field[fixedRight][y], min(1, 1 / ((fixedRight - x) * totalWeight)))),
        PVector.mult(field[x][fixedTop], min(1, 1 / ((y - fixedTop) * totalWeight)))),
        PVector.mult(field[x][fixedBottom], min(1, 1 / ((fixedBottom - y) * totalWeight))));

      field[x][y].z = 0;
      if(preview) {
        for(int sy = -6; sy <= 6; sy++) for(int sx = -6; sx <= 6; sx++) try {if(field[x + sx][y + sy].z == 0) field[x + sx][y + sy].set(field[x][y]);} catch (Exception e) {};
      }
    }
  }
}

void autoRange() {
  for(Mark m: marks) {
    for(Mark mm: marks) if(m != mm) m.range = min(m.range, dist(m.start.x, m.start.y, mm.start.x, mm.start.y));
    if(method == 2) m.range = max(m.range, 6 * dist(m.start.x, m.start.y, m.stop.x, m.stop.y));
    else m.range = max(m.range, 3 * dist(m.start.x, m.start.y, m.stop.x, m.stop.y));
  }
}

float logisticStrength(float distance, float range, float rate) {
  if(distance == 0) return 1;
  if(range == 0 || distance >= range) return 0;
  float norm = - rate * tan(PI * distance / range - HALF_PI);
  return 1 - 1 / (1 + exp(norm));
}

float linearStrength(float distance, float range) {
  return max(1 - distance / range, 0);
}

void calcPointMorph(boolean first) {
  int w, h, dx, dy;
  boolean weighted = calc == 0;
  boolean maxed = calc == 1; 
  boolean summed = calc == 2; 
  float strength = 0;
  float totalWeight = 0;
  float weight = 0;
  float maxMag = 0;
  PVector origin = new PVector(0, 0);
  PVector vec;
  char i;

  if(method == 2 || method == 3) autoRange();
  else for(Mark m: marks) m.range = m.manualRange;

  if(first) {
    renderImg = i1.copy();
    originalImg = i1.copy();
    w = i1.width;
    h = i1.height;
    dx = i1dx;
    dy = i1dy;
    i = '1';
  }
  else {
    renderImg = i2.copy();
    originalImg = i2.copy();
    w = i2.width;
    h = i2.height;
    dx = i2dx;
    dy = i2dy;
    i = '2';
  }
  renderingLabel.setText("Calculating Image " + i);

  field = new PVector[w][h];
  progressBar.setRange(0, w * h);
  for(int y = 0; y < h; y++) for(int x = 0; x < w; x++) {
    progressBar.setValue(x + y * w);
    field[x][y] = new PVector(0, 0);
    if(weighted) {
      totalWeight = 0;
      for(Mark m: marks) {
        if(first) origin = m.start.copy();
        else origin = m.stop.copy();
        if(dist(x - w / 2 + dx, y - h / 2 + dy, origin.x, origin.y) < 3) {totalWeight = 1; break;}
        else totalWeight += 1 / dist(x - w / 2 + dx, y - h / 2 + dy, origin.x, origin.y);
      }
    }
    else if(maxed) maxMag = 0;

    for(Mark m: marks) {
      if(first) {
        origin = m.start.copy();
        vec = PVector.sub(m.stop, m.start);
      }
      else {
        origin = m.stop.copy();
        vec = PVector.sub(m.start, m.stop);
      }
      if (method == 1) strength = 1;
      else if (method == 2 || method == 4) strength = logisticStrength(dist(x - w / 2 + dx, y - h / 2 + dy, origin.x, origin.y), m.range, m.rate);
      else if (method == 3 || method == 5) strength = linearStrength(dist(x - w / 2 + dx, y - h / 2 + dy, origin.x, origin.y), m.range);

      if(weighted) {
        if(dist(x - w / 2 + dx, y - h / 2 + dy, origin.x, origin.y) < 3) weight = 1;
        else weight = min(1, 1 / (dist(x - w / 2 + dx, y - h / 2 + dy, origin.x, origin.y) * totalWeight));
        field[x][y].add(PVector.mult(vec, strength * weight));
      }
      else if(maxed || summed) {
        maxMag = max(maxMag, PVector.mult(vec, strength).mag());
        field[x][y].add(PVector.mult(vec, strength));
      }
    }
    if(maxed) field[x][y].setMag(maxMag);
  }
}

void morph(boolean first, int frames, int steps, float cycles ) {
  int w = renderImg.width;
  int h = renderImg.height;
  char i;
  if(first) i = '1'; else i = '2';
  progressBar.setRange(0, frames);
  renderImg.loadPixels();
  for(int frame = 0; frame <= frames; frame++) {
    renderingLabel.setText("Rendering Image " + i + ": " + frame + " of " + frames);
    progressBar.setValue(frame);
    for(int my = 0; my < h * cycles; my++) for(int mx = 0; mx < w * cycles; mx++) {
      float x = mx / cycles;
      int ix = min(round(x), w - 1);
      float y = my / cycles;
      int iy = min(round(y), h - 1);
      int p = round(x + field[ix][iy].x * frame / frames) + (round(y + field[ix][iy].y * frame / frames) * w);
      if(p < w * h && p >= 0
      && x + field[ix][iy].x * frame / frames < w && y + field[ix][iy].y * frame / frames < h
      && x + field[ix][iy].x * frame / frames >= 0 && y + field[ix][iy].y * frame / frames >= 0)
        renderImg.pixels[p] = originalImg.pixels[ix + iy * w];
    }
    renderImg.updatePixels();
    if(frame % steps == 0) {
      if(first) renderImg.get((renderBoxX - renderBoxW / 2) - (i1dx - i1.width / 2), (renderBoxY - renderBoxH / 2)- (i1dy - i1.height / 2), renderBoxW, renderBoxH).save(String.format(tempPath + "/1%04d.tif", frame / steps));
      else renderImg.get((renderBoxX - renderBoxW / 2) - (i2dx - i2.width / 2), (renderBoxY - renderBoxH / 2)- (i2dy - i2.height / 2), renderBoxW, renderBoxH).save(String.format(tempPath + "/2%04d.tif", (frames - frame) / steps));
    }
  }
}

void mixMorph(int frames, int mixFrames) {
  int maskValue;
  int[] maskArray = new int[renderBoxW * renderBoxH];

  if(mixFrames > frames) mixFrames = frames;
  progressBar.setRange(0, frames - 1);
  for(int frame = 0; frame < frames; frame++) {
    renderingLabel.setText("Mixing Images: " + frame + " of " + (frames - 1));
    progressBar.setValue(frame);
    maskValue = round(max(0, min(1, map(frame, (frames - mixFrames) / 2, frames - (frames - mixFrames) / 2 - 1, 0, 1))) * 255);
    for(int m = 0; m < maskArray.length; m++) maskArray[m] = maskValue;
    originalImg = loadImage(String.format(tempPath + "/1%04d.tif", frame));
    renderImg = loadImage(String.format(tempPath + "/2%04d.tif", frame));
    renderImg.mask(maskArray);
    originalImg.blend(renderImg, 0, 0, renderBoxW, renderBoxH, 0, 0, renderBoxW, renderBoxH, BLEND);
    originalImg.save(String.format(tempPath + "/1%04d.tif", frame));
  }
}

void saveMorph(int frames) {
  PGraphics pg = createGraphics(renderBoxW, renderBoxH);
  VideoExport videoExport = new VideoExport(dephormer.this, videoPath, pg);
  progressBar.setRange(0, frames - 1);
  if(renderVideo) {
    videoExport.setDebugging(false);
    videoExport.setFrameRate(fps);
    videoExport.startMovie();
  }
  for(int frame = 0; frame < frames; frame++) {
   renderingLabel.setText("Saving Images: " + frame + " of " + (frames - 1));
   progressBar.setValue(frame);
   renderImg = loadImage(String.format(tempPath + "/1%04d.tif", frame));
    if(renderImages) renderImg.save(String.format(imagesPath, frame));
    if(renderVideo) {
      pg.beginDraw();
      pg.loadPixels();
      pg.pixels = renderImg.pixels;
      pg.updatePixels();
      pg.endDraw();
      videoExport.saveFrame();
    }
  }
  if(renderVideo) videoExport.endMovie();
}
