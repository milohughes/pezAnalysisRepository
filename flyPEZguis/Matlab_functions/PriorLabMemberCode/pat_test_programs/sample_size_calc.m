
index = 1;
samp_range = 20:1:200;
pct_range = .25:.25:.75;
results = zeros(length(pct_range),length(samp_range));

for iterZ = samp_range
    pct_indx = 1;
    for iterP = pct_range

        x = round(iterP*iterZ);
        n = iterZ;
        alpha = .05;
        phat =  x ./ n;
        z=sqrt(2).*erfcinv(alpha);
        den=1+(z^2./n);xc=(phat+(z^2)./(2*n))./den;
        halfwidth=(z*sqrt((phat.*(1-phat)./n)+(z^2./(4*(n.^2)))))./den;
        wsi=[xc(:) xc(:)]+[-halfwidth(:) halfwidth(:)];

        results(pct_indx,index) = phat - min(wsi);
        pct_indx = pct_indx + 1;
    end
    index = index + 1;    
end
results = cell2table(num2cell(results));
results.Properties.RowNames = arrayfun(@(x) sprintf('%2.4f%%',x*100),pct_range,'uniformoutput',false);
results.Properties.VariableNames = arrayfun(@(x) sprintf('N_%03.0f',x),samp_range,'uniformoutput',false);

figure
plot(samp_range,table2array(results));
legend('25%','50%','75%')