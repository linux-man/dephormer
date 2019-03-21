class Mark {
  PVector start, stop;
  float manualRange, range, rate; 

  Mark() {
    this(0, 0);
  }
  Mark(float x, float y) {
    this(x, y, x, y);
  }
  Mark(float x, float y, float range) {
    this(x, y, x, y, range);
  }
  Mark(float x1, float y1, float x2, float y2) {
    this(x1, y1, x2, y2, 400);
  }
  Mark(float x1, float y1, float x2, float y2, float range) {
    this(x1, y1, x2, y2, range, 6);
  }
  Mark(float x1, float y1, float x2, float y2, float range, float rate) {
    start = new PVector(x1, y1);
    stop = new PVector(x2, y2);
    manualRange = range;
    this.rate = rate;
  }
}
