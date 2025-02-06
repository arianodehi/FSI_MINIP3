clc;
clear;
close all;

% Load dataset and preprocess
raw_data = readtable('AirQualityUCI.xlsx');
data_matrix = table2array(raw_data(:, 3:end));

% Remove invalid data (-200 values)
data_matrix(any(data_matrix == -200, 2), :) = [];

% Normalize dataset using z-score normalization
normalized_data = (data_matrix - mean(data_matrix, 1)) ./ std(data_matrix, 0, 1);

% Split dataset into training, testing, and validation sets
num_samples = size(normalized_data, 1);
train_size = round(0.6 * num_samples);
test_size = round(0.2 * num_samples);
val_size = num_samples - train_size - test_size;

rng(100); % Set random seed for reproducibility
indices = randperm(num_samples);
train_indices = indices(1:train_size);
test_indices = indices(train_size+1:train_size+test_size);
val_indices = indices(train_size+test_size+1:end);

train_set = normalized_data(train_indices, :);
test_set = normalized_data(test_indices, :);
val_set = normalized_data(val_indices, :);

% Extract input and output variables for training
train_output = train_set(:,8);
train_input = train_set;
train_input(:,8) = [];

% Generate initial fuzzy model using Subtractive Clustering
sc_options = genfisOptions('SubtractiveClustering');
fis_model = genfis(train_input, train_output, sc_options);

% Prepare training and testing datasets
training_data = [train_input train_output];
test_input = test_set;
test_output = test_set(:,8);
test_input(:,8) = [];
testing_data = [test_input test_output];

% Configure ANFIS training options
anfis_options = anfisOptions('InitialFIS', fis_model);
anfis_options.EpochNumber = 1000;
anfis_options.InitialStepSize = 0.015;
anfis_options.StepSizeDecreaseRate = anfis_options.StepSizeDecreaseRate / 2;
anfis_options.ValidationData = testing_data;

% Train ANFIS model
[fis_trained, train_error, step_size, val_fis, val_error] = anfis(training_data, anfis_options);

% Plot training and validation errors
figure;
subplot(3, 1, 1);
plot(train_error);
title('Training Error');
subplot(3, 1, 2);
plot(val_error);
title('Validation Error');
subplot(3, 1, 3);
plot(step_size);
title('Step Size');

% Evaluate trained FIS model
train_predicted = evalfis(val_fis, training_data(:,1:end-1));
test_predicted = evalfis(val_fis, testing_data(:,1:end-1));

% Compute Mean Squared Error (MSE)
mse_train = mean((train_predicted - training_data(:,end)).^2);
mse_test = mean((test_predicted - testing_data(:,end)).^2);

% Implement Radial Basis Function Network (RBF)
mse_train_arr = [];
mse_test_arr = [];
lowest_test_error = inf;
best_rbf_model = [];

for spread = 0.01:0.01:1
    X_train = training_data(:,1:end-1)';
    Y_train = training_data(:,end)';
    
    rbf_net = newrbe(X_train, Y_train, spread);
    
    train_output_rbf = sim(rbf_net, X_train);
    mse_train_rbf = mean((train_output_rbf - Y_train).^2);
    
    test_output_rbf = sim(rbf_net, test_input');
    mse_test_rbf = mean((test_output_rbf - test_output').^2);
    
    mse_train_arr = [mse_train_arr mse_train_rbf];
    mse_test_arr = [mse_test_arr mse_test_rbf];
    
    if mse_test_rbf < lowest_test_error
        best_rbf_model = rbf_net;
        lowest_test_error = mse_test_rbf;
    end
end

% Plot MSE variations
figure;
subplot(2, 1, 1);
plot(mse_test_arr);
title('MSE for Test Data');
subplot(2, 1, 2);
plot(mse_train_arr);
title('MSE for Training Data');

disp(['Lowest Train MSE: ', num2str(min(mse_train_arr))]);
disp(['Lowest Test MSE: ', num2str(lowest_test_error)]);
disp(['Number of centers in best RBF model: ', num2str(size(best_rbf_model.IW{1}, 1))]);
