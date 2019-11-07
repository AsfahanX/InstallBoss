@echo off
REM https://github.com/AsfahanX/InstallBoss/releases/latest
REM https://github.com/AsfahanX/InstallBoss/releases/latest/download/InstallBoss.cmd

REM.-- Prepare the Command Processor
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
CD /D "%~dp0"

REM.-- Version History --
REM         X.X               YYYY-MM-DD  Author    Description
SET version=0.1-beta    & rem 2019-10-03  Asfahan   initial version, providing the framework
SET version=0.2         & rem 2019-10-06  Asfahan   Added feature to create folder structure example
SET version=0.3         & rem 2019-10-14  Asfahan   Added improved UI on Installation progress
SET version=1.0.0       & rem 2019-11-07  AsfahanX  Build system for development
REM !! For a new version entry, copy the last entry down and modify Date, Author and Description
SET version=%version: =%

REM.-- Set the window title 
SET title=%~n0 v%version%
TITLE %title%
