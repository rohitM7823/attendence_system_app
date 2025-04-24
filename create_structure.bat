@echo off
REM Root directory
set ROOT=lib

REM Create directories
mkdir %ROOT%\core\constants
mkdir %ROOT%\core\utils

mkdir %ROOT%\features\attendance\presentation\pages
mkdir %ROOT%\features\attendance\presentation\widgets
mkdir %ROOT%\features\attendance\domain\models
mkdir %ROOT%\features\attendance\application

mkdir %ROOT%\data

mkdir %ROOT%\routes

REM Create placeholder Dart files
type nul > %ROOT%\main.dart
type nul > %ROOT%\core\constants\time_constants.dart
type nul > %ROOT%\core\utils\time_utils.dart

type nul > %ROOT%\features\attendance\presentation\pages\login_page.dart
type nul > %ROOT%\features\attendance\presentation\pages\face_verification_page.dart
type nul > %ROOT%\features\attendance\presentation\pages\clock_page.dart
type nul > %ROOT%\features\attendance\presentation\widgets\clock_button.dart

type nul > %ROOT%\features\attendance\domain\models\employee_model.dart
type nul > %ROOT%\features\attendance\application\attendance_service.dart

type nul > %ROOT%\data\mock_face_verifier.dart
type nul > %ROOT%\routes\app_router.dart

echo Folder structure created successfully!
pause
