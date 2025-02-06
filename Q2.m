% Truck Parking Problem using Fuzzy Logic

% Define the fuzzy inference system
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
    1 3 1 1 1; % If trailer angle is Sharp Left and distance is Near, then Sharp Left
    2 3 2 1 1; % If trailer angle is Slight Left and distance is Near, then Slight Left
    3 3 3 1 1; % If trailer angle is Centered and distance is Near, then Straight
    4 3 4 1 1; % If trailer angle is Slight Right and distance is Near, then Slight Right
    5 3 5 1 1; % If trailer angle is Sharp Right and distance is Near, then Sharp Right

    1 2 1 1 1; % If trailer angle is Sharp Left and distance is Medium, then Sharp Left
    2 2 2 1 1; % If trailer angle is Slight Left and distance is Medium, then Slight Left
    3 2 3 1 1; % If trailer angle is Centered and distance is Medium, then Straight
    4 2 4 1 1; % If trailer angle is Slight Right and distance is Medium, then Slight Right
    5 2 5 1 1; % If trailer angle is Sharp Right and distance is Medium, then Sharp Right

    1 1 1 1 1; % If trailer angle is Sharp Left and distance is Far, then Sharp Left
    2 1 2 1 1; % If trailer angle is Slight Left and distance is Far, then Slight Left
    3 1 3 1 1; % If trailer angle is Centered and distance is Far, then Straight
    4 1 4 1 1; % If trailer angle is Slight Right and distance is Far, then Slight Right
    5 1 5 1 1; % If trailer angle is Sharp Right and distance is Far, then Sharp Right
];

% Add rules to the FIS
fis = addrule(fis, rules);

% Display FIS structure
showrule(fis);

% Simulate the system
theta_trailer = -45; % Initial trailer angle
distance = 70;       % Initial distance to target
output = evalfis([theta_trailer, distance], fis);

% Display results
disp(['Steering Angle: ', num2str(output), ' degrees']);

% Plot FIS
figure;
plotfis(fis);

% Plot membership functions
figure;
subplot(3, 1, 1);
plotmf(fis, 'input', 1);
title('Trailer Angle Membership Functions');

subplot(3, 1, 2);
plotmf(fis, 'input', 2);
title('Distance to Target Membership Functions');

subplot(3, 1, 3);
plotmf(fis, 'output', 1);
title('Steering Angle Membership Functions');
