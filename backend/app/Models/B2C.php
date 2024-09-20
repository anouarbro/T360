<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class B2C extends Model
{
    //! Include the factory trait for generating model instances for testing or seeding
    use HasFactory;

    //! Explicitly set the table name for this model
    protected $table = 'b2cs';

    //! Define which attributes can be mass-assigned
    protected $fillable = [
        'Nom',              // Name of the individual
        'TEL',              // Phone number
        'Age',              // Age of the individual
        'Sexe',             // Gender of the individual (e.g., male, female)
        'DEP',              // Department code or location of the individual
        'UDA9',             // UDA9 code for classification or segmentation
        'Region13',         // Region code where the individual resides
        'Type_TEL',         // Type of phone (e.g., mobile, landline)
        'Habitat',          // Type of housing or living situation
        'CSP_Interviewe',   // Socio-professional category of the interviewee
        'SEEDI',            // Information related to the SEEDI file
        'Heure_FIN'         // Time the interview or session finished
    ];
}

