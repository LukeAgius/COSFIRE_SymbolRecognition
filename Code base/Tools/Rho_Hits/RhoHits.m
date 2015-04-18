function result = RhoHits(ModelImage)

        rhoList = [4 30 72 130 165];    

        ConcentricCircles = zeros(256,256);
        ConcentricCircles(:) = 255;
        
        % Init list of circles
        circles = int32(zeros(length(rhoList),3));

        % For each element in rho list, the circles matrix is being populated.
        for j=1:length(rhoList),
            circles(j,1) = 128;
            circles(j,2) = 128;
            circles(j,3) = rhoList(j);
        end
        
        % Converting image to RGB
        RGB = repmat(ConcentricCircles,[1,1,3]);

        % Color of circle borders
        red = uint8([255 0 0]); 

        % Init Shapre inserter and specify circles
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom','CustomBorderColor',red);

        % Mesh togather the circles and the image.
        %imwrite(step(shapeInserter, RGB, circles),outputPath);
        circlesImage = step(shapeInserter, im2uint8(RGB), circles);
        circlesImage = circlesImage(:,:,2);
        ModelImage = bwmorph(imresize(ModelImage,0.5),'thicken',Inf);
        
        counter = 0;
        for x=1:256,
            for y=1:256,
                if circlesImage(x,y) == 0
                    if ModelImage(x,y) == 0
                        counter = counter +1;
                    end
                    
                end
            end
        end
        display(counter);
        
result = circlesImage;
end

