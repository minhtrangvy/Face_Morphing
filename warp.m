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

    %% for each triangle, compute tranformation which
    % maps it to from the target back to the source
%     T = zeros(3,3,num_tri); % tranformation matricies
%     for i = 1:num_tri
%         % Grabbing which of the picked points are the corners of this triangle
%         current_triangle = tri(i,:);
%         corner1 = current_triangle(1);
%         corner2 = current_triangle(2);
%         corner3 = current_triangle(3);
%         % Grabbing corners of source image
%         tri1 = [pts_source(corner1,:);
%                 pts_source(corner2,:);
%                 pts_source(corner3,:)]
%         % Grabbing corners of target image
%         tri2 = [pts_target(corner1,:);
%                 pts_target(corner2,:);
%                 pts_target(corner3,:)]
%         % Add to matrix of all the transformation matrices
%         T(:,:,i) = tform(tri1,tri2);
%     end

    %% for each pixel in the target image, figure
    % out what triangle it lives in so we know 
    % what transformation to apply
    tindex = mytsearch(pts_target(:,1),pts_target(:,2),tri,Xtarg(1,:)', Xtarg(2,:)');
    
    % now tranform target pixels back to 
    % source image
    Xsrc = zeros(size(Xtarg));
%     for t = 1:num_tri
%         current_T_matrix = T(:,:,t);
%         % find source coordinates for all target pixels
%         % lying in triangle t
%         for row = 1:h
%             for col = 1:w
%                 % if the current pixel is in the current triangle
%                 if tindex_matrix(row,col) == t
%                     % find the coordinates of the source pixel
%                     display(current_T_matrix)
%                     current_point = [row,col,1]
%                     src_pixel_coord = current_T_matrix*current_point'
% %                     Xscr(src_pixel_coord(1),src_pixel_coord(2)) = 
%                     Xsrc(Xtarg(2,i),Xtarg(1,i)) = I_source(src_pixel_coord(1),src_pixel_coord(2));
%                 end
%             end
%         end
%     end
    for pixel=1:(h*w)
        if ~isnan(tindex(pixel))
            current_triangle = tri(tindex(pixel),:);
            corner1 = current_triangle(1);
            corner2 = current_triangle(2);
            corner3 = current_triangle(3);
            
            target_tri_points = [pts_target(corner1);
                                 pts_target(corner2);
                                 pts_target(corner3)];
            target_tri_points(3,:) = [1 1 1];
            transformation_matrix = [Xtarg(1,pixel),Xtarg(2,pixel),1]' \ target_tri_points;
            
            source_tri_points = [pts_source(corner1);
                                 pts_source(corner2);
                                 pts_source(corner3)];
            source_tri_points(3,:) = [1 1 1];
            result = source_tri_points*transformation_matrix;
            result = result / result(3);
            Xsrc(Xtarg(1,pixel),Xtarg(2,pixel)) = I_source(result(1),result(2));
        else
            Xsrc(Xtarg(1,pixel),Xtarg(2,pixel)) = I_source(Xtarg(1,pixel),Xtarg(2,pixel));
        end
    end
    
    % now we know where each point in the target
    % image came from in the source, we can interpolate
    % to figure out the colors
    assert(size(I_source,3) == 3)  % we only are going to deal with color images

    R_target = interp2(I_source(:,:,1),Xsrc(1,:),Xsrc(2,:));
    G_target = interp2(I_source(:,:,2),Xsrc(1,:),Xsrc(2,:));
    B_target = interp2(I_source(:,:,3),Xsrc(1,:),Xsrc(2,:));

    I_target(:,:,1) = reshape(R_target,h,w);
    I_target(:,:,2) = reshape(G_target,h,w);
    I_target(:,:,3) = reshape(B_target,h,w);

