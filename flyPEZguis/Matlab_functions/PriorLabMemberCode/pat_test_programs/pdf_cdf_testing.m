function [f,x_index,prob_short] = pdf_cdf_testing(input_x,x_index,scat_color,display)
    %% Generate N Gaussianly Distributed Random Variable with specific mean and
    repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(fullfile(repositoryDir,'Support_Programs'))

    input_x(isnan(input_x)) = [];

    %% Points for which PDF are to be evaluated
    if nargin == 1
        x_index = log(linspace(1,200,1000));
        scat_color = rgb('red');
        display = 'show';
    elseif nargin == 2
        scat_color = rgb('red');
        display = 'show';
    elseif nargin == 3
        display = 'show';        
    end
    %% Estimate PDF
    [f,~] = EstimateDistribution(input_x,x_index);
    %% Plot Results
    f(f<0) = 0;
    prob_short = 1-trapz(x_index(x_index>=log(41/6)),f(x_index>=log(41/6)));    
    if strcmp(display,'show')
        plot(x_index,f,'-','color',scat_color,'linewidth',1.2);
        set(gca,'nextplot','add')
        drawnow;
        
    end
end