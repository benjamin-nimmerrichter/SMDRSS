function ax = plotFR(x, y, leg_lbls, target)

    ax = getAxes(target);

    semilogx(ax, x, y, 'LineWidth',1.2)
    grid(ax,'on')

    xlabel(ax,'f (Hz) \rightarrow')
    ylabel(ax,'L_p dB(SPL) \rightarrow')

    yticks(ax,0:10:110)
    core = [2 3 5 10];
    xticks(ax,[core.*10 core.*100 core.*1000 20000])

    xlim(ax,[20 20e3])
    ylim(ax,[0 110])
    title(ax,"Frequency response")
    legend(ax,leg_lbls)
end