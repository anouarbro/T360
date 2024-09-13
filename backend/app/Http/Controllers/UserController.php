<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\ActiveSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Carbon\Carbon;

class UserController extends Controller
{
    /**
     * Get all users.
     */
    public function index()
    {
        return response()->json(User::all(), 200);
    }

    /**
     * Register a new user.
     */
    public function store(Request $request)
    {
        $request->validate([
            'username' => 'required|unique:users',
            'password' => 'required|min:6',
            'role' => 'in:admin,visitor',  // Validation rule for role
        ]);

        // Create a new user with a hashed password and role
        $user = User::create([
            'username' => $request->username,
            'password' => Hash::make($request->password),
            'role' => $request->role ?? 'visitor',  // Default to 'visitor'
        ]);

        return response()->json(['message' => 'User registered successfully', 'user' => $user], 201);
    }


    /**
     * Log in an existing user.
     */

    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        $user = User::where('username', $request->username)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'username' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        $user->tokens()->where('token', hash('sha256', $token))
            ->update(['expires_at' => Carbon::now()->addHours(24)]);

        ActiveSession::create([
            'user_id' => $user->id,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'last_activity' => now(),
        ]);

        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'role' => $user->role,  // Return the role as part of the response
            ]
        ], 200);
    }



    /**
     * Log out the currently authenticated user.
     */
    public function logout(Request $request)
    {
        // Revoke the current token
        $request->user()->currentAccessToken()->delete();

        // Remove active session
        ActiveSession::where('user_id', $request->user()->id)->delete();

        return response()->json(['message' => 'Logged out successfully'], 200);
    }

    /**
     * Update the username or password of an existing user.
     */
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $request->validate([
            'username' => 'sometimes|required|unique:users,username,' . $user->id,
            'password' => 'sometimes|required|min:6',
            'role' => 'in:admin,visitor',  // Validate role during update
        ]);

        if ($request->has('username')) {
            $user->username = $request->username;
        }

        if ($request->has('password')) {
            $user->password = Hash::make($request->password);
        }

        if ($request->has('role')) {
            $user->role = $request->role;  // Update the role if provided
        }

        $user->save();

        return response()->json(['message' => 'User updated successfully', 'user' => $user], 200);
    }


    /**
     * Delete a user.
     */
    public function destroy($id)
    {
        $user = User::findOrFail($id);
        $user->delete();

        return response()->json(null, 204); // 204 No Content
    }

}

