function frame_one_labeled = locatorVisualFun(frame_one_visual,locator_record)

%%%%% Generate visual readout of locator results
report_labels = {'Decision:','Template R-square:','Template threshold:',...
    'Gender:','Gender R-square:','Gender threshold:','Fly length:'};
report_vals = cell(1,numel(report_labels));
fail_ops = {'Single, Trackable Fly','Empty or Multi','Fly Not Found'};
report_vals{1} = fail_ops{locator_record.pass_or_fail{:}};
report_vals{2} = locator_record.template_R_square{:};
report_vals{3} = locator_record.template_threshold{:};
form_winr = locator_record.gender_ref{:};
form_winrB = locator_record.gender_guess{:};
if ~isempty(form_winr)
    form_ops = {'Female','Male','Unknown'};
    report_vals{4} = form_ops{form_winr};
    if form_winr == 3
        report_vals{4} = [form_ops{form_winr} ', guessing ' form_ops{form_winrB}];
    end
    report_vals{5} = locator_record.gender_R_square{:};
    report_vals{6} = locator_record.gender_threshold{:};
    fly_length = locator_record.fly_length{:};
    length_in_mm = round(fly_length*100*(5/250))/100;%prism is 5mm and ~250 pixels wide
    report_vals{7} = [num2str(length_in_mm,2) ' mm'];
end
final_report = cat(1,report_labels,report_vals);
report_block = zeros(size(frame_one_visual,1),280);
char_blanks = repmat({' '},size(final_report));
reports_title = 'FLY LOCATOR RESULTS';
labels_cell = cat(1,final_report,char_blanks);
labels_cell = cat(1,reports_title,char_blanks(:,1),labels_cell(:));
report_block = textN2im(report_block,labels_cell,12,[0.1 0.3]);
frame_one_labeled = cat(2,repmat(uint8(report_block.*255),[1 1 3]),frame_one_visual);
