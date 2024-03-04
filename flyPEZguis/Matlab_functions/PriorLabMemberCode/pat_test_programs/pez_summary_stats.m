Summary_stats = load('C:\Users\BREADSP\Documents\Summary_stats.mat');

%% runs per day hist
figure
total_runs = cell2mat(Summary_stats.run_table(8:end,2));
hist(total_runs,0:10:80)

%% videos per day
figure;
daily_totals = Summary_stats.date_table.Variables;
daily_totals = daily_totals(:,8:end);
hist(sum(daily_totals),0:100:1500);

%% vids per run

vpr = sum(daily_totals) ./ total_runs';
figure
hist(vpr);