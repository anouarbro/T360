<?php

namespace App\Http\Middleware;

use Closure;
use Carbon\Carbon;

class UpdateLastUsedAt
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        if ($request->user()) {
            $token = $request->user()->currentAccessToken();
            $token->forceFill(['last_used_at' => Carbon::now()])->save();
        }

        return $next($request);
    }
}
