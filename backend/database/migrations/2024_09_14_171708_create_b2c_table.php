<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     * 
     * This method creates the 'b2cs' table with the specified columns and their data types.
     */
    public function up()
    {
        // Create the 'b2cs' table
        Schema::create('b2cs', function (Blueprint $table) {
            $table->id();                        // Auto-incrementing ID column
            $table->string('Nom');               // Name field for the B2C entity
            $table->string('TEL');               // Telephone number field
            $table->integer('Age');              // Age field as an integer
            $table->string('Sexe');              // Gender field
            $table->string('DEP');               // Department code
            $table->string('UDA9');              // UDA9 classification field
            $table->string('Region13');          // Region code
            $table->string('Type_TEL');          // Type of telephone (e.g., mobile, landline)
            $table->string('Habitat');           // Housing or living situation
            $table->string('CSP_Interviewe');    // Socio-professional category of the interviewee
            $table->string('SEEDI');             // SEEDI-related information
            $table->time('Heure_FIN');           // Time when the session/interview finished
            $table->timestamps();                // Adds created_at and updated_at timestamp columns
        });
    }

    /**
     * Reverse the migrations.
     * 
     * This method drops the 'b2cs' table if it exists.
     */
    public function down(): void
    {
        // Drop the 'b2cs' table
        Schema::dropIfExists('b2cs');
    }
};

