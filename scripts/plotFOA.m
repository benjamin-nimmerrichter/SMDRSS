function ax = plotFOA(cf, band_db_vals, target)

    ax = getAxes(target);

    bar(ax, 1:numel(cf), band_db_vals(:,1))
    xlabel(ax,'f (Hz) \rightarrow')
    ylabel(ax,'L_p dB(SPL) \rightarrow')

    xticks(ax,1:numel(cf))
    xticklabels(ax,round(cf))
    ylim(ax,[0 110])
    xlim(ax,[1 numel(cf)])
    title(ax,"Third octave analysis")
end