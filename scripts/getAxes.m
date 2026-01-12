function ax = getAxes(target)
% target:
%   - []            draw new window
%   - UIAxes        draw to app
%   - axes handle   draw to existing axes

    if nargin == 0 || isempty(target)
        fig = figure('Position',[100 100 800 500]);
        ax = axes('Parent',fig);
    else
        ax = target;
        cla(ax,'reset');
    end
end