function viewCOSFIREstructure(operator)

% Visualize the structure of the given COSFIRE operator. The orientations
% are illustrated by ellipses and the blurring functions are illustrated by
% 2D Gaussian blobs

params = operator.params;

maxrho = max(operator.tuples(3,:));
maxsigma = params.COSFIRE.sigma0 + params.COSFIRE.alpha*maxrho;    
radius = ceil((maxrho + (maxsigma*3)));

offset = [radius radius];   
dim = (2 * radius) + 1;

figure;
axis off;

sig = zeros(dim);            
for j = 1:size(operator.tuples,2)
    rho = operator.tuples(3,j);
    sigma = params.COSFIRE.sigma0 + params.COSFIRE.alpha*rho;
    [x y] = pol2cart(operator.tuples(4,j),rho);            
    g = gaussian(sigma,sigma,0,[dim dim],[round(offset(1)-y),round(offset(2)+x)]);
    sig = max(sig,g);
end
imagesc(sig);colormap(gray);axis equal;
      
hold on;
for j = size(operator.tuples,2):-1:1
    rho = operator.tuples(3,j);
    [x y] = pol2cart(operator.tuples(4,j),rho);

    if strcmp(params.inputfilter.name,'Gabor')
        theta = operator.tuples(2,j);
        lambda = operator.tuples(1,j);        
        el = ellipse(lambda/3,lambda/1.5,pi-theta,round(offset(2)+x),round(offset(1)-y));
        set(el,'FaceAlpha',0,'EdgeAlpha',1,'EdgeColor',[1 1 1],'linewidth',2);
    end
end     

axis square;
axis off;
hold off;