function ax = plotFOA(cf, band_db_vals, target)
    % --- Target Logic (App vs. New Window) ---
    if isempty(target)
        % Create new figure window
        f = figure('Name', 'Third Octave Analysis', 'Color', 'w');
        ax = axes(f);
    else
        % Use existing axes in App Designer
        ax = target;
        cla(ax, 'reset'); % Reset is crucial to clear old plots/settings
    end
    % -----------------------------------------

    % Plot bar chart (Band vs Level)
    bar(ax, 1:numel(cf), band_db_vals(:,1));
    
    % Labels and formatting
    xlabel(ax, 'f (Hz) \rightarrow');
    ylabel(ax, 'L_p dB(SPL) \rightarrow');
    
    % Set X-axis ticks to match frequency bands
    xticks(ax, 1:numel(cf));
    xticklabels(ax, round(cf));
    
    % Axis limits
    ylim(ax, [0 110]);
    xlim(ax, [0.5 numel(cf)+0.5]); % Slight padding
    
    title(ax, "Third octave analysis");
    grid(ax, 'on'); 
end