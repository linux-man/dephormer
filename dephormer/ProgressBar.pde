class ProgressBar extends Controller<ProgressBar> {
 
  public ProgressBar(ControlP5 theControlP5, String theName) {
    super(theControlP5, theName);
 
    setView(new ControllerView<ProgressBar>() {
      public void display(PGraphics pg, ProgressBar c) {
        pg.fill(!isMouseOver() ? c.getColor().getForeground():c.getColor().getActive());
        pg.rect(0, 0, c.getWidth(), c.getHeight());
 
        float val = map(c.getValue(),c.getMin(), c.getMax(), 0, c.getWidth()); 
        pg.fill(255);
        pg.rect(0, 0, val, c.getHeight());
      }
    }
    );
  }
 
  public ProgressBar setValue(float theValue) {
    return super.setValue(constrain(theValue, getMin(), getMax()));
  }
 
  public ProgressBar setRange(int theStart, int theEnd) {
    _myMin = theStart;
    _myMax = theEnd;
    return this;
  }
}
