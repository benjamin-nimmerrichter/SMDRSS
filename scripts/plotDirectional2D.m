function plotDirectional2D(data, band_db_vals, cf, min_b, max_b, target)
    % --- 1. Target Logic (Axes Preparation) ---
    if isempty(target)
        fig = figure('Position',[100 100 800 600], 'Name', 'Directional Response');
        ax = polaraxes(fig);
    elseif isa(target, 'matlab.ui.control.UIAxes')
        parent = target.Parent;
        delete(target); 
        ax = polaraxes(parent); 
        ax.Position = [0.1 0.1 0.8 0.8]; 
    else
        if isa(target, 'matlab.graphics.axis.PolarAxes')
            ax = target;
            cla(ax, 'reset');
        else
            ax = polaraxes(target);
        end
    end
    
    % --- 2. Plane Detection and Orientation Setup ---
    
    num_az = numel(unique(data.az));
    num_el = numel(unique(data.el));
    
    if num_az > num_el
        % === HORIZONTAL (Azimuth) ===
        % 0° points up (Top)
        plot_angles = data.az;
        plot_title = "Horizontal Directivity (Azimuth)";
        zero_loc = 'top';       
        theta_dir = 'clockwise'; % For horizontal, we usually go clockwise
    else
        % === VERTICAL (Elevation) ===
        % 0° points right -> so that 90° is at the top
        plot_angles = data.el;
        plot_title = "Vertical Directivity (Elevation)";
        zero_loc = 'right';     
        theta_dir = 'counterclockwise'; % For vertical, we want +90° up (mathematically positive direction)
    end
    
    % Sort angles for correct line plotting
    [sorted_angles, sort_idx] = sort(plot_angles);
    phi = deg2rad(sorted_angles);
    band_db_vals_sorted = band_db_vals(:, sort_idx);
    
    % --- 3. Plotting ---
    hold(ax, 'on');
    
    min_db = inf; 
    max_db = -inf;
    num_curves = max_b - min_b + 1;
    leg_lbls = strings(1, num_curves);
    k = 1;
    
    for band = min_b:max_b
        vals = band_db_vals_sorted(band, :);
        polarplot(ax, phi, vals, 'LineWidth', 1.5);
        
        % Min/Max tracking
        current_min = min(vals);
        current_max = max(vals);
        if current_min < min_db, min_db = current_min; end
        if current_max > max_db, max_db = current_max; end
        
        leg_lbls(k) = string(round(cf(band))) + " Hz";
        k = k + 1;
    end
    
    hold(ax, 'off');
    
    % --- 4. Styling (passing zero_loc and theta_dir) ---
    if isinf(min_db), min_db = -100; end
    if isinf(max_db), max_db = 0; end
    stylePolar2D(ax, min_db, max_db, leg_lbls, plot_title, zero_loc, theta_dir);
end