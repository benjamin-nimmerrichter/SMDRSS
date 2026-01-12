function ax = plotDirectional3D(data, band_db_vals, cf, bandIdx, target)

    ax = getAxes(target);
    cla(ax,'reset')
    hold(ax,'on')

    % --- angle selection (same logic as 2D)
    if numel(unique(data.az)) > numel(unique(data.el))
        az = data.az(:);
        el = zeros(size(az));
    else
        el = data.el(:);
        az = zeros(size(el));
    end

    % --- data for selected band
    r = band_db_vals(bandIdx, :);

    % --- build grid
    az_u = unique(az);
    el_u = unique(el);

    [AZ,EL] = meshgrid(deg2rad(az_u), deg2rad(el_u));
    R = reshape(r, numel(el_u), numel(az_u));

    % --- spherical → cartesian
    [X,Y,Z] = sph2cart(AZ, EL, R);

    % --- plot surface
    surf(ax, X, Y, Z, R, 'EdgeColor','none')

    % --- styling (analogous to 2D)
    axis(ax,'equal')
    view(ax,3)
    grid(ax,'on')

    colormap(ax,'jet')
    colorbar(ax)

    title(ax, sprintf("Directional Response 3D (%d Hz)", round(cf(bandIdx))))
end
