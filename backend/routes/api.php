<?php

use App\Http\Controllers\UserController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\StudyCaseController;
use App\Http\Controllers\B2BController;
use App\Http\Controllers\B2CController;

// Route to register a new user
Route::post('/register', [UserController::class, 'store']);

// Route to log in a user
Route::post('/login', [UserController::class, 'login']);

// Route to log out a user (requires authentication)
Route::middleware('auth:sanctum')->post('/logout', [UserController::class, 'logout']);

// Group routes that require authentication, last activity update, and token expiry check
Route::middleware(['auth:sanctum', 'update.last.used', 'check.token.expiry'])->group(function () {

    // Route to get all users
    Route::get('/users', [UserController::class, 'index']);

    // Route to update user details (username or password)
    Route::put('/users/{id}', [UserController::class, 'update']);

    // Route to delete a user
    Route::delete('/users/{id}', [UserController::class, 'destroy']);

    // Resourceful routes for CommentController (CRUD)
    Route::apiResource('comments', CommentController::class);

    // Resourceful routes for StudyCaseController (CRUD)
    Route::apiResource('study-cases', StudyCaseController::class);

    // Route to update study case information only (without uploading a new file)
    Route::put('/study-cases/{studyCase}/info', [StudyCaseController::class, 'updateStudyCaseInfo']);

    // Route to upload or update the zip file for the study case
    Route::post('/study-cases/{studyCase}/upload-zip', [StudyCaseController::class, 'uploadZipFile']);

    // Additional routes for fetching comments by study_case_id and user_id
    Route::get('/comments/study_case/{study_case_id}', [CommentController::class, 'getByStudyCaseId']);
    Route::get('/comments/study_case/{study_case_id}/user/{user_id}', [CommentController::class, 'getByStudyCaseIdAndUserId']);

    // Route to get all currently connected users and their session information
    Route::get('/connected-users', function () {
        $connectedUsers = \App\Models\ActiveSession::with('user')->get();
        return response()->json($connectedUsers, 200);
    });

    // Route to get all B2B records
    Route::get('/b2b', [B2BController::class, 'index']);

    // Route to get all B2C records
    Route::get('/b2c', [B2CController::class, 'index']);
});
