<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ActiveSession extends Model
{
    //! Include the factory trait for generating model instances for testing or seeding
    use HasFactory;

    //! Define which attributes can be mass-assigned
    protected $fillable = [
        'user_id',        // ID of the user associated with this session
        'ip_address',     // IP address from where the session was created
        'user_agent',     // Information about the browser or client making the request
        'last_activity',  // Timestamp of the last activity during the session
    ];


    //! Define an inverse one-to-many relationship: An active session belongs to a user
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

