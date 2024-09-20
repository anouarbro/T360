<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\B2C;
use Faker\Factory as Faker;

class B2CSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * 
     * This method uses Faker to generate and insert 10 random B2C records into the database.
     */
    public function run()
    {
        // Initialize the Faker library to generate fake data
        $faker = Faker::create();

        // Loop to create 10 B2C records
        for ($i = 0; $i < 50; $i++) {
            B2C::create([
                'Nom' => $faker->name,                              // Generate a random name
                'TEL' => $faker->phoneNumber,                       // Generate a random phone number
                'Age' => $faker->numberBetween(18, 90),             // Generate a random age between 18 and 90
                'Sexe' => $faker->randomElement(['M', 'F']),        // Randomly select gender ('M' or 'F')
                'DEP' => $faker->stateAbbr,                         // Generate a random state abbreviation
                'UDA9' => $faker->word,                             // Generate a random word for UDA9
                'Region13' => $faker->state,                        // Generate a random state for Region13
                'Type_TEL' => $faker->randomElement(['Mobile', 'Landline']), // Randomly select phone type
                'Habitat' => $faker->randomElement(['Urban', 'Rural']), // Randomly select habitat type
                'CSP_Interviewe' => $faker->word,                   // Generate a random word for CSP_Interviewe
                'SEEDI' => $faker->randomNumber(5),                 // Generate a random 5-digit number for SEEDI
                'Heure_FIN' => $faker->time,                        // Generate a random time for Heure_FIN
            ]);
        }
    }
}

