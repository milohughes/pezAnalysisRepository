% stripeStimulusMaker_v2
clear all, close all

%%%%%%%%% USER INPUT %%%%%%%%%%%%%

%------Graing Parameters---------%
stripe_width_deg = 15; % deg  
stripe_height_deg = 100; % deg
stripe_freq_hz = 1; % Hz
osc_amp_deg = 12; % deg
stripe_num = 1; 
stimTotalDuration = 8; % sec                                                % total duration of grating motion, will determine number of loops (convert to msec for saving)

%------Display Parameters--------%
screenid = 0;                                                               % ID of second screen for PsychToolbox window display; 0 or 1 on mac, 1 or 2 on PC
xOffset = 100;                                                              % offset form the left. '0' is far left
yOffset = 100;                                                              % offset from the top. '0' is the top

height = 768;                                                               % height of stimulus display screen
width = 1024;                                                               % width of stimulus display screen
stimTimeStep = (1/360);                                                     % seconds per frame channel at 120 Hz
stimRefRGB = [2 3 1]; %%DO NOT CHANGE%%                                     % order projector shows RGB frames

%-----Plot & Save Parameters-----%
save_stimulus = 1;

show_image = 0;
watch_stripes_move = 0;
plot_stim_ind = 0;
show_movie = 0;
show_waterfall = 1;

switch computer
    case 'MACI64', save_path = '/Volumes/cardlab/pez3000_variables/visual_stimuli';%'/Volumes/card/Sahana/Matalbroot/test_stimuli';
    otherwise, save_path = 'Z:\pez3000_variables\visual_stimuli';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Make stripe freq fit 2 pairs of triplets
stripe_freq_hz = 360/(6*round(round(360/stripe_freq_hz)/6));                % Adjust stripe frequency to make full triplets
display(['Adjusted stripe frequency is ',num2str(stripe_freq_hz),' Hz'])

% Make width to fit full stripes
pixPerDeg = width/360;
stripe_width_pix = ceil(stripe_width_deg * pixPerDeg);
num_stripe_reps = round(360/(stripe_width_deg*2));
if stripe_num > 0.5*num_stripe_reps,                                        % Only work for stripe nums half of possible
    stripe_num = 0.5*num_stripe_reps;
    display(['Changing stripe_num to ',num2str(stripe_num)])
end
draw_width = num_stripe_reps*(2*stripe_width_pix);
crop_width = stripe_num*(2*stripe_width_pix);

% Make img with draw_width, height number of frames
%shift_pix = (stripe_num - 0.5)*stripe_width_pix;
white_pix = draw_width - crop_width;
shift_pix = (white_pix/2)+1 + floor(0.5*stripe_width_pix);
ind_st = shift_pix:2*stripe_width_pix:shift_pix+(stripe_num-1)*(2*stripe_width_pix);%1:2*stripe_width_pix:stripe_num*(2*stripe_width_pix);              % use only number of stripes in stripe_num
ind_rep = repmat(ind_st,stripe_width_pix,1);
ind_wid = repmat([1:stripe_width_pix]',1,length(ind_st));
ind_all = ind_rep + ind_wid - 1;

% Display parameters
stripe_wavelength = 360 / num_stripe_reps; % deg/cycle
stripe_contrastFreq = stripe_wavelength * stripe_freq_hz;
display(['Adjusted stripe wavelength is ',num2str(stripe_wavelength),' deg/cycle (',num2str(stripe_wavelength/2),' deg wide stripes)'])
display(['Grating contrast frequency is ',num2str(stripe_contrastFreq),' deg/sec'])

% Get number of frames for one period of oscillation
per = 1/stripe_freq_hz;
numFrames_osc = round(0.25*per*(1/stimTimeStep));                           % frames to go amplitude distance (0.25 cycle) once (not the whole period)
numFrames_osc = 24*round((4*numFrames_osc)/24) / 4;                         % Get numFrames to be divisible by 6 for projector

numFrames_all = length(0:stimTimeStep:per-stimTimeStep);
T = 0:stimTimeStep:numFrames_osc*stimTimeStep;                              % move stripe_freq_hz * 2*(stripe_width_pix-1) every second

imgTime = uint8(255*ones(numFrames_osc,draw_width));                        % Make frames uint8
imgTime(:,ind_all(:)) = 0; 
if show_image, imshow([imgTime]), end

% Shear the image to get correct stripe motion  %%imresize
%Tmat = [1 0 0; (2*stripe_width_pix)/numFrames_all 1 0; 0 0 1];             % Use for shearing with freq referring to time to move one stripe cycle
Tmat = [1 0 0; osc_amp_deg*pixPerDeg/numFrames_osc 1 0; 0 0 1];             % Use for shearing with freq referring to stripe oscillation rate
tform = affine2d(Tmat);
imgWarp = imwarp(imgTime,tform);
if show_image, imshow([imgWarp]), end

% Shear back the other way
lastFrame = imgWarp(end,:);
shift_ind = find(lastFrame==255); shift_ind = shift_ind(1);
lastFrame = lastFrame(1,shift_ind:end);
imgTime_2 = repmat(lastFrame,2*numFrames_osc+1,1);                          % Get last frame of previous warp

Tmat_2 = [1 0 0; -osc_amp_deg*pixPerDeg/numFrames_osc 1 0; 0 0 1];          % Use for shearing with freq referring to stripe oscillation rate
tform_2 = affine2d(Tmat_2);
imgWarp_2 = imwarp(imgTime_2,tform_2);
imgWarp_2 = imgWarp_2(2:end,end-size(imgWarp,2)+1:end);                     % crop off first line (repeated from first warp) and beginning columns added from shear
%imgWarp_2 = imgWarp_2(:,end-size(imgWarp,2)+1:end); 

% And shear back to start
lastFrame = imgWarp_2(end,:);
shift_ind = find(lastFrame==255); shift_ind = shift_ind(end);
lastFrame = lastFrame(1,1:shift_ind);
imgTime_3 = repmat(lastFrame,numFrames_osc+1,1);                            % Get last frame of previous warp

imgWarp_3 = imwarp(imgTime_3,tform);


imgWarp = imgWarp(:, 1:size(imgWarp_3,2));
imgWarp_2 = imgWarp_2(:,1:size(imgWarp_3,2));
imgWarp_3 = imgWarp_3(2:end,:);

imgCrop = [imgWarp; imgWarp_2; imgWarp_3];
imgCrop(:,[1:round(white_pix/4),end-round(white_pix/4):end]) = 255;

% Resize to correct width, interpolate with bilinear filter
imgResize = imresize(imgCrop,[size(imgCrop,1) width],'bilinear');

% Make all grating posiitons
pixPerDeg_el = height/180;
stripe_height_pix = 2*round(stripe_height_deg * pixPerDeg_el/2);            % find closest even number of pixels to stripe height
stripe_height_deg = stripe_height_pix/pixPerDeg_el;
display(['Adjusted stripe height is ',num2str(stripe_height_deg),' deg'])
white_ind = (height - stripe_height_pix)/2;
for i = 1:size(imgResize,1)
    temp = repmat(imgResize(i,:),height,1);
    temp([1:white_ind,end-white_ind+1:end],:) = 255; 
    imgMat(:,:,i) = imfilter(temp,fspecial('average',[4 4]),'replicate');   % 3rd dimension indexes how many pixels shifted
end

if watch_stripes_move
    for i = 1:size(imgMat,3)
        imshow([imgMat(:,:,i)])
        pause(stimTimeStep)
    end
end

% Get frame index and group into triplets
shiftInd = 1:size(imgMat,3);
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
numLoops = round(stimTotalDuration / per);
if numLoops < 1, numLoops = 1; end
stimTotalDuration = numLoops * per;

%%
if save_stimulus
    eleScale = height;                                                      % Determines resolution of undistorted image at the cost of speed
    aziScale = width;
    stimTotalDuration_msec = stimTotalDuration * 1000;                      % Convert total duration to msec
    stimulusStruct = struct('stimTotalDuration',stimTotalDuration_msec,'imgReset',imgReset,...
        'imgFin',imgFin,'eleScale',eleScale,'aziScale',aziScale,'numLoops',numLoops);
    stimulusStruct(1).imgCell = imgCat;

    fileName = [...
        'grating_',...
        num2str(stripe_num),'_',...
        num2str(stripe_width_deg),'W_',...
        sprintf('%0.1f',stripe_height_deg), 'H_',...
        num2str(osc_amp_deg),'A_',...
        num2str(stripe_freq_hz),'Hz_',...
        num2str(stimTotalDuration),'s'...
        ];
    fileName = regexprep(fileName,'\.','p');

    save(fullfile(save_path,fileName),'stimulusStruct','-v7.3')
    disp(['Saved to ',fullfile(save_path,fileName)])
end

%%
if plot_stim_ind
   figure, hold on
   plot(T,stripe_freq_hz * 2*(stripe_width_pix) *T)
   plot(T,shiftInd,'.')
end

%%
if show_movie
    figure
    tic
    for j = 1:numLoops
        for i = 1:size(imgCat,1)
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
        imgWaterfall = [imgWaterfall;imgMat(end/2,:,i)];
    end
    figure
    imshow([imgWaterfall;imgWaterfall;imgWaterfall])
end

