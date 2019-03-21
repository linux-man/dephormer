import drop.*;

SDrop drop;

void initDrop() {
  drop = new SDrop(this);
}

void dropEvent(DropEvent dropEvt) {
  if(hide) return;
  if(dropEvt.isFile()) {
    File file = dropEvt.file();
    if(file != null && file.isFile()){
      String path = file.getPath();
      if(path.endsWith(".mor") && i1!= null) loadMorph(file);
      else insertMedia(file);
    }
  }
}
