  String modelFolder = "sketches25f-models";
  String testFolder = "sketches25f-level1";
  String experiment = "Experiment 2";
  String batch = "Batch1a (alpha 0.05)";
  
  // List of Paths
  String modelDataSetPath = "../../../Data Sets/Symbols Datasets/Sketched Symbols/"+modelFolder+"/";
  String testDataSetPath = "../../../Data Sets/Symbols Datasets/Sketched Symbols/"+testFolder+"/";
  String operatorsPath = "../../"+experiment+"/Final Results/"+batch+"/Visual Output/Operators/";
  String testResultPath = "../../"+experiment+"/Final Results/"+batch+"/"+batch+".txt";
  String imageOutPutPath_pass = "../../"+experiment+"/Final Results/"+batch+"/Visual Output/pass/";

  // Setting font color.
  fill(255,0,0);
  PFont mono;
  mono = loadFont("Calibri-28.vlw");
  textFont(mono);

  // Loading test result
  String resultLines[] = loadStrings(testResultPath);
  
  // For each result in the text file.
  for (int i =0 ; i < 1 /*resultLines.length-4*/; i++) 
  {
    // Get current result
    String result = resultLines[i];

    // Replace .tiff with .JPG. This is because processing does not support all versions of .TIFF
    result = result.replace(".tiff",".jpg");

    // Extract testing image name and model image Name
    String testImageName = result.substring(0,result.indexOf(" "));
    String modelImageName = result.substring(result.indexOf("symbol"), result.indexOf(" -"));

    // Load testing image, model image and model image's operator, also sizing them all to 256x256
    PImage testImage = loadImage(testDataSetPath+testImageName); testImage.resize(256,256);
    PImage modelImage = loadImage(modelDataSetPath+modelImageName);modelImage.resize(256,256);
    PImage operatorImage = loadImage(operatorsPath+modelImageName);operatorImage.resize(256,256);

    // Size up sketch to fit all 3
    size(256*3,operatorImage.height);
      
    // Drawing all images on sketch
    image(testImage,0,0);
    image(modelImage,256,0);
    image(operatorImage,256*2,0);
      
    // Including text to distinguish between them
    text("Test Image", 10, 246);      
    text("Model Image", 266, 246);
    text("Model Operator", 532, 246);
   
    // If current result is a fail
    if(result.substring(result.indexOf("- "),result.length()).equals("- Fail"))
    {   
      save(imageOutPutPath_fail+testImageName);
    }
    else
    {
      save(imageOutPutPath_pass+testImageName);
    }
  }
  
