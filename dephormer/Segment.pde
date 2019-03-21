class Segment {
  PVector p1, v1, p2, v2;
  float d; 

  Segment(PVector p1, PVector v1, PVector p2, PVector v2) {
    this.p1 = p1;
    this.v1 = v1;
    this.p2 = p2;
    this.v2 = v2;
    d = PVector.dist(p1, p2);
  }
}
