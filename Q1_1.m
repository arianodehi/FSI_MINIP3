clc;clear;close all;
% Create a Mamdani fuzzy inference system
fis = mamfis('Name', 'FuzzyController');

% Define input 1: Error
fis = addInput(fis, [-1 1], 'Name', 'Error');
fis = addMF(fis, 'Error', 'trapmf', [-1 -1 -0.5 0], 'Name', 'Negative');
fis = addMF(fis, 'Error', 'trimf', [-0.5 0 0.5], 'Name', 'Zero');
fis = addMF(fis, 'Error', 'trapmf', [0 0.5 1 1], 'Name', 'Positive');

% Define input 2: Change in Error
fis = addInput(fis, [-1 1], 'Name', 'ChangeInError');
fis = addMF(fis, 'ChangeInError', 'trapmf', [-1 -1 -0.5 0], 'Name', 'Negative');
fis = addMF(fis, 'ChangeInError', 'trimf', [-0.5 0 0.5], 'Name', 'Zero');
fis = addMF(fis, 'ChangeInError', 'trapmf', [0 0.5 1 1], 'Name', 'Positive');

% Define output: Control Action
fis = addOutput(fis, [-1 1], 'Name', 'ControlAction');
fis = addMF(fis, 'ControlAction', 'trapmf', [-1 -1 -0.5 0], 'Name', 'Negative');
fis = addMF(fis, 'ControlAction', 'trimf', [-0.5 0 0.5], 'Name', 'Zero');
fis = addMF(fis, 'ControlAction', 'trapmf', [0 0.5 1 1], 'Name', 'Positive');

% Define fuzzy rules
rules = [...
    "If Error is Negative and ChangeInError is Negative then ControlAction is Negative"; 
    "If Error is Negative and ChangeInError is Zero then ControlAction is Negative"; 
    "If Error is Negative and ChangeInError is Positive then ControlAction is Zero";
    "If Error is Zero and ChangeInError is Negative then ControlAction is Negative";
    "If Error is Zero and ChangeInError is Zero then ControlAction is Zero";
    "If Error is Zero and ChangeInError is Positive then ControlAction is Positive";
    "If Error is Positive and ChangeInError is Negative then ControlAction is Zero";
    "If Error is Positive and ChangeInError is Zero then ControlAction is Positive";
    "If Error is Positive and ChangeInError is Positive then ControlAction is Positive"];
fis = addRule(fis, rules);

% Display the FIS
disp(fis);

% Save the FIS to a file for importing in Simulink
writeFIS(fis, 'FuzzyController.fis');
disp('FuzzyController.fis has been saved.');
