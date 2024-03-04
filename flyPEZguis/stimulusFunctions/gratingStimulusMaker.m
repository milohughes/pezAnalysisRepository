% gratingStimulusMaker
% clear all, close all, sca

%%%%%%%%% USER INPUT %%%%%%%%%%%%%

%------Graing Parameters---------%
stripe_width_deg = 20; % deg                                                % for even stripes, choose from [3,15,20,45,60,180]
stripe_freq_hz = 0; % Hz
stimTotalDuration = 4; % sec                                                % total duration of grating motion, will determine number of loops (convert to msec for saving)

%------Display Parameters--------%
screenid = 0;                                                               % ID of second screen for PsychToolbox window display; 0 or 1 on mac, 1 or 2 on PC
xOffset = 100;                                                              % offset form the left. '0' is far left
yOffset = 100;                                                              % offset from the top. '0' is the top

height = 768;                                                               % height of stimulus display screen
width = 1024;                                                               % width of stimulus display screen
stimTimeStep = (1/360);                                                     % seconds per frame channel at 120 Hz
stimRefRGB = [2 3 1]; %%DO NOT CHANGE%%                                     % order projector shows RGB frames

%-----Plot & Save Parameters-----%
show_image = 0;
watch_stripes_move = 0;
plot_stim_ind = 0;
save_stimulus = 1;
show_movie = 0;
show_waterfall = 0;

switch computer
    case 'MACI64', save_path = '/Volumes/cardlab/pez3000_variables/visual_stimuli';%'/Volumes/card/Sahana/Matalbroot/test_stimuli';
    otherwise, save_path = 'Z:\pez3000_variables\visual_stimuli';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stripe_freq_hz = 360/(6*round(round(360/stripe_freq_hz)/6));                % Adjust stripe frequency to make full triplets
display(['Adjusted stripe frequency is ',num2str(stripe_freq_hz)])

pixPerDeg = width/360;

stripe_width_pix = round(stripe_width_deg * pixPerDeg);
ind_st = 1:2*stripe_width_pix:width;
ind_rep = repmat(ind_st,stripe_width_pix,1);
ind_wid = repmat([1:stripe_width_pix]',1,length(ind_st));
ind_all = ind_rep + ind_wid - 1;

img = uint8(255*ones(height,width));                                        % Make frames uint8
img(:,ind_all(:)) = 0; 
if show_image, imshow([img img]), end

% Filter the image
% img = imfilter(img,fspecial('average',[4 4]),'replicate');
% if show_image, figure, imshow([img img]), end


% Make all possible grating posiitons
for i = 1:(2*stripe_width_pix)
    temp = circshift(img,[0 i-1]);
    imgMat(:,:,i) = imfilter(temp,fspecial('average',[4 4]),'replicate');                                   % 3rd dimension indexes how many pixels shifted
end
if watch_stripes_move
    for i = 1:size(imgMat,3)
        imshow([imgMat(:,:,i) imgMat(:,:,i)])
        pause(stimTimeStep)
    end
end

% Calculate how many pixels to move each frame
per = 1/stripe_freq_hz;
if isinf(per)
    per = 1/120;
    T = ones(1,3);
    shiftInd = T;
else
    T = stimTimeStep:stimTimeStep:per;                                        % move stripe_freq_hz * 2*(stripe_width_pix-1) every second
    shiftInd = round(stripe_freq_hz * (2*stripe_width_pix) *T);               % move stripe_freq_hz * 2*(stripe_width_pix-1) *stimTimeStep every frame
end
shiftIndTriplets = reshape(shiftInd,3,size(shiftInd,2)/3);                  % Group frame indices into triplets

% Make matrix of all possible frames
imgCat = cell(size(shiftIndTriplets,2),1);
for i = 1:size(shiftIndTriplets,2)
    imgCat{i} = cat(3,imgMat(:,:,shiftIndTriplets(stimRefRGB(1),i)),...
        imgMat(:,:,shiftIndTriplets(stimRefRGB(2),i)),...
        imgMat(:,:,shiftIndTriplets(stimRefRGB(3),i)) );
end

% Make triplets for reset frame and final frame
imgReset = cat(3,imgCat{1}(:,:,stimRefRGB(1)),...
    imgCat{1}(:,:,stimRefRGB(1)),...
    imgCat{1}(:,:,stimRefRGB(1)) );                                         % image that gets displayed between stimuli (first frame)
imgFin = imgReset ;                                                         % image that gets held after stimulus plays (last frame)

% Figure out number of loops and adjust total duration
numLoops = floor(stimTotalDuration / per);
if numLoops < 1, numLoops = 1; end
stimTotalDuration = numLoops * per;
flipReference = repmat((1:size(shiftIndTriplets,2)),1,numLoops);
%%
if save_stimulus
    eleScale = height;                                                      % Determines resolution of undistorted image at the cost of speed
    aziScale = width;
    stimTotalDuration_msec = stimTotalDuration * 1000;                      % Convert total duration to msec
    stimulusStruct = struct('stimTotalDuration',stimTotalDuration_msec,'imgReset',imgReset,...
        'imgFin',imgFin,'eleScale',eleScale,'aziScale',aziScale);
    stimulusStruct(1).imgCell = imgCat;
    stimulusStruct(1).flipReference = flipReference;
    fileName = ['gratingWithRef_' num2str(stripe_width_deg) 'deg_' num2str(stripe_freq_hz),...
        'Hz_' num2str(stimTotalDuration) 'sec_blackandwhite'];

    save(fullfile(save_path,fileName),'stimulusStruct','-v7.3')
    disp(['Saved to ',fullfile(save_path,fileName)])
end

%%
if plot_stim_ind
   figure, hold on
   plot(T,stripe_freq_hz * 2*(stripe_width_pix-1) *T)
   plot(T,shiftInd,'.')
end

%%
if show_movie
    figure
    tic
    for j = 1:numLoops
        for i = 1:length(imgCat)
            imshow(imgCat{i})
            pause(3*stimTimeStep)
        end
    end
    toc
end

%%
if show_waterfall
    imgWaterfall = [];
    for i = 1:size(imgMat,3)
        imgWaterfall = [imgWaterfall;imgMat(1,:,i)];
    end
    figure
    imshow([imgWaterfall;imgWaterfall])
end

