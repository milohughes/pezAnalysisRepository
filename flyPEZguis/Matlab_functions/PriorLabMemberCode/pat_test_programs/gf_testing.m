test_data_gf_50   = Experiment_ID('0099000023960701');
test_data_gf_40   = Experiment_ID('0099000023960709');
test_data_gf_30   = Experiment_ID('0099000023960708');
test_data_gf_20   = Experiment_ID('0099000023960707');
test_data_gf_10   = Experiment_ID('0099000023960705');

test_data_gf_50.load_data;  test_data_gf_50.make_tables;    test_data_gf_50.get_tracking_data;   test_data_gf_50.display_data;
test_data_gf_40.load_data;  test_data_gf_40.make_tables;    test_data_gf_40.get_tracking_data;   test_data_gf_40.display_data;
test_data_gf_30.load_data;  test_data_gf_30.make_tables;    test_data_gf_30.get_tracking_data;   test_data_gf_30.display_data;
test_data_gf_20.load_data;  test_data_gf_20.make_tables;    test_data_gf_20.get_tracking_data;   test_data_gf_20.display_data;
test_data_gf_10.load_data;  test_data_gf_10.make_tables;    test_data_gf_10.get_tracking_data;   test_data_gf_10.display_data;

gf_50_data = [test_data_gf_50.Complete_usuable_data;test_data_gf_50.Videos_Need_To_Work];
gf_40_data = [test_data_gf_40.Complete_usuable_data;test_data_gf_40.Videos_Need_To_Work];
gf_30_data = [test_data_gf_30.Complete_usuable_data;test_data_gf_30.Videos_Need_To_Work];
gf_20_data = [test_data_gf_20.Complete_usuable_data;test_data_gf_20.Videos_Need_To_Work];
gf_10_data = [test_data_gf_10.Complete_usuable_data;test_data_gf_10.Videos_Need_To_Work];