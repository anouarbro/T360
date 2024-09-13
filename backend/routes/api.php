<?php

use App\Http\Controllers\UserController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\StudyCaseController;

Route::post('/register', [UserController::class, 'store']);
Route::post('/login', [UserController::class, 'login']);
Route::middleware('auth:sanctum')->post('/logout', [UserController::class, 'logout']);

Route::middleware(['auth:sanctum', 'update.last.used', 'check.token.expiry'])->group(function () {
    Route::get('/users', [UserController::class, 'index']); // Get all users

    // Route to update user details (username or password)
    Route::put('/users/{id}', [UserController::class, 'update']);

    // Route to delete a user
    Route::delete('/users/{id}', [UserController::class, 'destroy']);

    Route::apiResource('comments', CommentController::class);
    Route::apiResource('study-cases', StudyCaseController::class);
    // Update study case information only
    Route::put('/study-cases/{studyCase}/info', [StudyCaseController::class, 'updateStudyCaseInfo']);

    // Upload or update the zip file for the study case
    Route::post('/study-cases/{studyCase}/upload-zip', [StudyCaseController::class, 'uploadZipFile']);



    // Additional routes for fetching comments by study_case_id and user_id
    Route::get('/comments/study_case/{study_case_id}', [CommentController::class, 'getByStudyCaseId']);
    Route::get('/comments/study_case/{study_case_id}/user/{user_id}', [CommentController::class, 'getByStudyCaseIdAndUserId']);

    // Route to get all currently connected users
    Route::get('/connected-users', function () {
        $connectedUsers = \App\Models\ActiveSession::with('user')->get();
        return response()->json($connectedUsers, 200);
    });
});
