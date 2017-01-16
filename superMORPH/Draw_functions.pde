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
  kin.displayDepth();
  kin.gatherDepthData();
  kin.displaySkeleton();

  //keyboard input for shape manipulation (FOR TESTING)
  if (keyPressed) {
    shape.controlSupershape();
    shape.refreshRandomizer = false;
  }

  //camera manipulation + supershape rendering
  shape.displaySupershape();
}

//drives shape parameters using gathered kinect data
void superMORPH() {
  //camera controls with Kinect
  //check which hand is controlling camera
  if (kin.zoomGesture && zoomGestureCheck == false) {

    currentCameraZ = shape.cameraDistance;
    currentHandDist = kin.handDistance;
    leftGestureCheck = false;
    rightGestureCheck = false;
    zoomGestureCheck = true;
  } else if (kin.rotateGestureLeft && leftGestureCheck == false) {

    currentHandX = kin.leftHandX;
    currentHandY = kin.leftHandY;
    currentCameraX = shape.cameraX;
    currentCameraY = shape.cameraY;
    leftGestureCheck = true;
    rightGestureCheck = false;
    zoomGestureCheck = false;
  } else if (kin.rotateGestureRight && rightGestureCheck == false) {

    currentHandX = kin.rightHandX;
    currentHandY = kin.rightHandY;
    currentCameraX = shape.cameraX;
    currentCameraY = shape.cameraY;
    leftGestureCheck = false;
    rightGestureCheck = true;
    zoomGestureCheck = false;
  }

  //reset gesture checks if no hands controlling camera
  if (kin.rotateGestureLeft == false && kin.rotateGestureRight == false && kin.zoomGesture == false) {
    leftGestureCheck = false;
    rightGestureCheck = false;
    zoomGestureCheck = false;
    controlling = false;
  }

  //control camera with designated hand
  if (leftGestureCheck) {
    shape.newCameraX = currentCameraX + (kin.leftHandX - currentHandX) * 2;
    shape.newCameraY = currentCameraY + (kin.leftHandY - currentHandY) * 4;
    controlling = true;
  } else if (rightGestureCheck) {
    shape.newCameraX = currentCameraX + (kin.rightHandX - currentHandX) * 2;
    shape.newCameraY = currentCameraY + (kin.rightHandY - currentHandY) * 4;
    controlling = true;
  } else if (zoomGestureCheck) {
    shape.cameraDistance = currentCameraZ + (kin.handDistance - currentHandDist) * 10;
    controlling = true;
  }

  if (controlling == false) {
    //morph shape using kinect input
    shape.newLonM1 = map(kin.leftFootX, 0, 509, 0, 30);
    shape.newLatM1 = map(kin.leftFootY, 0, 420, 0, 30);

    shape.newLonA = map(kin.leftHandY, 0, 420, 0.1, 2);
    shape.newLonB = map(kin.rightHandY, 0, 420, 0.1, 2);
    shape.newLonM1 = map(kin.rightFootX, 0, 509, 0, 50);
    shape.newLonM2 = map(kin.leftHandX, 0, 509, 0, 50);
    shape.newLonN1 = map(kin.userWidth, 0, 509, 5, 10);
    shape.newLonN2 = map(kin.leftElbowX, 0, 509, -10, 10);
    shape.newLonN3 = map(kin.leftElbowY, 0, 420, -10, 10);

    shape.newLatA = map(kin.leftFootY, 0, 420, 0, 50);
    shape.newLatB = map(kin.rightFootY, 0, 420, 0, 50);
    shape.newLatM1 = map(kin.leftFootX, 0, 509, 0, 50);
    shape.newLatM2 = map(kin.rightHandX, 0, 509, 0, 50);
    shape.newLatN1 = map(kin.userHeight, 0, 420, 1, 10);
    shape.newLatN2 = map(kin.rightElbowX, 0, 509, -10, 10);
    shape.newLatN3 = map(kin.rightElbowY, 0, 420, -10, 10);
  }
}