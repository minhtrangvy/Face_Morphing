function I_target = warp(I_source,pts_source,pts_target,tri)
%
% I_source : color source image  (HxWx3)
% pts_source : coordinates of keypoints in the source image  (2xN)
% pts_target : coordinates of where the keypoints end up after the warp (2xN)
% tri : list of triangles (triples of indices into pts_source)  (Kx3)
%       for example, the coordinates of the Tth triangle should be 
%       given by the expression:
%
%           pts_source(:,tri(T,:))
% 
%
% I_target : resulting warped image, same size as source image (HxWx3)
%
    [h,w,d] = size(I_source);
    num_tri = size(tri,1);

    %% coordinates of pixels in target image in 
    % homogenous coordinates.  we will assume 
    % target image is same size as source
    [xx,yy] = meshgrid(1:w,1:h);
    Xtarg = [xx(:) yy(:) ones(h*w,1)]';
    
    % for each triangle, compute tranformation which
    % maps it to from the target back to the source
    T = zeros(3,3,num_tri); % tranformation matricies
    for i = 1:num_tri
        % Grabbing which of the picked points are the corners of this triangle
        current_triangle = tri(i,:);
        corner1 = current_triangle(1);
        corner2 = current_triangle(2);
        corner3 = current_triangle(3);
        % Grabbing corners of source image
        tri1 = [pts_source(corner1,:);
                pts_source(corner2,:);
                pts_source(corner3,:)];
        % Grabbing corners of target image
        tri2 = [pts_target(corner1,:);
                pts_target(corner2,:);
                pts_target(corner3,:)];
        % Add to matrix of all the transformation matrices
        T(:,:,i) = tform(tri1,tri2);
    end
    
    %% for each pixel in the target image, figure
    % out what triangle it lives in so we know 
    % what transformation to apply
    tindex = mytsearch(pts_target(:,1),pts_target(:,2),tri,Xtarg(1,:)', Xtarg(2,:)');
    tindex_matrix = zeros(h,w);
    for row = 1:h
        start = 1+((row-1)*w);
        stop = w*row;
        tindex_matrix(row,:) = tindex(start:stop);
    end
    
    % now tranform target pixels back to 
    % source image
    I_target = I_source;
    I_target_copy = I_source;
    Xsrc = zeros(size(Xtarg));
    current_pixel = 0;
    for r = 1:h
        for c = 1:w
            current_pixel = current_pixel+1;
            current_triangle = tindex_matrix(r,c);
            if ~isnan(current_triangle)
                transformation_matrix = T(:,:,current_triangle);
                current_point = [r c 1]';
                current_source_coord = transformation_matrix * current_point;
                current_source_coord = round(current_source_coord/current_source_coord(3));
                x = current_source_coord(1);
                y = current_source_coord(2);

                if (x > 0) && (x < h) && (y > 0) && (y < w)
                    Xsrc(1,current_pixel) = x;
                    Xsrc(2,current_pixel) = y;
                    I_target_copy(r,c,:) = I_source(x,y,:);
                else
                    Xsrc(1,current_pixel) = r;
                    Xsrc(2,current_pixel) = c;
                    I_target_copy(r,c,:) = I_source(r,c,:);
                end                
            else
                Xsrc(1,current_pixel) = r;
                Xsrc(2,current_pixel) = c;
                I_target_copy(r,c,:) = I_source(r,c,:);
            end
        end
    end
    
%     figure
%     imshow(I_target_copy)
%     return
%     
%     % now we know where each point in the target
%     % image came from in the source, we can interpolate
%     % to figure out the colors
    assert(size(I_source,3) == 3)  % we only are going to deal with color images
    I_source = im2double(I_source);

    R = I_source(:,:,1);
    G = I_source(:,:,2);
    B = I_source(:,:,3);

X = Xtarg(1,:);
Y = Xtarg(2,:);
[X2,Y2] = meshgrid(1:w,1:h);
size(X)
size(X2)
assert(X == X2)
R_target = interp2(R,X2,Y2);
figure
imshow(R)
figure
imshow(R_target)
return
    R_target = interp2(R,Xsrc(1,:),Xsrc(2,:));
    G_target = interp2(G,Xsrc(1,:),Xsrc(2,:));
    B_target = interp2(B,Xsrc(1,:),Xsrc(2,:));

    I_target(:,:,1) = reshape(R_target,h,w);
    I_target(:,:,2) = reshape(G_target,h,w);
    I_target(:,:,3) = reshape(B_target,h,w);

    figure
    imshow(I_source)
    title('source')

    figure
    imshow(I_target)
    title('target')
    
    figure
    imshow(I_target_copy)
    title('directly setting pixel value')

