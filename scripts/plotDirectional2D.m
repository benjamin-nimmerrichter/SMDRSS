function plotDirectional2D(data, band_db_vals, cf, min_b, max_b)

    fig = figure('Position',[100 100 800 500]);
    ax = polaraxes(fig);
    hold(ax,'on')

    if numel(unique(data.az)) > numel(unique(data.el))
        phi = deg2rad(data.az);
    else
        phi = deg2rad(data.el);
    end

    min_db = inf;
    max_db = -inf;
    leg = strings(1,max_b-min_b+1);

    k = 1;
    for band = min_b:max_b
        polarplot(ax, phi, band_db_vals(band,:), 'LineWidth',1.2)
        leg(k) = "f = " + round(cf(band)) + " Hz";

        min_db = min(min_db, min(band_db_vals(band,:)));
        max_db = max(max_db, max(band_db_vals(band,:)));
        k = k+1;
    end

    stylePolar2D(ax, min_db, max_db, leg)
end
