class Render extends Thread{
  int duration, fps, steps, frames;
  float cycles;

  public Render(int duration, int fps, int steps, float cycles){
    this.duration = duration;
    this.fps = fps;
    this.steps = steps;
    this.cycles = cycles;
    frames = (duration * fps - 1) * steps;
  }
  
  public void run() {
    if(method == 0) calcSegMorph(true, false);
    else calcPointMorph(true);
    morph(true, frames, steps, cycles);    
    if(i2 != null) {
      if(method == 0) calcSegMorph(false, false);
      else calcPointMorph(false);
      morph(false, frames, steps, cycles);
      mixMorph(duration * fps, mixDuration * fps);
    }
    saveMorph(duration * fps);
    hide = false;
    menuGroup.setVisible(true);
    footerGroup.setVisible(true);
    renderingGroup.setVisible(false);
    renderMsgBox.setVisible(false);
  }

}
