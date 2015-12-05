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
num_tri = size(tri,1)

% coordinates of pixels in target image in 
% homogenous coordinates.  we will assume 
% target image is same size as source
[xx,yy] = meshgrid(1:w,1:h);
Xtarg = [xx(:) yy(:) ones(h*w,1)]';

% for each triangle, compute tranformation which
% maps it to from the target back to the source
T = zeros(3,3,num_tri); % tranformation matricies
.
.
.

% for each pixel in the target image, figure
% out what triangle it lives in so we know 
% what transformation to apply
tindex = ...


% now tranform target pixels back to 
% source image
Xsrc = zeros(size(Xtarg));
for t = 1:num_tri
.
% find source coordinates for all target pixels
% lying in triangle t
.
end

% now we know where each point in the target 
% image came from in the source, we can interpolate
% to figure out the colors

assert(size(I_source,3) == 3)  % we only are going to deal with color images

R_target = interp2(I_source(:,:,1),Xsrc(1,:),Xsrc(2,:));
G_target = ...
.
.

I_target(:,:,1) = reshape(R_target,h,w);
I_target(:,:,2) = reshape(G_target,h,w);
.
.

