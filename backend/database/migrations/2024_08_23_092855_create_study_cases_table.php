<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateStudyCasesTable extends Migration
{
    /**
     * Run the migrations.
     * 
     * This method creates the 'study_cases' table with the specified columns.
     */
    public function up()
    {
        // Create the 'study_cases' table
        Schema::create('study_cases', function (Blueprint $table) {
            $table->id();                                      // Auto-incrementing ID column
            $table->string('nom_etude');                       // Name of the study case
            $table->date('date_debut');                        // Start date of the study case
            $table->date('date_fin');                          // End date of the study case
            $table->time('timing_attendu');                    // Expected timing for the study
            $table->time('timing_reelle');                     // Actual timing for the study
            $table->decimal('cadence_attendu', 8, 2);          // Expected cadence (up to 8 digits, 2 decimal places)
            $table->decimal('cadence_reelle', 8, 2);           // Actual cadence (up to 8 digits, 2 decimal places)
            $table->string('zipFile');                         // Path to the compressed file associated with the study case
            $table->timestamps();                              // Adds created_at and updated_at timestamp columns
        });
    }

    /**
     * Reverse the migrations.
     * 
     * This method drops the 'study_cases' table if it exists.
     */
    public function down()
    {
        // Drop the 'study_cases' table
        Schema::dropIfExists('study_cases');
    }
}

