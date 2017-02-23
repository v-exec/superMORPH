//kinect class containing 1 kinect object from KinectPV2 and its respective methods
class Kinect {

  //kinect controller
  KinectPV2 myKinect;

  //drawing coordinates for kinect camera displays
  final int kinectDisplayWidth = 512;
  final int kinectDisplayHeight = 424;
  int kinectDisplayX = width - kinectDisplayWidth;
  int kinectDisplayY = height - kinectDisplayHeight - 1;

  //kinect distance render thresholds
  int maxD = 2000; //at 2000, range is 4.5m, returns ~100 grey value
  int minD = 0;  //at 0, range is 50cm, returns ~30 grey value

  //kinect user position data gathering variables
  int userTop = 0;
  int userBottom = 0;
  int userHeight = 0;

  int userLeft = 0;
  int userRight = 0;
  int userWidth = 0;

  //reqired number of non-black pixels adjecent to currently scanned pixel to consider current pixel as substantial
  //using to ignore false positives
  int userVerifier = 50;

  //variables holding position of joints (relative to kinect display image)
  float leftElbowX;
  float leftElbowY;
  float rightElbowX;
  float rightElbowY;

  float leftHandX;
  float leftHandY;
  float rightHandX;
  float rightHandY;

  float leftFootX;
  float leftFootY;
  float rightFootX;
  float rightFootY;

  float handDistance;

  //states whether or not to accept the types of hand gestural input
  boolean rotateGestureLeft = false;
  boolean rotateGestureRight = false;
  boolean zoomGesture = false;

  //constructor left empty
  Kinect () {
  }

  /*
initialize Kinect object, controller, and enable depth and point cloud images
   KinectPV2 constructor expects processing.core.PApplet as parameter
   so, using parameters to give the KinectPV2 object initialization the appropriate parameter
   */

  void init (processing.core.PApplet master) {
    myKinect = new KinectPV2(master);

    myKinect.enableDepthImg(true);
    myKinect.enablePointCloud(true);
    myKinect.enableSkeletonDepthMap(true);

    myKinect.init();
  }

  //get and display point cloud depth image, and set point cloud thersholds
  void displayDepth() {
    image(myKinect.getPointCloudDepthImage(), kinectDisplayX, kinectDisplayY);
    myKinect.setLowThresholdPC(minD);
    myKinect.setHighThresholdPC(maxD);
  }

  //get and display skeleton image, and check for hand gestural input
  void displaySkeleton() {
    ArrayList<KSkeleton> skeletonArray =  myKinect.getSkeletonDepthMap();

    for (int i = 0; i < skeletonArray.size(); i++) {
      KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
      KJoint[] joints = skeleton.getJoints();

      fill(255);
      stroke(255);

      drawBody(joints);
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);

      if (joints[KinectPV2.JointType_HandRight].getState() == KinectPV2.HandState_Closed && joints[KinectPV2.JointType_HandLeft].getState() != KinectPV2.HandState_Closed) {
        rotateGestureRight = true;
        rotateGestureLeft = false;
        zoomGesture = false;
      } else rotateGestureRight = false;

      if (joints[KinectPV2.JointType_HandRight].getState() != KinectPV2.HandState_Closed && joints[KinectPV2.JointType_HandLeft].getState() == KinectPV2.HandState_Closed) {
        rotateGestureRight = false;
        rotateGestureLeft = true;
        zoomGesture = false;
      } else rotateGestureLeft = false;

      if (joints[KinectPV2.JointType_HandRight].getState() == KinectPV2.HandState_Closed && joints[KinectPV2.JointType_HandLeft].getState() == KinectPV2.HandState_Closed) {
        rotateGestureRight = false;
        rotateGestureLeft = false; 
        zoomGesture = true;
      } else zoomGesture = false;
    }
  }

  //gets user height and width in pixels, and distnce from Kinect in greyscale range
  void gatherDepthData() {

    //load pixel array so we can scan through it
    loadPixels();

    /*
 four pixel scan passes, one from each direction, used to determine width and height of user (in theory more efficient than making 1 full scan that constantly checks for the four specific pixels each loop)
     includes false negative verification by seeing if pixel has userVerifier amount of non-black pixels after the current one, this avoids lone random pixels
     also includes annoying break out of nested 'for' loops
     considering trying to make these into function? everything is nearly inversed for each one, so it's a bit complicated. maybe rework algorithm entirely?
     */

    //pass through all pixels in Kinect IR camera image (from left to right) and find first colored pixel on X axis
    for (int i = kinectDisplayX; i < kinectDisplayX + kinectDisplayWidth; i++) {
      boolean broke = false;
      for (int j = kinectDisplayY; j < kinectDisplayY + kinectDisplayHeight; j++) {
        if (grayify(i, j) > 0) {
          for (int k = i; k < i + userVerifier; k++) {
            if (grayify(k, j) < 1) {
              break;
            } else if (k == i + userVerifier - 1) {
              userLeft = i;
              broke = true;
            }
          }
        }
        if (broke) break;
      }
      if (broke) break;
    }

    //pass through all pixels in Kinect IR camera image (from right to left) and find first colored pixel on X axis
    for (int i = kinectDisplayX + kinectDisplayWidth; i > kinectDisplayX + userVerifier; i--) {
      boolean broke = false;
      for (int j = kinectDisplayY; j < kinectDisplayY + kinectDisplayHeight; j++) {
        if (grayify(i, j) > 0) {
          for (int k = i; k > i - userVerifier; k--) {
            if (grayify(k, j) < 1) {
              break;
            } else if (k == i - userVerifier + 1) {
              userRight = i;
              broke = true;
            }
          }
        }
        if (broke) break;
      }
      if (broke) break;
    }

    //pass through all pixels in Kinect IR camera image (from top to bottom) and find first colored pixel on Y axis
    for (int i = kinectDisplayY; i < kinectDisplayY + kinectDisplayHeight; i++) {
      boolean broke = false;
      for (int j = kinectDisplayX; j < kinectDisplayX + kinectDisplayWidth; j++) {
        if (grayify(j, i) > 0) {
          for (int k = i; k < i + userVerifier; k++) {
            if (grayify(j, k) < 1) {
              break;
            } else if (k == i + userVerifier - 1) {
              userTop = i;
              broke = true;
            }
          }
        }
        if (broke) break;
      }
      if (broke) break;
    }

    //pass through all pixels in Kinect IR camera image (from bottom to top) and find first colored pixel on Y axis
    for (int i = kinectDisplayY + kinectDisplayHeight; i > kinectDisplayY + userVerifier; i--) {
      boolean broke = false;
      for (int j = kinectDisplayX; j < kinectDisplayX + kinectDisplayWidth; j++) {
        if (grayify(j, i) > 0) {
          for (int k = i; k > i - userVerifier; k--) {
            if (grayify(j, k) < 1) {
              break;
            } else if (k == i - userVerifier + 1) {
              userBottom = i;
              broke = true;
            }
          }
        }
        if (broke) break;
      }
      if (broke) break;
    }

    //calculate height and width
    userWidth = userRight - userLeft;
    userHeight = userBottom - userTop;

    //reset values
    userLeft = userRight = userTop = userBottom = 0;
  }

  //draw the body skeleton
  void drawBody(KJoint[] joints) {
    //draws bones, purely for show

    //body
    drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
    drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
    drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
    drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
    drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
    drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
    drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
    drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

    //right arm
    drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);

    //left arm
    drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);

    //legs
    drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
    drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);

    //draws joints, used for data gathering

    //arms
    drawJoint(joints, KinectPV2.JointType_ElbowRight);
    drawJoint(joints, KinectPV2.JointType_ElbowLeft);

    rightElbowX = joints[KinectPV2.JointType_ElbowRight].getX();
    rightElbowY = joints[KinectPV2.JointType_ElbowRight].getY();
    leftElbowX = joints[KinectPV2.JointType_ElbowLeft].getX();
    leftElbowY = joints[KinectPV2.JointType_ElbowLeft].getY();

    //hands
    rightHandX = joints[KinectPV2.JointType_HandRight].getX();
    rightHandY = joints[KinectPV2.JointType_HandRight].getY();
    leftHandX = joints[KinectPV2.JointType_HandLeft].getX();
    leftHandY = joints[KinectPV2.JointType_HandLeft].getY();
    handDistance = sqrt(sq(joints[KinectPV2.JointType_HandLeft].getX() - joints[KinectPV2.JointType_HandRight].getX()) + sq(joints[KinectPV2.JointType_HandLeft].getY() - joints[KinectPV2.JointType_HandRight].getY()));

    //feet
    drawJoint(joints, KinectPV2.JointType_FootLeft);
    drawJoint(joints, KinectPV2.JointType_FootRight);

    rightFootX = joints[KinectPV2.JointType_FootRight].getX();
    rightFootY = joints[KinectPV2.JointType_FootRight].getY();
    leftFootX = joints[KinectPV2.JointType_FootLeft].getX();
    leftFootY = joints[KinectPV2.JointType_FootLeft].getY();
  }

  //draw a single joint
  void drawJoint(KJoint[] joints, int jointType) {
    pushMatrix();
    translate(joints[jointType].getX() + kinectDisplayX, joints[jointType].getY() + kinectDisplayY, joints[jointType].getZ());
    ellipse(0, 0, 15, 15);
    popMatrix();
  }

  //draw a bone from two joints
  void drawBone(KJoint[] joints, int jointType1, int jointType2) {
    pushMatrix();
    translate(joints[jointType1].getX() + kinectDisplayX, joints[jointType1].getY() + kinectDisplayY, joints[jointType1].getZ());
    popMatrix();
    line(joints[jointType1].getX() + kinectDisplayX, joints[jointType1].getY() + kinectDisplayY, joints[jointType1].getZ(), joints[jointType2].getX() + kinectDisplayX, joints[jointType2].getY() + kinectDisplayY, joints[jointType2].getZ());
  }

  //draw a ellipse depending on the hand state
  void drawHandState(KJoint joint) {
    if (joint.getState() == KinectPV2.HandState_Closed) {
      fill(255);
    } else fill(0);

    pushMatrix();
    translate(joint.getX() + kinectDisplayX, joint.getY() + kinectDisplayY, joint.getZ());
    ellipse(0, 0, 20, 20);
    popMatrix();
  }

  //scan individual pixels in pixel[] array and convert the RGB return value of each called pixel to 0-255
  int grayify (int x, int y) {
    int c=pixels[x+(y*width)];
    int r=(c&0x00FF0000)>>16;
    int g=(c&0x0000FF00)>>8;
    int b=(c&0x000000FF);
    int grey=(r+b+g)/3;
    return grey;
  }
}