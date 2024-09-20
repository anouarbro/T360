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
     *! Get all users.
     * 
     * This method retrieves all users from the database
     * and returns them as a JSON response with a 200 status.
     */
    public function index()
    {
        return response()->json(User::all(), 200);
    }

    /**
     *! Register a new user.
     * 
     * This method validates the input, creates a new user with a hashed password,
     * and returns a JSON response with the created user and a success message.
     */
    public function store(Request $request)
    {
        // Validate the incoming request
        $request->validate([
            'username' => 'required|unique:users',   // Username must be unique
            'password' => 'required|min:6',         // Password must be at least 6 characters
            'role' => 'in:admin,visitor',           // Role can be either 'admin' or 'visitor'
        ]);

        // Create a new user with hashed password and assign the role
        $user = User::create([
            'username' => $request->username,
            'password' => Hash::make($request->password),  // Hash the password for security
            'role' => $request->role ?? 'visitor',         // Default role is 'visitor'
        ]);

        // Return success response with the created user
        return response()->json(['message' => 'User registered successfully', 'user' => $user], 201);
    }

    /**
     *! Log in an existing user.
     * 
     * This method checks the provided username and password, generates an auth token,
     * and returns the token with the user information.
     */
    public function login(Request $request)
    {
        // Validate the login request
        $request->validate([
            'username' => 'required',  // Username is required
            'password' => 'required',  // Password is required
        ]);

        // Find the user by username
        $user = User::where('username', $request->username)->first();

        // Check if the user exists and the password is correct
        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'username' => ['The provided credentials are incorrect.'],
            ]);
        }

        // Create a new token for the user
        $token = $user->createToken('auth-token')->plainTextToken;

        // Update the token expiration to 24 hours
        $user->tokens()->where('token', hash('sha256', $token))
            ->update(['expires_at' => Carbon::now()->addHours(24)]);

        // Create a new active session record for the user
        ActiveSession::create([
            'user_id' => $user->id,
            'ip_address' => $request->ip(),           // Store the IP address of the user
            'user_agent' => $request->userAgent(),    // Store the browser or client information
            'last_activity' => now(),                 // Log the last activity time
        ]);

        // Return success response with the user info and token
        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'role' => $user->role,  // Include the user's role in the response
            ]
        ], 200);
    }

    /**
     *! Log out the currently authenticated user.
     * 
     * This method revokes the current user's token and removes their active session.
     */
    public function logout(Request $request)
    {
        // Revoke the current token of the authenticated user
        $request->user()->currentAccessToken()->delete();

        // Remove the user's active session record
        ActiveSession::where('user_id', $request->user()->id)->delete();

        // Return success message
        return response()->json(['message' => 'Logged out successfully'], 200);
    }

    /**
     *! Update the username or password of an existing user.
     * 
     * This method allows updating the user's username, password, or role,
     * with validation to ensure unique usernames and a minimum password length.
     */
    public function update(Request $request, $id)
    {
        // Find the user by ID or throw an error if not found
        $user = User::findOrFail($id);

        // Validate the input for updating the user
        $request->validate([
            'username' => 'sometimes|required|unique:users,username,' . $user->id,  // Ensure the username is unique, except for the current user
            'password' => 'sometimes|required|min:6',  // Validate password if provided
            'role' => 'in:admin,visitor',              // Role can be 'admin' or 'visitor'
        ]);

        // Update username if provided
        if ($request->has('username')) {
            $user->username = $request->username;
        }

        // Update password if provided
        if ($request->has('password')) {
            $user->password = Hash::make($request->password);
        }

        // Update role if provided
        if ($request->has('role')) {
            $user->role = $request->role;
        }

        // Save the updated user information
        $user->save();

        // Return success message with the updated user
        return response()->json(['message' => 'User updated successfully', 'user' => $user], 200);
    }

    /**
     *! Delete a user.
     * 
     * This method deletes the specified user by their ID.
     */
    public function destroy($id)
    {
        // Find the user by ID or throw an error if not found
        $user = User::findOrFail($id);

        // Delete the user
        $user->delete();

        // Return a 204 No Content response (successful deletion with no response body)
        return response()->json(null, 204);
    }
}
