<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     * 
     * This method creates the 'personal_access_tokens' table with the specified columns.
     */
    public function up(): void
    {
        // Create the 'personal_access_tokens' table
        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->id();                                   // Auto-incrementing ID column
            $table->morphs('tokenable');                    // Polymorphic relation (used for multiple models)
            $table->string('name');                         // Name of the token (e.g., device or session name)
            $table->string('token', 64)->unique();          // Unique token value with 64 characters
            $table->text('abilities')->nullable();          // Token abilities (e.g., permissions), nullable
            $table->timestamp('last_used_at')->nullable();  // Timestamp for when the token was last used
            $table->timestamp('expires_at')->nullable();    // Optional expiration timestamp for the token
            $table->timestamps();                           // Adds created_at and updated_at timestamps
        });
    }

    /**
     * Reverse the migrations.
     * 
     * This method drops the 'personal_access_tokens' table if it exists.
     */
    public function down(): void
    {
        // Drop the 'personal_access_tokens' table
        Schema::dropIfExists('personal_access_tokens');
    }
};

