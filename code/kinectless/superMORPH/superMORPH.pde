//start screen variables
float transparency = 255;
boolean isFading = false;
PFont myFont;

//camera control variables
boolean leftGestureCheck = false;
boolean rightGestureCheck = false;
boolean zoomGestureCheck = false;
boolean controlling = false;
float currentHandX = 0;
float currentHandY = 0;
float currentHandDist = 0;
float currentCameraX = 0;
float currentCameraY = 0;
float currentCameraZ = 0;

//supershape object
Supershape shape = new Supershape();

void setup() {
  size(1800, 950, P3D);
  smooth(4);
  frameRate(60);

  //get font
  myFont = loadFont("FixedSystem.vlw");

  //get font used for formula
  shape.getFont(myFont);
}

void draw() {
  background(0);

  //displays kinect images, gathers user data, and outputs supershape
  displays();

  //title screen
  if (transparency > 0) title(myFont);
}

//mousewheel event that zooms in/out of shape (FOR TESTING)
void mouseWheel(MouseEvent event) {
  shape.cameraDistance += (event.getCount() * 20);
}

//resets refresher, allowing shape to be re-randomized (FOR TESTING)
void keyReleased() {
  shape.refreshRandomizer = true;
}