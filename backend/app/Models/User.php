<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    //! Include traits for API tokens and notification functionality
    use HasApiTokens, Notifiable;

    //! Define which attributes can be mass-assigned
    protected $fillable = [
        'username',  // Stores the username of the user
        'password',  // Stores the user's password
        'role',      // Stores the user's role (e.g., admin, visitor, etc.)
    ];

    //! Define which attributes should be hidden in arrays
    protected $hidden = [
        'password',  // The password field is hidden from being exposed in responses
    ];

    //! Define a one-to-many relationship: A user can have many comments
    public function comments()
    {
        return $this->hasMany(Comment::class);
    }
}

