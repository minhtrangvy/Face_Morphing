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
    I_source = im2double(I_source);
    [h,w,d] = size(I_source);
    num_tri = size(tri,1);

    %% coordinates of pixels in target image in 
    % homogenous coordinates.  we will assume 
    % target image is same size as source
    [xx,yy] = meshgrid(1:h,1:w);
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
        T(:,:,i) = tform(tri2,tri1);
    end
    
    %% for each pixel in the target image, figure
    % out what triangle it lives in so we know 
    % what transformation to apply
    tindex = mytsearch(pts_target(:,1),pts_target(:,2),tri,Xtarg(1,:)', Xtarg(2,:)');
    save('tindex','tindex');
    tindex_matrix = zeros(h,w);
    for row = 1:h
        start = 1+((row-1)*w);
        stop = w*row;
        tindex_matrix(row,:) = tindex(start:stop);
    end
    
    % now tranform target pixels back to 
    % source image
    I_target = ones(size(I_source));
    Xsrc = zeros(h,w);
    Ysrc = zeros(h,w);
%     I_target_copy = ones(size(I_source));
    for r = 1:h
        for c = 1:w
            current_triangle = tindex_matrix(r,c);
            
            if ~isnan(current_triangle)
                
                transformation_matrix = T(:,:,current_triangle);
                
                current_point = [r c 1]';
                current_source_coord = transformation_matrix * current_point;
                current_source_coord = round(current_source_coord/current_source_coord(3));
                
                x = current_source_coord(1);
                y = current_source_coord(2);
                
%                 Xsrc(r,c) = 1;
%                 Ysrc(r,c) = 1;
                [Xsrc(r,c), Ysrc(r,c)] = check_pixels(x,y,h,w,r,c);
%                 [Xsrc(r,c), Ysrc(r,c)] = check_pixels2(x,y,h,w);
            else
                Xsrc(r,c) = r;
                Ysrc(r,c) = c;
%                 I_target_copy(r,c,1) = interp2(I_source(:,:,1),r,c);
%                 I_target_copy(r,c,2) = interp2(I_source(:,:,3),r,c);
%                 I_target_copy(r,c,3) = interp2(I_source(:,:,3),r,c);
            end
        end
    end
    
    % now we know where each point in the target
    % image came from in the source, we can interpolate
    % to figure out the colors
    assert(size(I_source,3) == 3)  % we only are going to deal with color images

    R = I_source(:,:,1);
    G = I_source(:,:,2);
    B = I_source(:,:,3);

    R_target = interp2(R,Ysrc,Xsrc);
    G_target = interp2(G,Ysrc,Xsrc);
    B_target = interp2(B,Ysrc,Xsrc);

    I_target(:,:,1) = reshape(R_target,h,w);
    I_target(:,:,2) = reshape(G_target,h,w);
    I_target(:,:,3) = reshape(B_target,h,w);

