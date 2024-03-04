function make3Dflyplot(hax,radius,makeSample,flyFactor)
%MAKE3DFLYPLOT This receives and axes handle and prepares it for plotting
%in 3D over a fly in a dome

if ~exist('makeSample','var')
    makeSample = 0;
end
if ~exist('flyFactor','var')
    flyFactor = 0.5;
end
if ~exist('hax','var')
    clf
    hax = axes;
end

if ~exist('radius','var')
    radius = 3;
end


colorMapVar = colorMapMaker(1);
colorMapVar = (colorMapVar.^0.75);
colormap(colorMapVar)

addpath('C:\Users\williamsonw\Documents\cad2matR2')
if makeSample > 0
    loadFly(90,0,90,radius*flyFactor*0.75,1);%0.75 makes fly 1.5mm if diameter of dome is 2mm
end

gridLeg = 90;
aziQ = linspace(0,180,round(gridLeg*pi));
eleQ = linspace(0,90,gridLeg);
[aziQ,eleQ] = meshgrid(aziQ,eleQ);
aziQ = cat(2,fliplr(aziQ),-aziQ(:,2:end));
eleQ = cat(2,fliplr(eleQ),eleQ(:,2:end));

[visX,visY,visZ] = sph2cart(deg2rad(aziQ),deg2rad(eleQ),zeros(size(eleQ))+radius);

[Fdata,Vdata] = surf2patch(visX,visY,visZ);
Cdata = ones(size(Vdata,1),1);    
% facevertex
Sh = patch('faces',Fdata,'vertices',Vdata,'cdata',Cdata,...
    'cdatamapping','scaled','FaceLighting','gouraud','FaceColor','interp');
Sh.EdgeColor = 'none';
set(Sh,'AmbientStrength',1)
Sh.FaceColor = [0 0 0]+0.8;
set(Sh,'facealpha',0.1)

invert = 0;
    

view(180,45)
material dull
axis square
lims = [-radius radius]*1.1;
% set(hax,'xlim',lims,'ylim',lims,'zlim',lims,'clim',[0 255])

set(hax,'projection','perspective')
set(hax,'CameraViewAngle',45)
% if size(get(0,'monitorpositions'),1) == 1
%     set(gcf,'position',[100 90 1200 900],'color','w')
% else
%     set(gcf,'position',[2500 90 1200 900],'color','w')
% end
[camX,camY,camZ] = sph2cart(deg2rad(90-5),deg2rad(47),80);
set(hax,'cameraviewangle',3.5,'cameraposition',[camX camY camZ],'CameraTarget',[0 -0.8 0])
set(hax,'color','none','xcolor','none','ycolor','none','zcolor','none')
% delete(findobj('type','Light'))
if makeSample > 0
    hLb = light('style','infinite');
    [xL,yL,zL] = sph2cart(deg2rad(-45),deg2rad(45),radius);
    lightPos = [-xL,yL,-zL];
    set(hLb,'position',lightPos)
end
if invert == 1
    set(gcf,'color','k')
    gridC = [0 0 0]+1;
    gridAlpha = 0.15;
else
    gridC = [0 0 0]+0;
    gridAlpha = 0.1;
end
gridSwell = 0.2;
minAzi = -180;
maxAzi = 180;
aziLines = linspace(minAzi,maxAzi,9);
for iterL = 1:numel(aziLines)
    aziL = [-gridSwell gridSwell]+aziLines(iterL);
    eleQ = linspace(0,90,50);
    [aziL,eleQ] = meshgrid(aziL,eleQ);
    [visXa,visYa,visZa] = sph2cart(deg2rad(aziL),deg2rad(eleQ),zeros(size(eleQ))+radius*1.005);
    [visXb,visYb,visZb] = sph2cart(deg2rad(aziL),deg2rad(eleQ),zeros(size(eleQ))+radius*1.0025);
    visX = [visXa;flipud(visXb)];
    visY = [visYa;flipud(visYb)];
    visZ = [visZa;flipud(visZb)];
    [F,V] = surf2patch(visX,visY,visZ,ones(size(visZ)));
    FsideA = [flipud(F(:,1)) flipud(F(:,4)) (F(:,1)) (F(:,4))];
    FsideB = [(F(:,2)) flipud(F(:,3)) flipud(F(:,2)) (F(:,3))];
    F = cat(1,FsideA,FsideB,F);
    h = patch('faces',F,'vertices',V,'FaceLighting','gouraud','FaceColor',gridC);
    h.EdgeColor = gridC;
    h.EdgeLighting = 'gouraud';
    set(h,'FaceAlpha',gridAlpha,'EdgeAlpha',gridAlpha)
end

eleLines = fliplr(linspace(0,90,5));
eleLines(1) = eleLines(1)-1;
for iterL = 1:numel(eleLines)
    %         if eleLines(iterL) == 90
    %             eleQ = [-3 0]+eleLines(iterL);
    %         else
    eleQ = [-gridSwell gridSwell]+eleLines(iterL);
    %         end
    aziL = linspace(minAzi,maxAzi,50);
    [aziL,eleQ] = meshgrid(aziL,eleQ);
    [visXa,visYa,visZa] = sph2cart(deg2rad(aziL),deg2rad(eleQ),zeros(size(eleQ))+radius*1.005);
    [visXb,visYb,visZb] = sph2cart(deg2rad(aziL),deg2rad(eleQ),zeros(size(eleQ))+radius*1.0025);
    visX = [visXa;flipud(visXb)];
    visY = [visYa;flipud(visYb)];
    visZ = [visZa;flipud(visZb)];
    [F,V] = surf2patch(visX,visY,visZ,ones(size(visZ)));
    h = patch('faces',F,'vertices',V,'FaceLighting','gouraud','FaceColor',gridC);
    h.EdgeColor = gridC;
    h.EdgeLighting = 'gouraud';
    set(h,'FaceAlpha',gridAlpha,'EdgeAlpha',gridAlpha)
end

Vi = [-23.4510    4.6412   -0.0087    6.1630
   -4.2245  -21.3228   11.9680  282.1375
   -0.1355   -0.6862   -0.7146   44.2172
   44.2327         0         0    1.0000];
camview(Vi)
set(hax,'xdir','reverse')


end

