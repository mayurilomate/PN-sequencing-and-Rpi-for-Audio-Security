clc;
close all;
clear all;

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
        break;
    end
    fprintf('Wrong tapping positions!\n');
end

disp(pseudo_random_sequence);



%% Extract array

% Define the file name (should match the name you used to save the data)
filename = 'datafortransmission.txt';

% Open the file for reading
fileID = fopen(filename, 'r');

% Check if the file was successfully opened
if fileID == -1
    error('Error opening the file for reading.');
end

% Read the data from the file
received_data = fscanf(fileID, '%d');

% Close the file
fclose(fileID);
received_data = received_data.';

%% Extracting original bit stream

[~,pn_length] = size(pseudo_random_sequence);
[~, received_data_length] = size(received_data);
x = received_data_length/pn_length;
pseudo_random_sequence = repmat(pseudo_random_sequence, 1, x);

big_binary_data = and(pseudo_random_sequence,received_data);

% Reshape the sequence into groups of 4 using the reshape function
binary_data = reshape(big_binary_data, pn_length, []);

% Take the first element of each group
binary_data = binary_data(1, :);

% if all(binary_data==x_binary_stream)
%     disp("correct")
% else
%     disp("wrong")
% end

% Reshape the binary data to the original shape
binary_streamz = reshape(binary_data, [], 8); 

% Convert the binary data back to decimal
y_integer = bi2de(binary_streamz, 'left-msb');

% Rescale the integer data back to the appropriate range
y_scaled = double(y_integer) / (2^8 - 1);

% Write the audio data to a WAV file
fs = 48000; % Set your desired sample rate
audiowrite('reconstructed_audio.wav', y_scaled, fs);


