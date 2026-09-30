function [rECI] = perifocalToECI(p, q, i_rad, RAAN_rad, w_rad)

    % Perifocal vector
    r_peri = [p; q; 0];

    % Define the individual rotation matrices
    Rz_neg_RAAN = [ cos(-RAAN_rad), sin(-RAAN_rad), 0
                    -sin(-RAAN_rad),  cos(-RAAN_rad), 0
                    0,               0,              1 ];

    Rx_neg_i = [ 1,           0,            0
                    0, cos(-i_rad), sin(-i_rad)
                    0, -sin(-i_rad),  cos(-i_rad) ];

    Rz_neg_w = [ cos(-w_rad), sin(-w_rad), 0
                    -sin(-w_rad),  cos(-w_rad), 0
                    0,            0,           1 ];

    % Combined rotation
    % Note that matrix multiplication is right to left when applied to vectors
    rECI = Rz_neg_RAAN * ( Rx_neg_i * ( Rz_neg_w * r_peri ) );
end
    