<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     * 
     * This method creates the 'b2bs' table with the specified columns and their data types.
     */
    public function up()
    {
        // Create the 'b2bs' table
        Schema::create('b2bs', function (Blueprint $table) {
            $table->id();                                     // Auto-incrementing ID column
            $table->string('EntrepriseID');                   // Company ID
            $table->string('Nom_du_champ');                   // Name of the company field
            $table->string('TEL');                            // Primary phone number
            $table->string('TEL2')->nullable();               // Secondary phone number (nullable)
            $table->string('TEL3')->nullable();               // Tertiary phone number (nullable)
            $table->string('SIRET');                          // SIRET number (French business identification number)
            $table->date('dateCreationUniteLegale');          // Date of legal entity creation
            $table->string('trancheEffectifsUniteLegale');    // Number of employees in the legal entity
            $table->string('categorieEntreprise');            // Company category (e.g., SME, large enterprise)
            $table->string('nomUniteLegale_def');             // Official name of the legal entity
            $table->string('categorieJuridiqueUniteLegale');  // Legal category of the company (e.g., SARL, SA)
            $table->string('activitePrincipaleUniteLegale_def'); // Main activity of the company
            $table->string('trancheEffectifsEtablissement');  // Number of employees at the establishment
            $table->string('etablissementSiege');             // Indicates if it's the main establishment (headquarters)
            $table->string('adresse');                        // Address of the establishment
            $table->string('codePostalEtablissement');        // Postal code of the establishment
            $table->string('libelleCommuneEtablissement');    // Commune (city) name of the establishment
            $table->string('codeCommuneEtablissement');       // Commune code for the establishment
            $table->string('DEPT');                           // Department (region) of the establishment
            $table->string('etatAdministratifEtablissement'); // Administrative status of the establishment (e.g., active, closed)
            $table->string('NIVI');                           // Indicator for business categorization
            $table->string('TAILLEII');                       // Size indicator for the business
            $table->string('SECTEUR');                        // Sector of business activity
            $table->string('SECTEUR_QUOTA');                  // Quota for the business sector
            $table->string('UDA9_Info_Fichier');              // UDA9-related information
            $table->string('Region13');                       // Region code (Region 13)
            $table->string('Confirmation_du_nom');            // Name confirmation of the legal entity
            $table->date('DATEI');                            // Date of the information file
            $table->integer('NBR_APPELI');                    // Number of calls made
            $table->string('RESULTI');                        // Results of the calls
            $table->string('SEEDI');                          // SEEDI-related information
            $table->timestamps();                             // Adds created_at and updated_at timestamp columns
        });
    }

    /**
     * Reverse the migrations.
     * 
     * This method drops the 'b2bs' table if it exists.
     */
    public function down(): void
    {
        // Drop the 'b2bs' table
        Schema::dropIfExists('b2bs');
    }
};

