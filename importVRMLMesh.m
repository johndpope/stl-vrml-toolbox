function [pointcloud,K]=importVRMLMesh(fname,dispResult)
%% importVRMLMesh
% Author: Robert Ellenberg
%   (Based on wrl2mat by Alireza Bossaghzadeh)
%
%   Extract the coordinate indices and point cloud from a VRML model. Note
%   that this function makes very restrictive assumptions about the nature
%   of the VRML file.  It can basically only handle a single object,
%   defined first by a set of points, then a set of indices.
%
if ~strcmp(fname(end-3:end),'.wrl')
    fname=[fname '.wrl']
end
vrfile=fopen(fname);

fprintf('Reading pointcloud data from %s\n', fname)
p=1;
counter=0;
pointcloud=zeros(2000,3);

while counter ~= -1
    data=fgets(vrfile);
    fpoint=strfind(data,'point');% 2 checkers to find out the begining
    f2point=strfind(data,'[');   %of the x,y,z " point [ "
    while ~isempty(fpoint) && ~isempty(f2point)
        data=fgets(vrfile);
        if isempty(strfind(data,']'));
            t=sscanf(data,'%f %f %f');
            pointcloud(p,:)=t';
            p=p+1;
        else fpoint=[];counter=-1;
        end
        if p>size(pointcloud,1);
            pointcloud=[pointcloud;zeros(200,3)];
        end
    end
end

pointcloud=pointcloud(1:p-1,:); %trim padded zeros

p=1;
counter=0;
coordIndex=zeros(2000,4);
fprintf('Reading surface mesh data from %s\n', fname)
while counter ~= -1
    data=fgets(vrfile);
    fpoint=strfind(data,'coordIndex');% 2 checkers to find out the begining
    f2point=strfind(data,'[');   %of the x,y,z " point [ "
    while ~isempty(fpoint) && ~isempty(f2point)
        data=fgets(vrfile);
        if isempty(strfind(data,']'));
            t=sscanf(data,'%d, %d, %d, %d,');
            coordIndex(p,:)=t';
            p=p+1;  
        else fpoint=[];counter=-1;
        end
        if p>size(coordIndex,1);
            coordIndex=[coordIndex;zeros(200,4)];
        end
    end
end
coordIndex=coordIndex(1:p-1,:); %trim padded zeros
fclose(vrfile);

disp('Display results')

K=coordIndex(:,1:3)+1;
X=pointcloud(:,1);Y=pointcloud(:,2);Z=pointcloud(:,3);%Load positions to X,Y,Z

if nargin<2
    dispResult=0;
end
if dispResult
    
    %Display the imported VRML Mesh
    figure(1)
    trisurf(K,X,Y,Z);
    axis equal
   
end

