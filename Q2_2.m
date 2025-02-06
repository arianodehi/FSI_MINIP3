clc; clear; close all;

% Create the Fuzzy Inference System (FIS) for truck parking
fis = newfis('Truck Parking', 'mamdani');

% Input 1: Trailer Angle (theta_trailer)
fis = addvar(fis, 'input', 'Trailer Angle', [-90, 90]); % Degrees
fis = addmf(fis, 'input', 1, 'Sharp Left', 'trapmf', [-90, -90, -60, -30]);
fis = addmf(fis, 'input', 1, 'Slight Left', 'trimf', [-60, -30, 0]);
fis = addmf(fis, 'input', 1, 'Centered', 'trimf', [-30, 0, 30]);
fis = addmf(fis, 'input', 1, 'Slight Right', 'trimf', [0, 30, 60]);
fis = addmf(fis, 'input', 1, 'Sharp Right', 'trapmf', [30, 60, 90, 90]);

% Input 2: Distance to Target (distance)
fis = addvar(fis, 'input', 'Distance to Target', [0, 100]); % Distance in meters
fis = addmf(fis, 'input', 2, 'Near', 'trapmf', [0, 0, 10, 30]);
fis = addmf(fis, 'input', 2, 'Medium', 'trimf', [10, 50, 90]);
fis = addmf(fis, 'input', 2, 'Far', 'trapmf', [50, 90, 100, 100]);

% Output: Steering Angle (steering_angle)
fis = addvar(fis, 'output', 'Steering Angle', [-30, 30]); % Degrees
fis = addmf(fis, 'output', 1, 'Sharp Left', 'trapmf', [-30, -30, -20, -10]);
fis = addmf(fis, 'output', 1, 'Slight Left', 'trimf', [-20, -10, 0]);
fis = addmf(fis, 'output', 1, 'Straight', 'trimf', [-5, 0, 5]);
fis = addmf(fis, 'output', 1, 'Slight Right', 'trimf', [0, 10, 20]);
fis = addmf(fis, 'output', 1, 'Sharp Right', 'trapmf', [10, 20, 30, 30]);

% Define the rule base
rules = [
    1 3 1 1 1; 
    2 3 2 1 1;
    3 3 3 1 1; 
    4 3 4 1 1; 
    5 3 5 1 1;
    1 2 1 1 1; 
    2 2 2 1 1; 
    3 2 3 1 1; 
    4 2 4 1 1; 
    5 2 5 1 1;
    1 1 1 1 1; 
    2 1 2 1 1; 
    3 1 3 1 1; 
    4 1 4 1 1; 
    5 1 5 1 1;
];

% Add rules to the FIS
fis = addrule(fis, rules);

% Simulation parameters
dt = 0.1; % Time step
num_steps = 200; % Number of simulation steps

% Initial conditions
theta_trailer = -45; % Initial trailer angle (degrees)
distance = 70;       % Initial distance to target (meters)
x = 0;               % Initial x position
y = distance;        % Initial y position
theta_truck = 0;     % Initial truck heading angle

% Store trajectory
trajectory_x = zeros(1, num_steps);
trajectory_y = zeros(1, num_steps);

% Simulation loop
for i = 1:num_steps
    % Evaluate fuzzy controller
    steering_angle = evalfis([theta_trailer, distance], fis);
    
    % Update truck dynamics
    theta_trailer = theta_trailer + steering_angle * dt; % Update trailer angle
    distance = max(0, distance - 0.5); % Reduce distance (truck moving backward)
    
    % Update truck position
    x = x + cosd(theta_truck) * dt * 5; % Move forward
    y = y - sind(theta_truck) * dt * 5;
    
    % Update truck heading
    theta_truck = theta_truck + steering_angle * dt;
    
    % Store trajectory
    trajectory_x(i) = x;
    trajectory_y(i) = y;
    
    % Stop if distance is close to zero
    if distance <= 0.5
        break;
    end
end

% Plot the truck's trajectory
figure;
plot(trajectory_x, trajectory_y, 'b-', 'LineWidth', 2);
hold on;
plot(trajectory_x(end), trajectory_y(end), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % Final position
xlabel('X Position (m)');
ylabel('Y Position (m)');
title('Truck Parking Path');
grid on;
legend('Truck Path', 'Final Position');
axis equal;
