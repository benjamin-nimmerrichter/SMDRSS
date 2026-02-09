function ax = plotDirectional3D(data, band_db_vals, cf, bandIdx, target)
    % --- Target Logic ---
    if isempty(target)
        f = figure('Name', '3D Directional Response', 'Color', 'w');
        ax = axes(f);
    else
        ax = target;
        cla(ax, 'reset'); % Essential for 3D views
    end
    
    % --- Data Preparation ---
    % Determine if we have a full sphere or just a slice
    if numel(unique(data.az)) > numel(unique(data.el))
        az = data.az(:);
        el = zeros(size(az)); % Force 2D slice
    else
        el = data.el(:);
        az = zeros(size(el));
    end

    r = band_db_vals(bandIdx, :); 
    
    % --- Grid Generation ---
    az_u = unique(az);
    el_u = unique(el);
    
    % Hack for 'surf': Surf requires a 2D grid (at least 2x2).
    % If data is a 1D slice (e.g., horizontal only), duplicate it to create a strip.
    if numel(el_u) == 1
        el_u = [el_u; el_u + 0.001]; 
        r = [r; r];                 
    elseif numel(az_u) == 1
        az_u = [az_u; az_u + 0.001];
        r = [r; r];
    end

    [AZ, EL] = meshgrid(deg2rad(az_u), deg2rad(el_u));
    
    % Safe reshape
    if numel(AZ) == numel(r)
        R = reshape(r, size(AZ));
    else
        R = r; % Fallback
    end

    % --- Coordinate Transformation (Spherical -> Cartesian) ---
    [X, Y, Z] = sph2cart(AZ, EL, R);

    % --- Plotting ---
    hold(ax, 'on');
    surf(ax, X, Y, Z, R, 'EdgeColor', 'none', 'FaceColor', 'interp');
    
    % --- Styling ---
    axis(ax, 'equal');
    axis(ax, 'vis3d'); % Prevents box resizing during rotation
    grid(ax, 'on');
    view(ax, 3);       % Set default 3D view
    colormap(ax, 'jet');
    
    cb = colorbar(ax);
    cb.Label.String = 'L_p dB(SPL)';

    title(ax, sprintf("Directional Response 3D (%d Hz)", round(cf(bandIdx))));
end