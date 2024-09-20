<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\B2B;
use Faker\Factory as Faker;

class B2BSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * 
     * This method uses Faker to generate and insert 10 random B2B records into the database.
     */
    public function run()
    {
        // Initialize the Faker library to generate fake data
        $faker = Faker::create();

        // Loop to create 10 B2B records
        for ($i = 0; $i < 50; $i++) {
            B2B::create([
                'EntrepriseID' => $faker->uuid,                               // Generate a unique ID for the company
                'Nom_du_champ' => $faker->company,                           // Generate a random company name
                'TEL' => $faker->phoneNumber,                                // Generate a random primary phone number
                'TEL2' => $faker->optional()->phoneNumber,                   // Optionally generate a secondary phone number
                'TEL3' => $faker->optional()->phoneNumber,                   // Optionally generate a tertiary phone number
                'SIRET' => $faker->numerify('##########'),                   // Generate a 10-digit SIRET number
                'dateCreationUniteLegale' => $faker->date,                   // Generate a random creation date for the company
                'trancheEffectifsUniteLegale' => $faker->randomElement(['1-10', '11-50', '51-100']), // Number of employees in the legal entity
                'categorieEntreprise' => $faker->randomElement(['Small', 'Medium', 'Large']), // Category of the company
                'nomUniteLegale_def' => $faker->company,                     // Generate a random official company name
                'categorieJuridiqueUniteLegale' => $faker->randomElement(['SAS', 'SARL']), // Legal category (SAS, SARL)
                'activitePrincipaleUniteLegale_def' => $faker->jobTitle,     // Generate a random job title for main activity
                'trancheEffectifsEtablissement' => $faker->randomElement(['1-10', '11-50']), // Number of employees at the establishment
                'etablissementSiege' => $faker->boolean,                     // Randomly determine if it's the main establishment (HQ)
                'adresse' => $faker->address,                                // Generate a random address
                'codePostalEtablissement' => $faker->postcode,               // Generate a random postal code
                'libelleCommuneEtablissement' => $faker->city,               // Generate a random city name
                'codeCommuneEtablissement' => $faker->randomNumber(5),       // Generate a 5-digit commune code
                'DEPT' => $faker->state,                                     // Generate a random state or department
                'etatAdministratifEtablissement' => $faker->randomElement(['Active', 'Inactive']), // Administrative status
                'NIVI' => $faker->word,                                      // Generate a random word for NIVI
                'TAILLEII' => $faker->randomNumber(2),                       // Generate a random 2-digit number for TAILLEII
                'SECTEUR' => $faker->randomElement(['Public', 'Private']),   // Randomly assign the sector
                'SECTEUR_QUOTA' => $faker->randomElement(['Quota1', 'Quota2']), // Randomly assign a sector quota
                'UDA9_Info_Fichier' => $faker->word,                         // Generate a random word for UDA9_Info_Fichier
                'Region13' => $faker->stateAbbr,                             // Generate a random state abbreviation for Region13
                'Confirmation_du_nom' => $faker->boolean,                    // Randomly confirm the company name (true/false)
                'DATEI' => $faker->date,                                     // Generate a random date for DATEI
                'NBR_APPELI' => $faker->randomNumber(2),                     // Generate a random 2-digit number for NBR_APPELI
                'RESULTI' => $faker->randomElement(['Success', 'Fail']),     // Randomly assign a result ('Success' or 'Fail')
                'SEEDI' => $faker->randomNumber(5),                          // Generate a random 5-digit number for SEEDI
            ]);
        }
    }
}

