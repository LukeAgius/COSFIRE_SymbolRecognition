function finalresult = TestOperators(params, configuration, trainingSet,noOfSymbols)

    % Implementing Z-Score Normalization
    c = cell2mat(trainingSet');
    mu = mean(c);
    sigma = std(c);
    nc = (c-repmat(mu,size(c,1),1))./repmat(sigma,size(c,1),1);

    % Variables to hold count for true positives and false positives
    truepositives = 0;   falsepositives = 0;
    
    % Getting List of images in the models  folder
    models = dir([Utilities.getModelsDirectory(params), ['*' params.ModelsExtension]]);
    tests = dir([Utilities.getTestingDirectory(params), ['*' params.TestingExtension]]);
    
    % For each Symbol Model Image
    for i=3:length(tests)-1,   

        % Init testing image
       testingImage = imread([Utilities.getTestingDirectory(params) 'image' num2str(i,'%02i') params.TestingExtension]);
       testingImage = double(testingImage);
       
       % Noise E
       %testingImage = medfilt2(testingImage, [5 5]);
       
       % Noise A
       %se = strel('disk',1); 
       %testingImage = imcomplement(imdilate(imcomplement(testingImage), se));
       
       % Noise B
       testingImage = imcomplement(testingImage);
        DL = [];
        for j = 0:30:150,
            se = strel('line',10,j);
            DL(:,:,end+1) = imdilate(testingImage,se);
        end
        testingImage = max(DL,[],3);
        M = medfilt2(testingImage,[5 5]);
        S = bwmorph(M,'thin',inf);
        testingImage = imcomplement(imdilate(S,strel('disk',2)));
             
      
       % if the most maximum value within the testingImage is equal to 255
        if max(testingImage(:)) == 255
            % Divide entire testingImage by 255.
            testingImage = testingImage / 255;
        end

        % Vector of size 50, which will represent each image, with maximum values from all 50 operators.
        imageOutput = zeros(1,length(configuration));

        % Distances vector which will hold the distances for the current test image
        % from each operator in the training set.
        distancesN = zeros(1,noOfSymbols);
        distancesOrg = zeros(1,noOfSymbols);
        
        % For each COSFIRE operator
        for j=1:length(configuration),
            % Applying operator number j to current training image i and saving the output
            flag = 0;
            
            % if this is the first iteration
            if j==1
                try
                    % Apply configuration collection on the training
                    % image
                    [cosfireOutputForImage,tuple] = applyCOSFIRE(testingImage,configuration);
                catch me
                    % If error happens, flag it.
                    flag = 1;
                end
            end

            % If no error happens
            if flag == 0
                % Apple COSFIRE with the current iteration's operator
                % (j) and the tuple object.
                 cosfireOutputForImage = applyCOSFIRE(testingImage,configuration{j}, tuple);
            else
                 % Apple COSFIRE with the current iteration's operator
                 % (j)
                 cosfireOutputForImage = applyCOSFIRE(testingImage,configuration{j});
            end

            % Getting the maximum out of the cosfireOutputForImage and
            % setting it in the vector imageOutput. This vector will
            % ulitmatly represent the image with a value for each operator
            % applied to the image i (50 in total)
            imageOutput(1,j) = max(cosfireOutputForImage(:));

        end
        
        imageNOutput = (imageOutput-mu)./sigma;
        
        % Saving image output to disk
        save(['../Intermediate Results/' params.TestingFolder '/Test Image Outputs(MAX)/MaxOperators_file_' num2str(i) params.TestingExtension '.mat'], 'imageOutput');
        
        % For each element in imageOutput & trainingSet{1, X}
        for X=1:noOfSymbols,

            % Getting Euclidean distance between current trainingSet vector and
            % testing image vector
            v1org = trainingSet{1,X};
            v1 = nc(X,:);
            
            v2org = imageOutput;
            v2 = imageNOutput;
            
            distancesN(X) = dist(v1,v2');
            distancesOrg(X) = dist(v1org,v2org');
        end
    
        % Finally displaying answer.
        [value index] = min(distancesN); 
        [valueOrg indexOrg] = min(distancesOrg); 
        
        % If extracted index of nearest model is equal to the target of the
        % current testing image's xml expected value then count true positives 
        % and false positives accordingly. Also displaying and writing output
        % for user to file.
        if strrep(models(index).name,params.ModelsExtension,'') == Utilities.ReadXMLV2(['image' num2str(i,'%02i')])
            % Increment true positives
            truepositives = truepositives + 1;
            % Save result to file
            Utilities.appendResultToFile(params.TestingFolder,['image' num2str(i,'%02i') params.TestingExtension],models(index).name,'Pass');
        else
            % Increment false positives
            falsepositives = falsepositives + 1;            
            % Save result to file
            Utilities.appendResultToFile(params.TestingFolder,['image' num2str(i,'%02i') params.TestingExtension],models(index).name,'Fail');
            % Save false positive to image.
            Utilities.saveFalsePositive(params.TestingFolder, testingImage, imread([Utilities.getModelsDirectory(params) models(index).name]), ['image' num2str(i,'%02i') params.TestingExtension]);
        end
    end

    % Finally display and write results to file.
    Utilities.appendTPFP(params.TestingFolder,truepositives,falsepositives);
end