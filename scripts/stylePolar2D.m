function stylePolar2D(ax, min_val, max_val, leg_lbls, plot_title, zero_loc, theta_dir)
    % Apply orientation (Horizontal = Top/CW, Vertical = Right/CCW)
    ax.ThetaZeroLocation = zero_loc;
    ax.ThetaDir = theta_dir;
    
    % Grid and title
    grid(ax, 'on');
    ax.GridAlpha = 0.4;
    title(ax, plot_title, 'FontWeight', 'bold', 'FontSize', 12);
    
    % Legend
    if ~isempty(leg_lbls)
        legend(ax, leg_lbls, 'Location', 'bestoutside', 'Interpreter', 'none');
    end
    
    % --- Smart dB scaling ---
    range_span = 50; 
    
    upper_lim = ceil(max_val / 5) * 5; 
    if upper_lim < max_val + 2
        upper_lim = upper_lim + 5;
    end
    
    lower_lim = upper_lim - range_span;
    
    if min_val < lower_lim
        lower_lim = floor(min_val / 10) * 10;
    end
    
    rlim(ax, [lower_lim, upper_lim]);
    
    % Axis labels
    try
        ax.RAxis.Label.String = 'Amplitude (dB)';
    catch
    end
end