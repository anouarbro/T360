<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     * 
     * This method creates the 'active_sessions' table with the specified columns.
     */
    public function up()
    {
        // Create the 'active_sessions' table
        Schema::create('active_sessions', function (Blueprint $table) {
            $table->id();                                   // Auto-incrementing ID column
            $table->foreignId('user_id')                    // Foreign key to the users table
                ->constrained()                             // Automatically links to 'users' table
                ->onDelete('cascade');                      // Delete the session if the user is deleted
            $table->string('ip_address')->nullable();       // IP address from where the session was initiated (nullable)
            $table->string('user_agent')->nullable();       // User agent (browser or client info) for the session (nullable)
            $table->timestamp('last_activity');             // Timestamp of the last activity in the session
            $table->timestamps();                           // Adds created_at and updated_at timestamps
        });
    }

    /**
     * Reverse the migrations.
     * 
     * This method drops the 'active_sessions' table if it exists.
     */
    public function down(): void
    {
        // Drop the 'active_sessions' table
        Schema::dropIfExists('active_sessions');
    }
};

