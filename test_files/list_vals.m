function [items,values] = list_vals(in_vals)
    try
        items = string(in_vals);
        values = num2cell(in_vals);
    catch
        disp(strcat('Could not resolve values'));
    end
end