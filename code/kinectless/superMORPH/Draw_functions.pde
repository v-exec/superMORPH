//displays title screen that fades if "enter" is pressed
void title(PFont font) {
  fill(0, transparency);
  rect(0, 0, width, height);

  fill(255, transparency);
  textFont(font, 50);
  textAlign(CENTER, CENTER);
  text("superMORPH", width/2, height/2 -100); 
  text("CART 253 Final Project", width/2, height/2 -50);
  text("Victor Ivanov and Sarah Lauzon", width/2, height/2);
  text("Press 'Enter'", width/2, height/2 + 50);

  if (key == ENTER) {
    isFading = true;
  }

  if (isFading) transparency -= 3;
}

//displays kinect depth map and skeleton, gathers user data, and outputs supershape
void displays() {
  //keyboard input for shape manipulation (FOR TESTING)
  if (keyPressed) {
    shape.controlSupershape();
    shape.refreshRandomizer = false;
  }

  //camera manipulation + supershape rendering
  shape.displaySupershape();
}