<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class B2B extends Model
{
    //! Include the factory trait for generating model instances for testing or seeding
    use HasFactory;

    //! Explicitly set the table name for this model
    protected $table = 'b2bs';

    //! Define which attributes can be mass-assigned
    protected $fillable = [
        'EntrepriseID',                        // ID of the company
        'Nom_du_champ',                        // Name of the company field
        'TEL',                                 // Primary phone number
        'TEL2',                                // Secondary phone number
        'TEL3',                                // Tertiary phone number
        'SIRET',                               // SIRET number (French business identification number)
        'dateCreationUniteLegale',             // Date of the legal entity creation
        'trancheEffectifsUniteLegale',         // Number of employees in the legal entity
        'categorieEntreprise',                 // Category of the company (e.g., SME, large enterprise)
        'nomUniteLegale_def',                  // Official name of the legal entity
        'categorieJuridiqueUniteLegale',       // Legal form of the company (e.g., SARL, SA)
        'activitePrincipaleUniteLegale_def',   // Main business activity of the legal entity
        'trancheEffectifsEtablissement',       // Number of employees at the establishment
        'etablissementSiege',                  // Whether the establishment is the headquarters
        'adresse',                             // Address of the establishment
        'codePostalEtablissement',             // Postal code of the establishment
        'libelleCommuneEtablissement',         // Name of the commune where the establishment is located
        'codeCommuneEtablissement',            // Commune code for the establishment
        'DEPT',                                // Department where the establishment is located
        'etatAdministratifEtablissement',      // Administrative status of the establishment (e.g., active, closed)
        'NIVI',                                // Variable related to business categorization
        'TAILLEII',                            // Business size indicator
        'SECTEUR',                             // Sector of business activity
        'SECTEUR_QUOTA',                       // Quota for the business sector
        'UDA9_Info_Fichier',                   // Information related to UDA9 file
        'Region13',                            // Region code of the establishment
        'Confirmation_du_nom',                 // Confirmation of the legal entity's name
        'DATEI',                               // Date of the information file
        'NBR_APPELI',                          // Number of calls made
        'RESULTI',                             // Results of the calls
        'SEEDI'                                // Information related to the SEEDI file
    ];
}

