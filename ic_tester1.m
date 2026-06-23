% =========================================================================
% Universal IC Tester - Analog Signal Processing & System ID Pipeline
% Device Under Test: BJT CE Amplifier (50 Hz Data)
% =========================================================================

%% 0. Configuration
fprintf('Initializing DSP & System ID Pipeline...\n');
data_ch1 = readmatrix('16071.CSV'); 
data_ch2 = readmatrix('16081.CSV');

valid_idx = ~isnan(data_ch1(:, 4)) & ~isnan(data_ch1(:, 5));
t = data_ch1(valid_idx, 4);      
v_in = data_ch1(valid_idx, 5);   
v_out = data_ch2(valid_idx, 5);  
Ts = t(2) - t(1);  
Fs = 1 / Ts;       

%% 1. Time-Domain Parametric Extraction
v_in_pp = max(v_in) - min(v_in);
v_out_pp = max(v_out) - min(v_out);
Av_linear = v_out_pp / v_in_pp;

dc_offset_in = mean(v_in);
dc_offset_out = mean(v_out);

fprintf('\n--- 1. Parametric Extraction Results ---\n');
fprintf('Voltage Gain: %.2f V/V\n', Av_linear);
fprintf('DC Operating Point (Output): %.3f V\n', dc_offset_out);

%% 2. System Identification (Empirical Transfer Function)
% We manually AC couple the signal by subtracting the DC operating point
% This prevents the DC offset from skewing the H(s) estimation
v_in_ac = v_in - dc_offset_in;
v_out_ac = v_out - dc_offset_out;

% Package the data for System ID Toolbox
sys_data = iddata(v_out_ac, v_in_ac, Ts);

% Estimate a 1-pole, 0-zero transfer function
empirical_tf = tfest(sys_data, 1, 0);

% Extract empirical parameters for the text output
[num_emp, den_emp] = tfdata(empirical_tf, 'v');
K_emp = num_emp(2) / den_emp(2);
fc_emp = den_emp(2) / (2*pi);

%% 3. Ideal Mathematical Model
% Define the theoretical design targets
Av_ideal = 82.14;       % Theoretical midband gain
fc_ideal = 20000;       % Assumed theoretical High-Frequency Cutoff (20 kHz)
pole_ideal = 2 * pi * fc_ideal;

% Generate the Ideal Laplace Transfer Function
ideal_tf = tf(Av_ideal * pole_ideal, [1, pole_ideal]);

%% 4. Mathematical Output for Thesis
fprintf('\n--- 2. Mathematical Transfer Functions H(s) ---\n');
disp('Empirical H(s) [From 50Hz Data]:');
disp(empirical_tf);
disp('Ideal Theoretical H(s):');
disp(ideal_tf);

fprintf('\n--- 3. Magnitude & Phase Equations ---\n');
fprintf('Empirical Magnitude |H(jw)|: %.2f / sqrt(1 + (f / %.2f)^2)\n', K_emp, fc_emp);
fprintf('Empirical Phase arg(H(jw)) : -atan(f / %.2f) [radians]\n', fc_emp);
fprintf('\nIdeal Magnitude |H(jw)|    : %.2f / sqrt(1 + (f / %.2f)^2)\n', Av_ideal, fc_ideal);
fprintf('Ideal Phase arg(H(jw))     : -atan(f / %.2f) [radians]\n\n', fc_ideal);

%% 5. Visualization 1: Time & Frequency Domains
figure('Name', 'IC Tester: Time Domain & FFT', 'Position', [100, 100, 900, 600]);

% Subplot 1: Time Domain
subplot(2,1,1);
plot(t * 1e3, v_in, 'b', 'LineWidth', 1.5); hold on;
plot(t * 1e3, v_out, 'r', 'LineWidth', 1.5); 
title('Time Domain: BJT CE Amplifier (50 Hz)');
xlabel('Time (ms)'); ylabel('Voltage (V)');
legend('Input', 'Output', 'Location', 'best');
xlim([0 40]); grid on;

% Subplot 2: FFT (Using AC-Coupled Data to remove the 0Hz DC spike)
L = length(t);     
Y = fft(v_out_ac); 
P2 = abs(Y / L);                  
P1 = P2(1:floor(L/2)+1);          
P1(2:end-1) = 2 * P1(2:end-1);    
f_fft = Fs * (0:(L/2)) / L;           

subplot(2,1,2);
plot(f_fft, P1, 'k', 'LineWidth', 1.2);
title('Frequency Domain: Harmonic Distortion Profile (FFT)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
xlim([0 300]); ylim([0 max(P1)*1.2]); grid on;

%% 6. Visualization 2: Comparative Bode Plot
figure('Name', 'IC Tester: System Identification', 'Position', [150, 150, 900, 600]);

opts = bodeoptions;
opts.FreqUnits = 'Hz';
opts.Grid = 'on';
opts.Title.String = 'Bode Plot: Empirical vs. Ideal Frequency Response';

bodeplot(ideal_tf, 'b', empirical_tf, 'r--', opts);
legend('Ideal Model', 'Empirical Fit (from 50Hz)', 'Location', 'southwest');