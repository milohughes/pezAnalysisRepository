clear all
close all
clc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, one must plase run folders into a file named 'raw_videos' 
% within the 'speciesFolder' below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
speciesFolder = 'Drosophila_melanogaster';


%%%%% computer and directory variables and information
op_sys = system_dependent('getos');
if strfind(op_sys,'Microsoft Windows 7')
    archDir = [filesep filesep 'tier2' filesep 'card'];
    dm11Dir = [filesep filesep 'dm11' filesep 'cardlab'];
else
    archDir = [filesep 'Volumes' filesep 'card'];
    if ~exist(archDir,'file')
        archDir = [filesep 'Volumes' filesep 'card-1'];
    end
    dm11Dir = [filesep 'Volumes' filesep 'cardlab'];
end
if ~exist(archDir,'file')
    error('Archive access failure')
end
if ~exist(dm11Dir,'file')
    error('dm11 access failure')
end

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
addpath(fullfile(repositoryDir,'pezProc_subfunctions'))

run_list_dir = fullfile(archDir,'pez3000_flyTemplates',speciesFolder,'raw_videos');
workingTemplateDir = fullfile(archDir,'pez3000_flyTemplates',speciesFolder,'work_in_progress');
if ~isdir(workingTemplateDir), return, end

%% To determine size boundaries and filtered image collection
% if exist([workingTemplateDir filesep 'template_wip_reviewed.mat'],'file') == 0
    if exist([workingTemplateDir filesep 'template_wip.mat'],'file') == 0
        error('file not found')
    else
        template_making = load([workingTemplateDir filesep 'template_wip.mat']);
        template_init_data = template_making.template_init_data;
        fly_count = template_making.fly_count;
    end
% else
%     template_making = load([workingTemplateDir filesep 'template_wip_reviewed.mat']);
%     template_init_data = template_making.template_init_data;
%     fly_count = template_making.fly_count;
% end
% template_wip = load([workingTemplateDir filesep 'template_wip.mat']);
% template_init_data = template_wip.template_init_data;
% fly_count = template_wip.fly_count;

full_bounds = zeros(2,2);
small_bounds = zeros(2,2);
form_int = struct([]);
geno_int = struct([]);
dwnsampl_factor = 0.5;
for i = 1:2
    points = template_init_data(i).points;
    points_mat = cell2mat(points);
    points_size = size(points_mat);
    optimat = reshape(points_mat,2,2,points_size(2)/2);
    X = squeeze(optimat(1,:,:))';
    Y = squeeze(optimat(2,:,:))';
    dists = diag(pdist2(X,Y));
    full_bounds(i,1) = floor(prctile(dists,5)/2)*2;
    full_bounds(i,2) = ceil(prctile(dists,95)/2)*2;
    small_bounds(i,:) = round(full_bounds(i,:).*dwnsampl_factor);
    size_range = full_bounds(i,2)-full_bounds(i,1);
    pts_per_bin = 3;
    bins = round(linspace(full_bounds(i,1),full_bounds(i,2),size_range/pts_per_bin));
    dist_hist = hist(dists,bins);
%     figure, bar(bins,dist_hist)
%     uiwait(gcf)
    
    training_image_cell = template_init_data(i).images;
    training_count = fly_count(i);
    I_filt_cell = cell(1,training_count);
    I_lined_cell = cell(1,training_count);
    I_small_cell = cell(1,training_count);
    parfor j = 1:training_count
        I = training_image_cell{j};
        imAdjInput = stretchlim(I,[0.01 0.999]);
        I_nobakadj = imadjust(I,imAdjInput);
        I_nobakfilt = hotFilter(I_nobakadj);
        I_filtlined = lineMaker(I_nobakfilt);
        
%         imshow([I_nobakadj I_nobakfilt I_filtlined])
%         uiwait(gcf)
        
        I_small = imresize(I_nobakfilt,dwnsampl_factor);
        I_filt_cell{j} = I_nobakfilt;
        I_lined_cell{j} = I_filtlined;
        I_small_cell{j} = I_small;
        
        half_points{j} = points{j}*dwnsampl_factor;%only for small image
    end
    form_int(i).images = training_image_cell;
    form_int(i).images_filtered = I_filt_cell;
    form_int(i).images_lined = I_lined_cell;
    form_int(i).images_small = I_small_cell;
    form_int(i).points = points;
    form_int(i).half_points = half_points;
    form_int(i).fly_count = fly_count(i);
    form_int(i).full_bounds = full_bounds(i,:);
    form_int(i).small_bounds = small_bounds(i,:);
end

indexer_bounds = [min(full_bounds(:,1)) max(full_bounds(:,2))];
geno_int = struct('dwnsampl_factor',dwnsampl_factor,'indexer_bounds',indexer_bounds);
save([workingTemplateDir filesep 'template_interim.mat'],'geno_int','form_int')

%% Generate preliminary composites to later be refined
template_interim = load([workingTemplateDir filesep 'template_interim.mat']);
form_int = template_interim.form_int;
geno_int = template_interim.geno_int;

for k = 1:2
    
    I_filt_cell = form_int(k).images_small;
    I_lined_cell = form_int(k).images_lined;
    training_count = form_int(k).fly_count;
    
    fly_length = mean(form_int(k).full_bounds);%average fly length, gender-specific
    whole_fly_factorX = 1/2;%resampling factor for whole fly
    whole_fly_factorY = 0.7;%sets frame size in fly width dimension
    whole_frame_factor = 1.25;%frame size relative to adjusted fly length
    whole_XData = [1 round(fly_length*whole_fly_factorX*whole_frame_factor/2)*2+1];
    whole_YData = [1 round(whole_XData(2)*whole_fly_factorY/2)*2+1];
    whole_dests = [median(whole_XData)-fly_length/2*whole_fly_factorX,...
        median(whole_YData);
        median(whole_XData)+fly_length/2*whole_fly_factorX,...
        median(whole_YData)];
    whole_aligned_array = zeros(whole_YData(2),whole_XData(2),training_count);
    I_aligned_visual = cell(training_count,1);
    for j = 1:training_count
        ex_pts = form_int(k).points{j};
        Q_tform = cp2tform(ex_pts,whole_dests,'nonreflective similarity');
        I_aligned = imtransform(I_lined_cell{j},Q_tform,'XData',whole_XData,...
            'YData',whole_YData,'FillValues',0.01);
        I_aligned_visual{j} = imtransform(I_filt_cell{j},Q_tform,'XData',whole_XData,...
            'YData',whole_YData,'FillValues',0.01);
        I_aligned(I_aligned <= 0) = min(I_aligned(I_aligned > 0));
        I_aligned(I_aligned > 1) = 1;
        I_aligned = geomean(cat(3,I_aligned,flipud(I_aligned)),3);
        whole_aligned_array(:,:,j) = I_aligned;
    end
    
    imshow(mean(whole_aligned_array,3))
    hold on
    plot(whole_dests(:,1),whole_dests(:,2),'.','MarkerSize',22,'Color',[1 0 0])
    hold off    
    uiwait(gcf)
    form_int(k).full.whole_aligned_array = whole_aligned_array;
    form_int(k).full.whole_dests = whole_dests;
    form_int(k).full.whole_XData = whole_XData;
    form_int(k).full.whole_YData = whole_YData;
end


save([workingTemplateDir filesep 'template_interim.mat'],'geno_int','form_int')

%% To refine position of each image used in average, minimizing variation
template_interim = load([workingTemplateDir filesep 'template_interim.mat']);
geno_int = template_interim.geno_int;
form_int = template_interim.form_int;

pt_mag = 1;
pt_count = 3;
pt_leg = (pt_count-1)/2;
adj1 = linspace(-pt_leg*pt_mag,pt_leg*pt_mag,pt_count);
adj2_1 = repmat(adj1,pt_count^3,1);
adj2_2 = repmat(adj1,pt_count^2,pt_count);
adj2_3 = repmat(adj1,pt_count,pt_count^2);
adj2_4 = repmat(adj1,1,pt_count^3);
adj3 = cat(3,[adj2_1(:) adj2_2(:)],[adj2_3(:) adj2_4(:)]);
adj3 = permute(adj3,[3 2 1]);
adj4 = adj3;

pt_mag = 2;
pt_count = 3;
pt_leg = (pt_count-1)/2;
adj1 = linspace(-pt_leg*pt_mag,pt_leg*pt_mag,pt_count);
adj2_1 = repmat(adj1,pt_count^3,1);
adj2_2 = repmat(adj1,pt_count^2,pt_count);
adj2_3 = repmat(adj1,pt_count,pt_count^2);
adj2_4 = repmat(adj1,1,pt_count^3);
adj3 = cat(3,[adj2_1(:) adj2_2(:)],[adj2_3(:) adj2_4(:)]);
adj3 = permute(adj3,[3 2 1]);
adj4 = cat(3,adj4,adj3);

trial_count = pt_count^4*2;

for m = 1:2  % female or male
    I_cell = form_int(m).images_lined;
    points = form_int(m).points;
    training_count = form_int(m).fly_count;
    full = form_int(m).full;
    
    whole_XData = full.whole_XData;
    whole_YData = full.whole_YData;
    whole_dests = full.whole_dests;
    
    part1_aligned_array = full.whole_aligned_array(:,1:median(whole_XData),:);
    adj_ops = repmat(adj4,[1 1 1 training_count]);
    opti_dests1 = repmat(whole_dests,[1 1 training_count]);
    trial1 = [];
    
    for z = 1:3
        ranking_array = part1_aligned_array;
        ranking_lines = reshape(ranking_array,whole_YData(2)*median(whole_XData),training_count);
        ranking_cormat = corrcoef([mean(ranking_lines,2) ranking_lines]);
        ranking_corvec = ranking_cormat(2:end,:);
        [ranking_sorted sorted_index] = sort(ranking_corvec,'descend');
        ranked_index = sorted_index(1:round(training_count*.5));
        ranked_aligned_array = ranking_array(:,:,ranked_index);
        optimizer_template = mean(ranked_aligned_array,3);
        optimizer_sum = sum(optimizer_template(:));
        blank_array = zeros(whole_YData(2),median(whole_XData),trial_count);
        for i = 1:training_count
            training_pts = points{i};
            training_dest = opti_dests1(:,:,i);
            training_adjust = adj_ops(:,:,:,i);
            
            trial_diff = zeros(1,trial_count);
            trial_array = blank_array;
            for j = 1:trial_count
                
                trial_dest = training_dest+training_adjust(:,:,j);
                
                Q_tform = cp2tform(training_pts,trial_dest,'nonreflective similarity');
                I_aligned = imtransform(I_cell{i},Q_tform,'XData',whole_XData,...
                    'YData',whole_YData,'FillValues',0.01);
                I_aligned(I_aligned <= 0) = min(I_aligned(I_aligned > 0));
                I_aligned(I_aligned > 1) = 1;
                I_aligned = geomean(cat(3,I_aligned,flipud(I_aligned)),3);
                trial_array(:,:,j) = I_aligned(:,1:median(whole_XData));
                aligned_diff = optimizer_template-I_aligned(:,1:median(whole_XData));
                trial_diff(j) = 1-sum(aligned_diff(aligned_diff >= 0))/optimizer_sum;
            end
            opti_ref = find(max(trial_diff) == trial_diff,1);
            opti_dests1(:,:,i) = training_dest+training_adjust(:,:,opti_ref);
            part1_aligned_array(:,:,i) = trial_array(:,:,opti_ref);
            diff_tally(i,:) = trial_diff;
        end
        mean(diff_tally(:))
        
        trial1 = [trial1;optimizer_template];
    end
    
    part2_aligned_array = full.whole_aligned_array(:,median(whole_XData)+1:end,:);
    adj_ops = repmat(adj4,[1 1 1 training_count]);
    opti_dests2 = repmat(whole_dests,[1 1 training_count]);
    
    trial2 = [];
    
    for z = 1:3
        ranking_array = part2_aligned_array;
        ranking_lines = reshape(ranking_array,whole_YData(2)*(median(whole_XData)-1),training_count);
        ranking_cormat = corrcoef([mean(ranking_lines,2) ranking_lines]);
        ranking_corvec = ranking_cormat(2:end,:);
        [ranking_sorted sorted_index] = sort(ranking_corvec,'descend');
        ranked_index = sorted_index(1:round(training_count*.5));
        ranked_aligned_array = ranking_array(:,:,ranked_index);
        optimizer_template = mean(ranked_aligned_array,3);
        optimizer_sum = sum(optimizer_template(:));
        blank_array = zeros(whole_YData(2),median(whole_XData)-1,trial_count);
        parfor i = 1:training_count
            training_pts = points{i};
            training_dest = opti_dests2(:,:,i);
            training_adjust = adj_ops(:,:,:,i);
            
            trial_diff = zeros(1,trial_count);
            trial_array = blank_array;
            for j = 1:trial_count
                
                trial_dest = training_dest+training_adjust(:,:,j);
                
                Q_tform = cp2tform(training_pts,trial_dest,'nonreflective similarity');
                I_aligned = imtransform(I_cell{i},Q_tform,'XData',whole_XData,...
                    'YData',whole_YData,'FillValues',0.01);
                I_aligned(I_aligned <= 0) = min(I_aligned(I_aligned > 0));
                I_aligned(I_aligned > 1) = 1;
                I_aligned = geomean(cat(3,I_aligned,flipud(I_aligned)),3);
                trial_array(:,:,j) = I_aligned(:,median(whole_XData)+1:end);
                aligned_diff = optimizer_template-I_aligned(:,median(whole_XData)+1:end);
                trial_diff(j) = 1-sum(aligned_diff(aligned_diff >= 0))/optimizer_sum;
            end
            opti_ref = find(max(trial_diff) == trial_diff,1);
            opti_dests2(:,:,i) = training_dest+training_adjust(:,:,opti_ref);
            part2_aligned_array(:,:,i) = trial_array(:,:,opti_ref);
            diff_tally(i,:) = trial_diff;
        end
        mean(diff_tally(:))

        trial2 = [trial2;optimizer_template];
    end
    
    ranking_array = part1_aligned_array;
    ranking_lines = reshape(ranking_array,whole_YData(2)*median(whole_XData),training_count);
    ranking_cormat = corrcoef([mean(ranking_lines,2) ranking_lines]);
    ranking_corvec = ranking_cormat(2:end,:);
    [ranking_sorted sorted_index] = sort(ranking_corvec,'descend');
    ranked_index1 = sorted_index(1:round(training_count*.5));
    ranked_aligned_array1 = ranking_array(:,:,ranked_index1);
    
    ranking_array = part2_aligned_array;
    ranking_lines = reshape(ranking_array,whole_YData(2)*(median(whole_XData)-1),training_count);
    ranking_cormat = corrcoef([mean(ranking_lines,2) ranking_lines]);
    ranking_corvec = ranking_cormat(2:end,:);
    [ranking_sorted sorted_index] = sort(ranking_corvec,'descend');
    ranked_index2 = sorted_index(1:round(training_count*.5));
    ranked_aligned_array2 = ranking_array(:,:,ranked_index2);
    optimizer_template = mean([ranked_aligned_array1 ranked_aligned_array2],3);
    
    figure,imshow([trial1 trial2;optimizer_template])
    %     uiwait(gcf)
    
    full.hort_dests = {opti_dests1,opti_dests2};
    full.hort_ranked_ndcs = {ranked_index1,ranked_index2};
    full.optimized_aligned_array = [ranked_aligned_array1 ranked_aligned_array2];
    form_int(m).full = full;
end

save([workingTemplateDir filesep 'template_interim.mat'],'geno_int','form_int')

%%
template_interim = load([workingTemplateDir filesep 'template_interim.mat']);
geno_int = template_interim.geno_int;
form_int = template_interim.form_int;

template_names = {[speciesFolder '_lowResTemplate'],...
    [speciesFolder '_highResTemplate'],...
    [speciesFolder '_flyDetectTemplate'],...
    [speciesFolder '_flyDetectTemplate_hortRot']};
spokeCtOps = [48 84 36 120];%small 48, highres 84, flyDetect 36 and 120
spokeLengthOps = [16 22 8 8];%small 16, highres 22, flyDetect 8

for iterTmpl = 1:4
    spoke_count = spokeCtOps(iterTmpl);
    target_spoke_length = spokeLengthOps(iterTmpl);
    size_factor = 0.6;
    coverage = 1.5;
    
    
    indexer_bounds = geno_int.indexer_bounds.*geno_int.dwnsampl_factor;
    indexer_struct = hotIndexer2(spoke_count,target_spoke_length,...
        indexer_bounds,size_factor,coverage);
    
    indexer = indexer_struct.average_indexer;
    half_sml = indexer_struct.half_sml;
    half_lrg = indexer_struct.half_lrg;
    avg_spoke_length = indexer_struct.avg_spoke_length;
    trg_spoke_length = indexer_struct.trg_spoke_length;
    source_dim = indexer_struct.image_dim;
    source_center = (source_dim-1)/2+1;
    
    hort_inset = [round(half_sml*0.3) round(half_sml*0.5)];
    hort_pt_dests = {[half_sml+hort_inset(1)-3 source_center
        -half_sml+hort_inset(1)-3 source_center],...
        [source_dim+half_sml-hort_inset(2)+3 source_center
        +source_dim-half_sml-hort_inset(2)+3 source_center]};
    
    for k = 1:2
        form_ref = k;
        full_int = form_int(k).full;
        I_filt_cell = form_int(k).images_small;
        %     I_filt_cell = full.optimized_aligned_array;
        I_lined_cell = form_int(k).images_lined;
        training_count = form_int(k).fly_count;
        %     training_count = size(I_filt_cell,3);
        for i = 1:2
            hort_ref = i;
            ranked_ndcs = full_int.hort_ranked_ndcs{hort_ref};
            hort_dests = hort_pt_dests{hort_ref};
            sorted_array = zeros(avg_spoke_length,spoke_count,training_count);
            aligned_array = zeros(source_dim,source_dim,training_count);
            parfor j = 1:training_count
                I_filt = I_filt_cell{j};
                %             I_filt = I_filt_cell(:,:,j);
                ex_pts = form_int(k).half_points{j};
                %             ex_pts = full.whole_dests;
                Q_tform = cp2tform(ex_pts,hort_dests,'nonreflective similarity');
                I_aligned = imtransform(I_filt,Q_tform,'XData',[1 source_dim],...
                    'YData',[1 source_dim],'FillValues',0.01);
                aligned_array(:,:,j) = I_aligned;
                I_mat = I_aligned(indexer);
                sorted_array(:,:,j) = I_mat;
                
            end
            radians = 0;
            hort_multiplier = [-1 1];
            hort_factor = hort_multiplier(hort_ref);
            inset_adjusted = hort_inset(hort_ref)*hort_factor*(-1);
            [adj_x adj_y] = pol2cart(radians,inset_adjusted);
            trg_outset = [source_center source_center]+[adj_x -adj_y];
            imshow(mean(aligned_array,3),'initialmagnification',300)
            hold on
            plot(source_center,source_center,'.','MarkerSize',22,'Color',[1 0 0])
            plot(trg_outset(1),trg_outset(2),'.','MarkerSize',22,'Color',[0 1 0])
            hold off
            uiwait(gcf,1)
            close(gcf)
            imshow(mean(sorted_array,3),'initialmagnification',300)
            uiwait(gcf,1)
            close(gcf)
            form_int(k).hort_data(hort_ref).sorted_arrays = sorted_array(:,:,ranked_ndcs);
            form_int(k).hort_data(hort_ref).aligned_arrays = aligned_array(:,:,ranked_ndcs);
            form_int(k).hort_data(hort_ref).hort_dests = hort_dests;
        end
    end
    
    geno_int.spoke_count = spoke_count;
    geno_int.target_spoke_length = target_spoke_length;
    geno_int.hort_inset = hort_inset;
    geno_int.size_factor = size_factor;
    
    size_iters = avg_spoke_length-trg_spoke_length+1;
    size_options = linspace(indexer_bounds(1),indexer_bounds(2),size_iters);
    size_index = (1:size_iters);
    form = struct([]);
    hort_template = cell(1,2);
    hort_size_ref_list = cell(1,2);
    geno = struct([]);
    for k = 1:2 % heads or tails ('HorT')
        hort_ref = k;
        form_template = cell(1,2);
        form_size_ref_list = cell(1,2);
        for m = 1:2 % female or male ('ForM')
            form_ref = m;
            
            bounds = form_int(form_ref).small_bounds;
            small_vec = abs(repmat(bounds(1),1,size_iters)-size_options);
            large_vec = abs(repmat(bounds(2),1,size_iters)-size_options);
            small_ref = find(min(small_vec) == small_vec);
            large_ref = find(min(large_vec) == large_vec);
            size_logical = zeros(1,size_iters);
            size_logical(small_ref:large_ref) = 1;
            
            size_ref_list = size_index(logical(size_logical));
            size_count = length(size_ref_list);
            form_size_ref_list{form_ref} = size_ref_list;
            form(form_ref).size_count = size_count;
            template_array = form_int(form_ref).hort_data(hort_ref).sorted_arrays;
            template_mat = mean(template_array,3);
            template_2D = zeros(trg_spoke_length,spoke_count,size_iters);
            full_template_3D = zeros(trg_spoke_length*spoke_count,size_iters,spoke_count);
            for z = 1:size_iters
                template_1D = template_mat(size_iters-z+1:end-z+1,:);
                %             imshow(template_1D,[])
                %             uiwait(gcf)
                template_2D(:,:,z) = template_1D;
            end
            for z = 1:spoke_count
                circ_template3D = circshift(template_2D,[0 (z-1) 0]);
                circ_template2D = reshape(circ_template3D,trg_spoke_length*spoke_count,size_iters);
                full_template_3D(:,:,z) = circ_template2D;
            end
            full_template_3D = permute(full_template_3D,[1 3 2]);
            sized_template_3D = full_template_3D(:,:,size_ref_list);
            form_template{form_ref} = sized_template_3D;
        end
        size_sum = sum([form.size_count]);
        hort_size_ref_list{hort_ref} = [form_size_ref_list{1} form_size_ref_list{2}];
        hort_template{hort_ref} = cat(3,form_template{1},form_template{2});
    end
    geno(1).template_3D = cat(3,hort_template{1},hort_template{2});
    geno.form_refs = repmat([ones(1,form(1).size_count),...
        ones(1,form(2).size_count)*2]',2,1);
    geno.hort_refs = [ones(1,size_sum) ones(1,size_sum)*2];
    geno.size_refs = [hort_size_ref_list{1} hort_size_ref_list{2}];
    geno.size_options = size_options;
    geno.indexer_3D = repmat(indexer_struct.target_indexer(:),[1 spoke_count size_sum*2]);
    geno.source_dim = source_dim;
    geno.dwnsampl_factor = geno_int.dwnsampl_factor;
    geno.hort_inset = hort_inset;
    
    
    for m = 1:2
        form_ref = m;
        full_int = form_int(form_ref).full;
        crop_Y = round(full_int.whole_YData(2)/4);
        
        init_dests = full_int.whole_dests-[0 crop_Y;0 crop_Y];
        full_image = mean(full_int.optimized_aligned_array,3);
        full_image_crop = full_image(1+crop_Y:end-crop_Y,:);
        mid_pt = median(init_dests);
        imshow(full_image_crop,'InitialMagnification',400)
        hold on
        plot(init_dests(1,1),init_dests(1,2),'.','MarkerSize',22,'Color',[0 1 0])
        plot(init_dests(2,1),init_dests(2,2),'.','MarkerSize',22,'Color',[0 0 1])
        plot(mid_pt(1),mid_pt(2),'.','MarkerSize',22,'Color',[1 0 0])
        hold off
        uiwait(gcf,1)
        close(gcf)
        full_segment_count = 6;
        full_segment = (init_dests(2,1)-init_dests(1,1))/full_segment_count;
        trg_steps = (round(full_segment*0.9):...
            round(max(size_options)/full_segment_count*1.1));
        trg_step_count = length(trg_steps);
        form(form_ref).full(1).trg_steps = trg_steps;
        form(form_ref).full.image = full_image_crop;
        form(form_ref).full.init_dests = init_dests;
        form(form_ref).full.trg_step_count = trg_step_count;
        form(form_ref).full.full_segment = full_segment;
        form(form_ref).full.full_segment_count = full_segment_count;
        form(form_ref).full.XData = full_int.whole_XData;
        form(form_ref).full.YData = full_int.whole_YData-[0 crop_Y*2];
    end
    
    save(fullfile(archDir,'pez3000_flyTemplates',speciesFolder,...
        template_names{iterTmpl}),'geno','form')
    
end