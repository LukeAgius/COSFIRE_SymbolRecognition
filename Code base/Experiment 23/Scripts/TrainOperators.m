function trainingSet = TrainOperators(params,configuration,noOfSymbols)

% for i=1:length(configuration)
%     configuration{i}.params.COSFIRE.t1 = 0.1;
%     configuration{i}.params.COSFIRE.sigma0 = 2;
% end

    % Cell holding vectors for each COSFIRE operator on an image.
    listOfCOSFIREOutputs  = cell(1,noOfSymbols);

    % Init training image's feature vector.
    imageOutput = zeros(1,length(configuration));
    
    % If load training set from file is switched on
    if params.loadTrainingFromFile == 1
        % load listOfCOSFIREOutputs
        load(['../Intermediate Results/' params.TestingFolder '/Check Points/COSFIREOUTPUTS.mat'], 'listOfCOSFIREOutputs');
    else
        % Getting List of images in the models  folder
        models = dir([Utilities.getModelsDirectory(params), ['*' params.ModelsExtension]]);
        
        % For each Symbol Model Image
        for i=1:size(models,1),    
            % Display the number to keep track of where the loop is.
            display(['Training for ' models(i).name]);

            % Loading images. If statement due to 0 or 00 in the images' titles.
            trainingImage = imresize(imread([Utilities.getModelsDirectory(params) models(i).name]),0.5);
            
            % Converting trainingImage to double.
            trainingImage = double(trainingImage);
            
            % If the most maximum value within the trainingImage is equal
            % to 255
            if max(trainingImage(:)) == 255
                % Divide it all by 255.
                trainingImage = trainingImage / 255;
            end
            
            % init t as the same size of the trainingImage and enlarge it
            % by 100.
            t = ones(size(trainingImage)+100);
            
            % Place trainingImage in the middle of t
            t(51:51+size(trainingImage,1)-1,51:51+size(trainingImage,2)-1) = trainingImage;
            
            % replace trainingImage with t
            trainingImage = t;
            
            % For each operatar on the configuration collextioj
            for j=1:length(configuration)
                % Display the operator being currently applied
                  display(['  Applying operator' num2str(j)]);

                % Applying operator number j to current training image i and saving the output
                flag = 0;
                
                % if this is the first iteration
                if j==1
                    try
                        % Apply configuration collection on the training
                        % image
                        [cosfireOutputForImage,tuple] = applyCOSFIRE(trainingImage,configuration);
                    catch me
                        % If error happens, flag it.
                        flag = 1;
                    end
                end
                
                % If no error happens
                if flag == 0
                     % Apple COSFIRE with the current iteration's operator
                     % (j) and the tuple object.
                     cosfireOutputForImage = applyCOSFIRE(trainingImage,configuration{j}, tuple);
                else
                    % Apple COSFIRE with the current iteration's operator
                     % (j)
                     cosfireOutputForImage = applyCOSFIRE(trainingImage,configuration{j});
                end

                % Getting the maximum out of the cosfireOutputForImage and
                % setting it in the vector imageOutput. This vector will
                % ulitmatly represent the image with a value for each operator
                % applied to the image i (50 in total)
                imageOutput(1,j) = max(cosfireOutputForImage(:));
            end
            
            % Setting an other row listOfCOSFIREOutputs with the [1 50] vector
            % applied for image i
            listOfCOSFIREOutputs{1,i} = imageOutput;

            % Write to excel
            % Utilities.writeTrainingData(params.TestingFolder,listOfCOSFIREOutputs{1,i},i);
        end
        
        % Saving listOfCOSFIREOutputs to file
        save(['../Intermediate Results/' params.TestingFolder '/Check Points/COSFIREOUTPUTS.mat'], 'listOfCOSFIREOutputs');
    end
    
    % Visualizing training data.
    % Utilities.visualizeTrainingData(listOfCOSFIREOutputs, params.TestingFolder);
    
    % Returning training set.
    trainingSet = listOfCOSFIREOutputs;
end