function ax = plotFR(x, y, leg_lbls, target)
    % LOGIKA ROZHODOVÁNÍ
    if isempty(target)
        % Pokud je target prázdný, vytvoříme nové okno
        f = figure('Name', 'Frequency Response', 'Color', 'w');
        ax = axes(f);
    else
        % Pokud target existuje (je to app.UIAxes), použijeme ho
        ax = target;
        % Důležité: Vyčistit starý graf v App Designeru, jinak se překrývají
        cla(ax, 'reset'); 
    end

    % VYKRESLOVÁNÍ (zbytek je stejný, jen používáme 'ax')
    semilogx(ax, x, y, 'LineWidth', 1.2)
    grid(ax, 'on')
    xlabel(ax, 'f (Hz) \rightarrow')
    ylabel(ax, 'L_p dB(SPL) \rightarrow')
    yticks(ax, 0:10:110)
    
    core = [2 3 5 10];
    xticks(ax, [core.*10 core.*100 core.*1000 20000])
    xlim(ax, [20 20e3])
    ylim(ax, [0 110])
    title(ax, "Frequency response")
    legend(ax, leg_lbls)
end