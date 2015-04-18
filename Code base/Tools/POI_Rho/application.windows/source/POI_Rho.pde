PImage img;
int noOfImages = 50;
int imagePadding = 25;
boolean drawFirstBatch = false;
int[] pointOfInterest = new int[2];
String path = "originals/";
int[] rhoList1 = {0,4,9,15,22,30,39,49,60,72,85,99,114,130,147,165};
int[] rhoList2 = {0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,85,80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155,160,165};
int[] rhoList3 = {0,4,15,30,49,72,99,130,165};

// Setup
void setup()
{ 
  // Coloring for circles
  noFill();
  stroke(255,0,0);
  strokeWeight(3);
  // Setting drawing of ellipse to Radius
  ellipseMode(RADIUS);
  // Initialization of image.
  img = loadImage(path+"symbol001.jpg");
  // Setting size according to image dimensions
  size(img.width+imagePadding*2, img.height+imagePadding*2);
  // Setting point of interest
  pointOfInterest[0] = img.width/2+imagePadding;
  pointOfInterest[1] = img.height/2+imagePadding;
}

// Draw
void draw()
{
  // Reseting background
  background(150);
  // Drawing image on screen
  image(img,0+imagePadding,0+imagePadding);
  // Marking point of interest
  markPointOfInterest();
  // Drawing the list of concentric circles
  drawRhoList();
}

// Marking point of interest
void markPointOfInterest()
{
  // Drawing ellipse as point of interest
  ellipse(pointOfInterest[0],pointOfInterest[1],5,5);
}

// Draw the list of concentric circles according to the lists above.
void drawRhoList()
{ 
  int l =0;
  switch(listCounter)
  {
    case 1:
      l = rhoList1.length;
    break;
    
    case 2:
      l = rhoList2.length;
    break;
    
    case 3:
      l = rhoList3.length;
    break;    
  }
  
  // Loop through either rhoList1 or rholist2  
  for(int i=0; i<l; i++)
  {
    // Get corresponding radius in rholist
    int radius = ((drawFirstBatch)?rhoList1[i]:rhoList2[i]);
    
    switch(listCounter)
    {
      case 1:
        radius = rhoList1[i];
      break;
      
      case 2:
        radius = rhoList2[i];
      break;
      
      case 3:
        radius = rhoList3[i];
      break;    
    }

    // Set concentric circle
    ellipse(pointOfInterest[0],pointOfInterest[1],radius,radius);
  }
}

// Key pressed event.
int imageCounter=1;
int listCounter = 1;
void keyPressed()
{
  // If key r is pressed
  if (key == 'r')
  {
    println(listCounter);
    // Switch drawFirstBatch on and off
    listCounter++;
    if(listCounter == 4)
    {
      listCounter = 1;
    }
  }
 else
 {
    // If the image counter is smaller than the no of images availabe.
    if(imageCounter < noOfImages)
    {
      // If left arrow key is pressed and image counter is greater than 1
      if (keyCode == LEFT && imageCounter > 1) 
            // decrease counter to show previous image.
            imageCounter--;
      else
            // increase counter to show previous image.
            imageCounter++;
  
      // Load both normal and COSFIRE image
    if (imageCounter<10)
    {
      img = loadImage(path+"symbol00"+imageCounter+".jpg");
    }
    else
    {
      img = loadImage(path+"symbol0"+imageCounter+".jpg");
    }
  

    }
    else
    {
      // Reset image counter to 1 when it reaches the maximum number of symbols.
      imageCounter=1;
    }
 }
}
