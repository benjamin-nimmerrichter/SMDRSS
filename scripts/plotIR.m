function ax = plotIR(sig, fs, leg_lbls, target, ref_data)
    % --- 1. LOGIKA VÝPOČTU (Calculation & Processing) ---
    % Výchozí stav: Async (zobrazujeme to, co přišlo)
    process_type = "Waveform";
    align = true; % Vždy chceme zarovnat na špičku/náběh
    
    % Pokud jsme dostali referenční data, počítáme Impulsní Odezvu
    if ~isempty(ref_data) && ~isempty(ref_data.ref_sig)
        process_type = "Impulse Response";
        
        raw_ref = ref_data.ref_sig;
        raw_ref_fs = ref_data.ref_fs;
        
        % A) Sjednocení Sample Rate (Resampling)
        % Pokud se FS nahrávky liší od FS reference, reference se musí přizpůsobit.
        if raw_ref_fs ~= fs
            [P, Q] = rat(fs / raw_ref_fs);
            raw_ref = resample(raw_ref, P, Q);
        end
        
        % B) Stereo -> Mono (pro xcorr)
        if size(raw_ref, 2) > 1
            raw_ref = raw_ref(:, 1);
        end
        
        % C) Výpočet IR (Dekonvoluce / Cross-Correlation)
        ir_calculated = zeros(size(sig));
        win_len = size(sig, 1);
        
        for ch = 1:size(sig, 2)
            [c, ~] = xcorr(sig(:, ch), raw_ref);
            
            % Najdeme špičku a ořízneme relevantní část
            [~, idx_peak] = max(abs(c));
            
            % 100 vzorků před špičkou, zbytek za ní
            start_pt = max(1, idx_peak - 100); 
            end_pt = min(length(c), start_pt + win_len);
            
            snippet = c(start_pt:end_pt);
            ir_calculated(1:length(snippet), ch) = snippet;
        end
        
        % Přepíšeme původní signál vypočítanou IR
        sig = ir_calculated;
    end
    
    % --- 2. NORMALIZACE ---
    max_val = max(abs(sig(:)));
    if max_val > 0
        sig = sig ./ max_val;
    end

    % --- 3. VYKRESLOVÁNÍ (Plotting Logic) ---
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
        % Smart Zoom: -2ms až +50ms
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