clc;
clear all;
close all;

%% Generate a P-N sequence

% Get the number of flip-flops from the user
num_flip_flops = input('Enter the number of flip-flops: ');

% User input for the initial sequence
while true
    initial_sequence = input('Enter the initial sequence [ ]: ');
    [seq_rows, seq_cols] = size(initial_sequence);
    if seq_cols == num_flip_flops
        break;
    end
    fprintf('Wrong sequence length. Please try again!\n');
end

% Create a copy of the initial sequence
copied_sequence = initial_sequence;
copied_sequence(num_flip_flops + 1) = 0;
pseudo_random_sequence = 0;

% User input for the tapping positions
while true
    initial_sequence = copied_sequence;
    tapping_positions = input('Enter tapping positions [ ]: ');
    [tapping_rows, tapping_cols] = size(tapping_positions);
    first_tap = tapping_positions(1);
    
    for i = 1:((2^num_flip_flops) - 1)
        initial_sequence(2:(num_flip_flops + 1)) = initial_sequence(1:num_flip_flops);
        xor_result = initial_sequence(first_tap + 1);
        
        for k = 2:tapping_cols
            xor_result = xor(xor_result, initial_sequence(tapping_positions(k) + 1));
        end
        
        initial_sequence(1) = xor_result;
        pseudo_random_sequence(i) = initial_sequence(num_flip_flops + 1);
    end
    
    if copied_sequence(1:num_flip_flops) == initial_sequence(1:num_flip_flops)
        %fprintf('Tapping positions are correct. Generated sequence is:');
        %disp(pseudo_random_sequence);
        break;
    end
    fprintf('Wrong tapping positions!\n');
end




%% wav to binary

% For further processing we need the x,fs array
filename = 'AudioFileName.wav';
[x,fs] = audioread(filename);

%play audio
sound(x,fs);

% Take the FFT of the audio signal to get fm
X = fft(x);

% Find the absolute values 
mag_X = abs(X);

% Frequnency Axis 
freq_axis = linspace(0, fs, length(mag_X));

% GEtting index of the max number
[~, max_index] = max(mag_X(1:length(mag_X)));

% Map the index on the frequency Axis
max_freq = freq_axis(max_index);
omega = max_freq * 2 * pi;
fm = omega / 2;
%disp( fm);


%defining quantization levels
nQBits = 8;
nLevels = 2^nQBits;

% Compute Quantization step size
maxVal = max(abs(x));
stepSize = maxVal / (nLevels -1);

%Quantize Signals
x_quantized = quantiz(x, linspace(-maxVal, maxVal, nLevels-1));

%converting quantized signal to 8 bit binary stream
nBBits = 8;
x_quantized_norm = (x_quantized - min(x_quantized)) / (max(x_quantized) - min(x_quantized));
x_binary = de2bi(round(x_quantized_norm * (2^nBBits-1)), nBBits, 'left-msb');
x_binary_stream = x_binary(:)';



%% Xor with PN Sequence

[~,pn_length] = size(pseudo_random_sequence);
[x, received_data_length] = size(x_binary_stream);
pseudo_random_sequence = repmat(pseudo_random_sequence, 1, received_data_length);

received_data = repmat(x_binary_stream,pn_length,1);
received_data = received_data(:)';

data_for_transmission = xor(received_data,pseudo_random_sequence);

%% save it to a .txt file

% Define the file name
filename = 'datafortransmission.txt';

% Open the file for writing
fileID = fopen(filename, 'w');

% Check if the file was opened successfully
if fileID == -1
    error('Unable to open the file for writing.');
else
    % Write the data to the file
    fprintf(fileID, '%d ', data_for_transmission);
    
    % Close the file
    fclose(fileID);
end

  
