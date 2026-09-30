function rho = get_density_HP(h, HP_coeff , mode)
    % get_density_HP: This function computes the atmospheric density 
    % at a given altitude using the HP model.

    % ensure that altitude be between 100 to 1000 km
    if h < 100
        h = 100;
    elseif h > 960 % since we use upper bound of 1000 km
        h = 960; 
    end

    alt = HP_coeff(:,1); % get altitude values in the first column

    % find the index of the last altitude value 
    % that is less than or equal to h
    idx = find(alt <= h, 1, 'last'); 

    h1 = alt(idx); % get the altitude value at the index
    h2 = alt(idx+1); % get the next altitude value

    % extract the low density value from the table at h1, h2
    rho_low1 = HP_coeff(idx, 2);
    rho_low2 = HP_coeff(idx+1, 2);

    % extract the high density value from the table at h1, h2
    rho_high1 = HP_coeff(idx, 3);
    rho_high2 = HP_coeff(idx+1, 3);

    H_low = (h1-h2) / log(rho_low1/rho_low2);
    H_high = (h1-h2) / log(rho_high1/rho_high2);

    % get rho at h, for both low and high density
    rho_m = rho_low1 * exp((h1-h) / H_low); % low model at altitude h
    rho_h = rho_high1 * exp((h1-h) / H_high); % high model at altitude h

    % add the flag to choose between low and high model or average

    switch mode
        case 'low'
            rho = rho_m;
        case 'high'
            rho = rho_h;
        case 'average'
            rho = 0.5 * (rho_m + rho_h);
    end
end