String originals = "../POI_Rho/Originals/";
String path = "../../Experiment 1/SetA - COSFIRE Operators/Batch 1/";
String path2 = "../../Experiment 1/SetA - COSFIRE Operators/Batch 2/";
PImage normal_img;
PImage cosfire_img;
PImage cosfire_img2;
PFont font;

int noOfImages = 50;
int imageCounter=1;

// Setup
void setup()
{
    // Setting size
    size(1200,475);
    
    // loading Normal symbol
    normal_img = loadImage(originals+"symbol001.jpg");

    // loading COSFIRE operator
    cosfire_img = loadImage(path+"symbol1_COSFIRE.jpg");    
    cosfire_img2 = loadImage(path2+"symbol1_COSFIRE.jpg");    
}

// Draw
void draw()
{
  // Reseting background
  background(150);
  
  // Showing both normal image and COSFIRE operator
  image(normal_img,0,75);
  image(cosfire_img,266,75);
  image(cosfire_img2,276+cosfire_img.width,75);
  
  // Setting fill to black
  fill(0);
  
  // Showing text for number of symbol
  font = loadFont("ArialMT-22.vlw");
  textFont(font);
  text("Symbol "+imageCounter, 25,50);
  text("Batch 1 : Rho List [0:i++:165]" , 266,50);
  text("Batch 2 : Rho List [0:5:165] ", 276+cosfire_img.width,50);
}

// On key press event.
void keyPressed()
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
      normal_img = loadImage(originals+"symbol00"+imageCounter+".jpg");
    }
    else
    {
      normal_img = loadImage(originals+"symbol0"+imageCounter+".jpg");
    }

    cosfire_img = loadImage(path+"symbol"+imageCounter+"_COSFIRE.jpg");    
    cosfire_img2 = loadImage(path2+"symbol"+imageCounter+"_COSFIRE.jpg");   
  }
  else
  {
    // Reset image counter to 1 when it reaches the maximum number of symbols.
    imageCounter=1;
  }
}


