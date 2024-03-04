function [ p ] = loadFly(rotX,rotY,rotZ,scale,alphaFac)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
persistent F V
%%

addpath('C:\Users\williamsonw\Documents\cad2matR2')
filename = 'Z:\pez3000_methods_paper\FLY.stl';
if isempty(mfilename) || isempty(F)
    % Read the CAD data file:
    [F,V] = rndread(filename);
end
%%
if isempty(mfilename)
    clf
end
if ~exist('scale','var'), scale = 1; end
if ~exist('alphaFac','var')
    alphaFac = 0.15;
end
bodyAlpha = 1*alphaFac;
wingAlpha = 0.5*alphaFac;

bodyRefs = 1:8354;% all but wings is 1 through 8354
%%%%%%%%% eyes
eyeRefsA = [394:547,...
    2104:2138,...
    2204:2219,...
    30:280];% eye 1
eyeRefsB = [1547:1706,...
    579:594,...
    1865:2026,...
    2288:2363];% eye 2
%%%%%%%%% wings
wingEdgeRefsA = 8355:8500;
wingRefsA = 8501:8690;
wingEdgeRefsB = 8691:8844;
wingRefsB = 8845:9032;

C = repmat([183 104 13]/255,size(V,1),1);
bodyRefs2removeA = bodyRefs(eyeRefsA);
bodyRefs2removeB = bodyRefs(eyeRefsB);
bodyRefs(cat(1,bodyRefs2removeA(:),bodyRefs2removeB(:))) = [];
p(1) = patch('faces',F(bodyRefs,:),'vertices',V,'facevertexcdata',C,...
    'edgecolor','none','FaceColor','interp','facealpha',bodyAlpha,'facelighting','gouraud');
hold on
if isempty(mfilename) || nargin == 0
    rotX = 90;
    rotY = 0;
    rotZ = 90;
    daspect([1 1 1])                    % Setting the aspect ratio
end
C = repmat([148 16 16]/255,size(V,1),1);
p(2) = patch('faces',F([eyeRefsA eyeRefsB],:),'vertices',V,'facevertexcdata',C,...
    'edgecolor','none','FaceColor','interp','facealpha',bodyAlpha,'facelighting','gouraud');

C = zeros(size(V,1),3);
p(3) = patch('faces',F([wingEdgeRefsA wingEdgeRefsB],:),'vertices',V,'facevertexcdata',C,...
    'edgecolor','none','facealpha',wingAlpha,'FaceColor','interp');
C = zeros(size(V,1),3)+0.3;
p(4) = patch('faces',F([wingRefsA wingRefsB],:),'vertices',V,'facevertexcdata',C,...
    'edgecolor','none','facealpha',wingAlpha,'FaceColor','interp');
xlabel('X'),ylabel('Y'),zlabel('Z')

% Move it around.
% To use homogenous transforms, the n by 3 Vertices will be turned to
% n by 4 vertices, then back to 3 for the set command.
% Note: n by 4 needed for translations, not used here, but could, using tl(x,y,z)
V2 = (V*6)';
V3 = [V2(1,:); V2(2,:); V2(3,:); ones(1,length(V2))];
%

nv = tl(0,-0.5,1)*V3;
for iterP = 1:numel(p)
    set(p(iterP),'Vertices',nv(1:3,:)')
end

nv= rx(rotX)*nv;
for iterP = 1:numel(p)
    set(p(iterP),'Vertices',nv(1:3,:)')
end
nv= ry(rotY)*nv;
for iterP = 1:numel(p)
    set(p(iterP),'Vertices',nv(1:3,:)')
end
nv= rz(rotZ)*nv;
for iterP = 1:numel(p)
    set(p(iterP),'Vertices',nv(1:3,:)'*scale)
end
radius = 1;
[xL,yL,zL] = sph2cart(90-45,45,radius);
lightPos = [xL,yL,zL];
light('style','infinite','position',lightPos);

for iterP = 1:numel(p)
    set(p(iterP),'AmbientStrength',0.5,'FaceLighting','gouraud','FaceColor','interp',...
        'DiffuseStrength',0.5,'SpecularStrength',0.2,'SpecularColorReflectance',1,'SpecularExponent',7)
end
% drawnow
if isempty(mfilename)
%     view(180,45)
%     lightangle(180,45)
    set(gcf,'pos',[2628 224 1181 684])
end
end

