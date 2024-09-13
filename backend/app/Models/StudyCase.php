<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StudyCase extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array<string>
     */
    protected $fillable = [
        'nom_etude',
        'date_debut',
        'date_fin',
        'timing_attendu',
        'timing_reelle',
        'cadence_attendu',
        'cadence_reelle',
        'zipFile',
    ];

    /**
     * Get the comments for the study case.
     */
    public function comments()
    {
        return $this->hasMany(Comment::class);
    }
}

