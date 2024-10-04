 function experimentLauncher()
%function experimentLauncher()
%
% Project: Respiratory Resistance Sensitivity (RRS) Task. 
%       Respiratory interoception task.
%       Staircase adjusts restrictive load on an inhalation tube.
% 
% Calls main.m (the main experiment script, which in turn loads parameters
% from loadParams.m);
% Most variables you might want to change are found in loadParams.m;
% Note however, that text size needs to be set after the OpenWindow call,
% and is therefore set in main.m (~line 78).
%
% Versions:
%      1-2      Task for Visceral Mind Project, Cohort 2, Fall 2020
%      2-1      Version 2. Device update with new driver and screw. Change in motor step (& stim level) values 
%      2-2      Task for Visceral Mind Project 2021, Main task uses Psi single staircase. Includes variation of 2-1, 
%               but using PAL PEST staircase method
%               instead of n-down as an option. Psi single staircase
%      4-0      Update of code by Nicolas Gninenko
%               [nicolas.gninenko@gmail.com]
%               Mainly code optimization and implementation of German and
%               French versions of the task. Adapted also to different
%               RRST devices (ranges adapted in the scale2motorstep.m function)
%
% ======================================================   
%
% Run from 'RRS_4-0' directory
%
% -------------- PRESS ESC TO EXIT ---------------------
%
% ======================================================
%
% Niia Nikolova
% Nicolas Gninenko - nicolas.gninenko@gmail.com - FND Research Group
% Last edit: 22 Sept 2023

cd("D:\Experimental_scripts\projet_interoception_2023\task1_RRST\task\RRS_3-0");

%% Initial settings
% Clear existing workspace
close all; clc; clear all;


devFlag = 0;                % optional flag. Set to 1 when developing the task
      
vars.exptName = 'RRS';
vars.exptVers = '_3-0';

addpath('C:\software\Palamedes\Palamedes\'); %path specific to this computer !!!

% if strcmp(getenv('USER'),'nicogn')
%     addpath('/Users/nicogn/Documents/MATLAB/Palamedes/');
% elseif strcmp(getenv('USERNAME'),'lcns') % Account on EEG laptop currently used for the RRST task at HFR
%     addpath('C:\software\Palamedes\Palamedes\');    
% end

%% Set-up
% Check that PTB is installed
PTBv = PsychtoolboxVersion;
if isempty(PTBv)
    disp('Please install Psychtoolbox 3. Download and installation can be found here: http://psychtoolbox.org/download');
    return
end

% Skip internal synch checks, suppress warnings
oldLevel = Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);

% Check working directory & change if necessary
vars.workingDir = fullfile(vars.exptName); % make sure we're inside the RRS folder
currentFolder = pwd;
correctFolder = contains(currentFolder, vars.workingDir);
if ~correctFolder                   % if we're not in the correct working directory, prompt to change
    disp(['Incorrect working directory. Please start from ', vars.workingDir, vars.exptVers]);
    return;
end

% Data will be stored in the dataFolder variable defined below
dataFolder = 'data';
if ~exist([pwd filesep dataFolder], 'dir')
    mkdir([pwd filesep dataFolder]);
end

% Set up path
addpath(genpath('code'));
addpath(genpath(dataFolder));
addpath(genpath(fullfile('..', filesep, 'respDeviceHelpers_3-0')));
addpath(genpath(fullfile('..', filesep, 'helpers')));
sPath = what((fullfile('..', filesep, 'helpers')));
vars.helpersPath  = sPath.path;


%% Ask for subID & language
if ~devFlag % if we're testing
    vars.subNo          = input('What is the subject ID (e.g. 001)?   ');   
    vars.languageIn     = input('Language?: (e for english, f for french, g for german, or d for danish)   ', 's');       % 'E', or 'D'
    scr.ViewDist        = 70;
    HideCursor;
else 
    scr.ViewDist = 40;
end

if ~isfield(vars,'subNo') || isempty(vars.subNo)
    vars.subNo = 9999; % test
end

%% Output
vars.OutputFolder   = fullfile('.', dataFolder, filesep);
subIDstring         = sprintf('P%03d', vars.subNo);
vars.DataFileName   = strcat(vars.exptName, '_',subIDstring, '_P');    % name of data file to write to

if isfile(strcat(vars.OutputFolder, vars.DataFileName, '.mat'))
    % File already exists in Outputdir
    if vars.subNo ~= 9999
        disp('A datafile already exists for this subject ID. Please enter a different ID.')
        return
    end
end

 %% Start experiment
main(vars, scr);

if ~devFlag % if we're testing
    % Things to do to clean up if we're testing go here (e.g. copy data to network drive for backup)
end

% Clean up, reset paths
Screen('Preference', 'Verbosity', oldLevel);
rmpath(genpath('code'));
rmpath(genpath(dataFolder));
rmpath(genpath(fullfile('..', filesep, 'helpers')));