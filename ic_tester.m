% =========================================================================
% Universal IC Tester
% Device Under Test: BJT CE Amplifier (1 kHz)
% =========================================================================

%% 1. Data Acquisition (DAQ)
% The oscilloscope CSV puts Time in Column 4 and Voltage in Column 5
fprintf('Loading Data...\n');
data_ch1 = readmatrix('16071.CSV');
data_ch2 = readmatrix('16081.CSV');

% Extract Time (t) and Voltage (v) vectors
% We use ~isnan to filter out any empty header rows
valid_idx = ~isnan(data_ch1(:, 4)) & ~isnan(data_ch1(:, 5));
t = data_ch1(valid_idx, 4);      
v_in = data_ch1(valid_idx, 5);   % CH1: Input Signal (Base)
v_out = data_ch2(valid_idx, 5);  % CH2: Output Signal (Collector)

%% 2. Time-Domain Parametric Extraction
% Calculate Peak-to-Peak Voltages
v_in_pp = max(v_in) - min(v_in);
v_out_pp = max(v_out) - min(v_out);

% Calculate Voltage Gain (Av)
Av_linear = v_out_pp / v_in_pp;
Av_dB = 20 * log10(Av_linear);

% Calculate DC Offsets
dc_offset_in = mean(v_in);
dc_offset_out = mean(v_out);

% Print the Extracted Parameters to the Console
fprintf('--- Parametric Extraction Results ---\n');
fprintf('Input Signal (CH1) : %.3f Vpp  | DC Offset: %.3f V\n', v_in_pp, dc_offset_in);
fprintf('Output Signal (CH2): %.3f Vpp  | DC Offset: %.3f V\n', v_out_pp, dc_offset_out);
fprintf('System Voltage Gain: %.2f V/V (%.2f dB)\n\n', Av_linear, Av_dB);

%% 3. Visualization: Time Domain
figure('Name', 'IC Tester: DSP Analysis', 'Position', [100, 100, 900, 600]);

% Subplot 1: Input vs Output Waveforms
subplot(2,1,1);
plot(t * 1e6, v_in, 'b', 'LineWidth', 1.5); hold on;
% Scale the input wave up in the plot so it's visible next to the massive output wave
plot(t * 1e6, v_out, 'r', 'LineWidth', 1.5); 
title('Time Domain: BJT CE Amplifier Input vs Output (1 kHz)');
xlabel('Time (\mus)');
ylabel('Voltage (V)');
legend('CH1 (Input)', 'CH2 (Output)', 'Location', 'best');
grid on;

%% 4. Frequency-Domain Analysis (FFT Spectrum)
% Calculate the Sampling Frequency dynamically from the time vector
Ts = t(2) - t(1);  % Sample Time
Fs = 1 / Ts;       % Sampling Frequency
L = length(t);     % Length of the signal

% Compute the Fast Fourier Transform of the Output Signal
v_out_ac = v_out - dc_offset_out;
Y = fft(v_out_ac);
P2 = abs(Y / L);                  % Two-sided spectrum
P1 = P2(1:floor(L/2)+1);          % Single-sided spectrum
P1(2:end-1) = 2 * P1(2:end-1);    % Double the amplitude for folded frequencies
f = Fs * (0:(L/2)) / L;           % Define the frequency axis

% Subplot 2: FFT Spectrum
subplot(2,1,2);
plot(f / 1000, P1, 'k', 'LineWidth', 1.2);
title('Frequency Domain: Harmonic Distortion Profile (FFT)');
xlabel('Frequency (kHz)');
ylabel('Magnitude (|P1(f)|)');
xlim([0 1000]); % Limit X-axis to 1 MHz to see the fundamental (1kHz) and first few harmonics
grid on;

% Highlight the fundamental 1kHz spike
hold on;
[~, max_idx] = max(P1);
plot(f(max_idx)/1000, P1(max_idx), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(f(max_idx)/1000 + 20, P1(max_idx), 'Fundamental (1kHz)', 'Color', 'r');

%% 5. System Identification (Transfer Function Estimation)
fprintf('--- Transfer Function Estimation (H(s)) ---\n');

% 1. Remove the DC offsets so we only model the AC signal dynamics
v_in_ac = v_in - mean(v_in);
v_out_ac = v_out - mean(v_out);

% 2. Package the data into an 'iddata' object for the System ID Toolbox
% Format: iddata(Output, Input, SampleTime)
sys_data = iddata(v_out_ac, v_in_ac, Ts);

% 3. Estimate a Continuous-Time Transfer Function
% We ask MATLAB to fit a model with 1 Pole and 0 Zeros (standard for a basic CE amp)
estimated_tf = tfest(sys_data, 1, 0);

% 4. Display the mathematical equation in the console
disp('Calculated Transfer Function:');
disp(estimated_tf);

% 5. Generate the Bode Plot from the estimated equation
figure('Name', 'Estimated Bode Plot');
bode(estimated_tf);
grid on;
title('Estimated Frequency Response from 1kHz Data');
