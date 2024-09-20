<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StudyCase extends Model
{
    //! Define which attributes can be mass-assigned
    protected $fillable = [
        'nom_etude',        // Name of the study case
        'date_debut',       // Start date of the study case
        'date_fin',         // End date of the study case
        'timing_attendu',   // Expected timing for the study
        'timing_reelle',    // Actual timing for the study
        'cadence_attendu',  // Expected cadence (rate or pace) for the study
        'cadence_reelle',   // Actual cadence (rate or pace) for the study
        'zipFile',          // The zip file associated with the study case
    ];

    //! Define a one-to-many relationship: A study case can have many comments

    public function comments()
    {
        return $this->hasMany(Comment::class);
    }
}
