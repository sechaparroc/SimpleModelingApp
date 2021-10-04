import nub.core.*;
import nub.primitives.*;
import nub.processing.*;
import nub.timing.*;
import java.util.function.BiFunction;

MainArea mainArea;
ShapeSelectionArea shapeSelectionArea;
ColorSelectionArea colorSelectionArea;
InteractiveArea currentArea = null;

void settings(){
  size(1400,800, P3D);
}

void setup(){
  colorSelectionArea = new ColorSelectionArea(this, 0, 0, width, height / 6);
  shapeSelectionArea = new ShapeSelectionArea(this, 0, height - height / 6, width, height / 6);
  mainArea = new MainArea(this, shapeSelectionArea, colorSelectionArea,0, height / 6, width, height - height / 3);
  currentArea = mainArea;
}

void draw(){
  mainArea.display();
  colorSelectionArea.display(color(150));
  shapeSelectionArea.display(color(150), colorSelectionArea.currentColor);
}

void mouseClicked(MouseEvent event){
  currentArea.mouseClicked(event);
}

void mouseMoved() {
  updateCurrentArea();
  currentArea.mouseMoved();
}

void mousePressed(){
  currentArea.mousePressed();
}

void mouseReleased(){
  currentArea.mouseReleased();
}

void mouseDragged() {
  currentArea.mouseDragged();
}

void mouseWheel(MouseEvent event) {
  currentArea.mouseWheel(event);
}

void updateCurrentArea(){
  if(shapeSelectionArea.scene.hasFocus())
    currentArea = shapeSelectionArea;
  else if(colorSelectionArea.scene.hasFocus())
    currentArea = colorSelectionArea;
  else
    currentArea = mainArea;
}

public void keyPressed(){
  if(key == '1'){
    mainArea.mode = MainArea.Mode.SHAPESELECTION;
    mainArea.resetGizmos();
  }
  else if(key == '2'){
    mainArea.mode = MainArea.Mode.SCALING_GIZMO;
    mainArea.resetGizmos();
  }
  else if(key == '3'){
    mainArea.mode = MainArea.Mode.TRANSLATION_GIZMO;
    mainArea.resetGizmos();
  }
  else if(key == '4'){
    mainArea.mode = MainArea.Mode.ROTATION_GIZMO;
    mainArea.resetGizmos();
  }
  else if(key == 'k' || key == 'K'){
    mainArea.savePosture();
  }
  else if(key == ' '){
    mainArea.play();
  }
  else if(key == 'a' || key == 'A'){
    mainArea.extrusionMode = MainArea.ExtrusionMode.DEEPCLONE;
  }
  else if(key == 's' || key == 'S'){
    mainArea.extrusionMode = MainArea.ExtrusionMode.CURRENTSHAPE;
  }
  else if(key == 'd' || key == 'D'){
    mainArea.extrusionMode = MainArea.ExtrusionMode.DUPLICATE;
  }
  else if(key == 'r' || key == 'R'){
    Component.drawReferenceConnection = !Component.drawReferenceConnection;
  }
}
