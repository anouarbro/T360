<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    //! Define which attributes can be mass-assigned
    protected $fillable = [
        'user_id',         // ID of the user who made the comment
        'study_case_id',   // ID of the associated study case
        'comment',         // The text content of the comment
    ];

    //! Define an inverse one-to-many relationship: A comment belongs to a user
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    //! Define an inverse one-to-many relationship: A comment belongs to a study case
    public function studyCase()
    {
        return $this->belongsTo(StudyCase::class);
    }
}

