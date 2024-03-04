
org_val = 210000;
downpayment = 10000;
base_price = org_val-downpayment;
curr_apr = (.0429/30);

total_days = 12*30;    %30 years
new_price = zeros(length(total_days),1);
for iterZ = 1:total_days
    if iterZ == 1
        end_price = base_price*(curr_apr)+base_price;
    else
        end_price = end_price*(curr_apr)+end_price;
    end
    end_price = round(end_price*100)/100;
    new_price(iterZ) = end_price;
end

new_price = arrayfun(@(x) sprintf('%6.2f',x),new_price,'uniformoutput',false)';
monthly_payment = max(str2double(new_price{end}))/12/30;

etimated_pmi = (base_price*.0052)/12;

%6 years of pmi making min payments