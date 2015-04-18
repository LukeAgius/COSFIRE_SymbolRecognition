int[] rhoList = {4,30,72,130,165};
PImage rhoImage;
PImage modelImage;

void setup()
{
  size(256,256);
  ellipseMode(RADIUS);
  smooth();
  drawRhos();
  rhoImage = get();
  modelImage = loadImage("models\\symbol001.jpg");
}

void drawRhos()
{
  background(255);
  noFill();
  stroke(255,0,0);
  for(int r : rhoList)
  {
    ellipse(width/2,height/2,r,r);
  }
}

void draw()
{
  drawSymbolWithRho();
}


void drawSymbolWithRho()
{
  image(modelImage,0,0);
  noFill();
  stroke(255,0,0);
  for(int r : rhoList)
  {
    ellipse(width/2,height/2,r,r);
  }
}


