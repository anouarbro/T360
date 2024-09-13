<?php

namespace App\Http\Middleware;

use App\Models\ActiveSession;
use Carbon\Carbon;
use Closure;
use Illuminate\Http\Request;

class CheckTokenExpiry
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next)
    {
        $token = $request->user()->currentAccessToken();

        if ($token) {
            // Update the last_used_at timestamp
            $token->forceFill(['last_used_at' => now()])->save();
        }

        // Check if the token has expired (if using expires_at)
        if ($token && $token->created_at->lt(Carbon::now()->subHours(24))) {
            // Revoke the token if it is older than 24 hours
            $token->delete();

            // Remove active session
            ActiveSession::where('user_id', $request->user()->id)->delete();

            return response()->json(['message' => 'Token expired, please log in again.'], 401);
        }

        // Update last activity time in active sessions table
        ActiveSession::where('user_id', $request->user()->id)->update(['last_activity' => now()]);

        return $next($request);
    }
}
