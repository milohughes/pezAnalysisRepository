function pezControlLogoFun
%pezControlLogoFun Places photron logo into pezControl gui

%input center(x,y) and size(x,y)
guiPosFun = @(c,s) [c(1)-s(1)/2 c(2)-s(2)/2 s(1) s(2)];

logo = imread('logo.bmp');
logo = padarray(logo,[1 1],255);
logo(:,:,3) = round(logo(:,:,3).*0.5);
logo(:,:,1:2) = round(logo(:,:,1:2).*0.2);
logo = uint8(logo);
logo = imresize(logo,1.75);
logoPos = guiPosFun([.964 .02],[.07 .035]);
hIcon = axes('Units','normalized','Position',logoPos);
image(logo,'Parent',hIcon,'HitTest','off');
axis off

end

