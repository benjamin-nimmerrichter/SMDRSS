function ax = plotIR(sig, fs, leg_lbls, target, ref_data)
    % --- 1. CALCULATION & PROCESSING LOGIC ---
    % Default state: Async (displaying raw input)
    process_type = "Waveform";
    align = true; % Always align to peak/onset
    
    % If reference data is provided, calculate Impulse Response
    if ~isempty(ref_data) && ~isempty(ref_data.ref_sig)
        process_type = "Impulse Response";
        
        raw_ref = ref_data.ref_sig;
        raw_ref_fs = ref_data.ref_fs;
        
        % A) Unify Sample Rates (Resampling)
        % If recording FS differs from reference FS, adjust the reference.
        if raw_ref_fs ~= fs
            [P, Q] = rat(fs / raw_ref_fs);
            raw_ref = resample(raw_ref, P, Q);
        end
        
        % B) Stereo -> Mono (for xcorr)
        if size(raw_ref, 2) > 1
            raw_ref = raw_ref(:, 1);
        end
        
        % C) Calculate IR (Deconvolution / Cross-Correlation)
        ir_calculated = zeros(size(sig));
        win_len = size(sig, 1);
        
        for ch = 1:size(sig, 2)
            [c, ~] = xcorr(sig(:, ch), raw_ref);
            
            % Find peak and crop relevant part
            [~, idx_peak] = max(abs(c));
            
            % 100 samples before peak, the rest after
            start_pt = max(1, idx_peak - 100); 
            end_pt = min(length(c), start_pt + win_len);
            
            snippet = c(start_pt:end_pt);
            ir_calculated(1:length(snippet), ch) = snippet;
        end
        
        % Overwrite original signal with calculated IR
        sig = ir_calculated;
    end
    
    % --- 2. NORMALIZATION ---
    max_val = max(abs(sig(:)));
    if max_val > 0
        sig = sig ./ max_val;
    end
    
    % --- 3. PLOTTING LOGIC ---
    % --- Target Logic ---
    if isempty(target)
        f = figure('Name', process_type, 'Color', 'w');
        ax = axes(f);
    else
        ax = target;
        cla(ax, 'reset'); 
    end
    % --------------------
    
    hold(ax, 'on'); 
    grid(ax, 'on');
    
    [N, num_channels] = size(sig);
    t_vals = (0:N-1) / fs; 
    
    if align
        % --- ALIGNMENT MODE (Peak at t=0) ---
        for i = 1:num_channels
            current_sig = sig(:, i);
            [~, idx_max] = max(abs(current_sig));
            t_shifted = t_vals - t_vals(idx_max);
            
            plot(ax, t_shifted, current_sig, 'LineWidth', 1.2);
        end
        
        xlabel(ax, 'Time relative to peak (s) \rightarrow');
        % Smart Zoom: -2ms to +50ms
        xlim(ax, [-0.002, 0.050]); 
        
    else
        % --- RAW MODE ---
        plot(ax, t_vals, sig, 'LineWidth', 1.2);
        xlabel(ax, 'Time (s) \rightarrow');
        xlim(ax, [0, max(t_vals)]);
    end
    
    ylabel(ax, 'Normalized Amplitude');
    title(ax, process_type, 'Interpreter', 'none');
    
    if ~isempty(leg_lbls)
        legend(ax, leg_lbls, 'Location', 'best', 'Interpreter', 'none');
    end
    
    hold(ax, 'off');
end