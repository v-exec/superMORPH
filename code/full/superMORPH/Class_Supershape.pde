//supershape class that deals with supershape generation, display, and animation
class Supershape {

  //camera controls
  float cameraDistance = -650;
  float cameraX;
  float cameraY;
  float newCameraX;
  float newCameraY;
  float cameraControlResolution = 1000;
  float cameraEasing = 0.1;

  //number of vertices in the shape (resolution) (anything above 200 gets laggy)
  int total = 120;

  //two dimentional array that stores x,y,z values for all latitude and longitude vertices
  PVector[][] globe = new PVector[total+1][total+1];

  //radius of supershape
  float r = 200;

  //r1 parameters
  //point extrusion (0.1 - 2)
  float lonA = 1;
  //point extrusion (0.1 - 2)
  float lonB = 1;
  //number of points (0 - 50)
  float lonM1 = 0;
  //number of subdivisions (0 - 50)
  float lonM2 = 0;
  //point fold sharpness (5 - 10)
  float lonN1 = 1;
  //point sharpness (-10 - 10)
  float lonN2 = 1;
  //point sharpness (-10 - 10)
  float lonN3 = 1;

  //r2 parameters
  //layer extrusion (1 - 2)
  float latA = 1;
  //layer extrusion (0.1 - 2)
  float latB = 1;
  //number of layers (0 - 50)
  float latM1 = 0;
  //number of subdivisions (0 - 50)
  float latM2 = 0;
  //layer fold sharpness (1 - 10)
  float latN1 = 1;
  //outer layer sharpness (-10 - 10)
  float latN2 = 1;
  //inner layer sharpness (-10 - 10)
  float latN3 = 1;

  //parameter easing
  float easing = 0.1;
  //new r1 parameters
  float newLonA = 0.1;
  float newLonB = 1.0;
  float newLonM1 = 10;
  float newLonM2 = 10;
  float newLonN1 = 7.3;
  float newLonN2 = -3.6;
  float newLonN3 = 3.2;
  //new r2 parameters
  float newLatA = 1;
  float newLatB = 0.4;
  float newLatM1 = 11.4;
  float newLatM2 = 11.4;
  float newLatN1 = 2.2;
  float newLatN2 = -3.82;
  float newLatN3 = 3;

  boolean refreshRandomizer = true;

  //font for formula display
  PFont formulaFont;

  //constructor left empty
  Supershape() {
  }

  //assigns retrived font to the formulaFont attribute
  void getFont(PFont font) {
    formulaFont = font;
  }

  //creates 2D supershape
  float makeSupershape (float theta, float m1, float m2, float n1, float n2, float n3, float a, float b) {
    float t1 = abs((1/a)*cos(m1 / 4 * theta));
    t1 = pow(t1, n2);
    float t2 = abs((1/b)*sin(m2/ 4 * theta));
    t2 = pow(t2, n3);
    float t3 = t1 + t2;
    float r = pow(t3, - 1 / n1);
    return r;
  }

  //generates 3D supershape
  void generateSupershape() {
    //run through latitude vertices
    for (int i = 0; i < total+1; i++) {
      //map the latitude to sphere
      float lat = map(i, 0, total, -HALF_PI, HALF_PI);
      //r2 = latitude of supershape
      float r2 = makeSupershape(lat, latM1, latM2, latN1, latN2, latN3, latA, latB);

      //run through longitude vertices
      for (int j = 0; j < total+1; j++) {
        //map the longitude to sphere
        float lon = map(j, 0, total, -PI, PI);
        //r1 = longitude of supershape
        float r1 = makeSupershape(lon, lonM1, lonM2, lonN1, lonN2, lonN3, lonA, lonB);

        //create xyz coordinates
        float x = r * r1 * cos(lon) * r2 * cos(lat);
        float y = r * r1 * sin(lon) * r2 * cos(lat);
        float z = r * r2 * sin(lat);
        //create vector from xyz for globe vertices
        globe[i][j] = new PVector(x, y, z);
      }
    }
  }

  //renders supershape
  void renderSupershape() {
    noStroke();
    colorMode(HSB);

    for (int i = 0; i < total; i++) {
      //filling supershape vertices with triangle strip faces
      beginShape(TRIANGLE_STRIP);
      for (int j = 0; j < total+1; j++) {
        //hue mapping
        float hu = map(j, 0, total, 0, 255);
        fill(hu, 150, 255);

        //draws first vertex
        PVector v1 = globe[i][j];
        //vertex one xyz coordinates
        vertex(v1.x, v1.y, v1.z);
        //draws second vertex, incementing latitude to create triangle frame
        PVector v2 = globe[i+1][j];
        //vertex two xyz coordinates
        vertex(v2.x, v2.y, v2.z);
      }
      //end triangle strip
      endShape();
    }
    colorMode(RGB);
  }

  //eases a value between it and a target value
  float ease(float x, float target, float easing) {  
    float dx = target - x;
    x += dx * easing;
    return x;
  }

  //draws live formula on screen
  void formula() {
    textAlign(CENTER, CENTER);
    fill(255);

    textFont(formulaFont, 50);
    text("r1 = (cos( ("+nf(lonM1, 2, 2)+" /4) /"+nf(lonA, 1, 2)+")  " + "   + (sin( ("+nf(lonM2, 2, 2)+"/4) /"+nf(lonB, 1, 2)+")  " + "  )"+"", width/2, height-90);

    textFont(formulaFont, 30);
    text(nf(lonN2, 1, 2), width/2-5, height-95);
    text(nf(lonN3, 1, 2), width/2+350, height-95);
    text("-1/"+ nf(lonN1, 1, 2), width/2+415, height-95);

    textFont(formulaFont, 50);
    text("r2 = (cos( ("+nf(latM1, 2, 2)+" /4) /"+nf(latA, 1, 2)+")  " + "   + (sin( ("+nf(latM2, 2, 2)+"/4) /"+nf(latB, 1, 2)+")  " + "  )"+"", width/2, height-50);

    textFont(formulaFont, 30);
    text(nf(latN2, 1, 2), width/2-5, height-55);
    text(nf(latN3, 1, 2), width/2+350, height-55);
    text("-1/"+ nf(latN1, 1, 2), width/2+415, height-55);
  }

  //generates and renders supershape with eased camera controls
  void displaySupershape() {
    pushMatrix();

    //move matrix to translate and rotate supershape
    translate(width/2, height/2, cameraDistance);
    rotateX(map(cameraY, 0, cameraControlResolution, PI/1.7, -PI/1.7)); 
    rotateY(map(cameraX, 0, cameraControlResolution, 0, TWO_PI));
    rotateZ(PI + HALF_PI);

    //generates and renders supershape
    generateSupershape();
    renderSupershape();

    //FOR TESTING
    //newCameraX = mouseX;
    //newCameraY = mouseY;

    //ease camera movement
    cameraX = ease(cameraX, newCameraX, cameraEasing);
    cameraY = ease(cameraY, newCameraY, cameraEasing);

    //ease r1 paramteres
    lonA = ease(lonA, newLonA, easing);
    lonB = ease(lonB, newLonB, easing);
    lonM1 = ease(lonM1, newLonM1, easing);
    lonM2 = ease(lonM2, newLonM2, easing);
    lonN1 = ease(lonN1, newLonN1, easing);
    lonN2 = ease(lonN2, newLonN2, easing);
    lonN3 = ease(lonN3, newLonN3, easing);
    //ease r2 parameters
    latA = ease(latA, newLatA, easing);
    latB = ease(latB, newLatB, easing);
    latM1 = ease(latM1, newLatM1, easing);
    latM2 = ease(latM2, newLatM2, easing);
    latN1 = ease(latN1, newLatN1, easing);
    latN2 = ease(latN2, newLatN2, easing);
    latN3 = ease(latN3, newLatN3, easing);
    popMatrix();

    //display superformula on screen
    formula();
  }

  //handles keyboard controls (FOR TESTING)
  void controlSupershape() {
    switch (key) {
      //------------------------------r1
    case '1':
      if (newLonA < 2) newLonA += 0.05;
      break;

    case 'q':
      if (newLonA > 0.1) newLonA -= 0.05;
      break;

    case '2':
      if (newLonB < 2) newLonB += 0.05;
      break;

    case 'w':
      if (newLonB > 0.1) newLonB -= 0.05;
      break;

    case '3':
      if (newLonM1 < 50) newLonM1 += 0.5;
      break;

    case 'e':
      if (newLonM1 > 0) newLonM1 -= 0.5;
      break;

    case 'a':
      if (newLonM2 < 50) newLonM2 += 0.5;
      break;

    case 'z':
      if (newLonM2 > 0) newLonM2 -= 0.5;
      break;

    case '4':
      if (newLonN1 < 10) newLonN1 += 0.5;
      break;

    case 'r':
      if (newLonN1 > 5) newLonN1 -= 0.5;
      break;

    case '5':
      if (newLonN2 < 10) newLonN2 += 0.5;
      break;

    case 't':
      if (newLonN2 > -10) newLonN2 -= 0.5;
      break;

    case '6':
      if (newLonN3 < 10) newLonN3 += 0.5;
      break;

    case 'y':
      if (newLonN3 > -10) newLonN3 -= 0.5;
      break;

      //------------------------------r2
    case '7':
      if (newLatA < 2) newLatA += 0.05;
      break;

    case 'u':
      if (newLatA > 1) newLatA -= 0.05;
      break;

    case '8':
      if (newLatB < 2) newLatB += 0.05;
      break;

    case 'i':
      if (newLatB > 0.1) newLatB -= 0.05;
      break;

    case '9':
      if (newLatM1 < 50) newLatM1 += 0.5;
      break;

    case 'o':
      if (newLatM1 > 0) newLatM1 -= 0.5;
      break;

    case 's':
      if (newLatM2 < 50) newLatM2 += 0.5;
      break;

    case 'x':
      if (newLatM2 > 0) newLatM2 -= 0.5;
      break;

    case '0':
      if (newLatN1 < 10) newLatN1 += 0.5;
      break;

    case 'p':
      if (newLatN1 > 1) newLatN1 -= 0.5;
      break;

    case '-':
      if (newLatN2 < 10) newLatN2 += 0.5;
      break;

    case '[':
      if (newLatN2 > -10) newLatN2 -= 0.5;
      break;

    case '=':
      if (newLatN3 < 10) newLatN3 += 0.5;
      break;

    case ']':
      if (newLatN3 > -10) newLatN3 -= 0.5;
      break;

      //randomize
    case ' ':
      if (refreshRandomizer) {
        //set random values for new r1 parameters
        newLonA = random(0.1, 2);
        newLonB = random(0.1, 2);
        newLonM1 = round(random(0, 50));
        newLonM2 = round(random(0, 50));
        newLonN1 = random(5, 10);
        newLonN2 = random(-10, 10);
        newLonN3 = random(-10, 10);
        //set random values for new r2 parameters
        newLatA = random(1, 2);
        newLatB = random(0.1, 2);
        newLatM1 = round(random(0, 50));
        newLatM2 = round(random(0, 50));
        newLatN1 = random(1, 10);
        newLatN2 = random(-10, 10);
        newLatN3 = random(-10, 10);
      }
      break;
    }
  }
}