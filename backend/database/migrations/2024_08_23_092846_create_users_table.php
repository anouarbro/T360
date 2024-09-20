<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUsersTable extends Migration
{
    /**
     * Run the migrations.
     * 
     * This method creates the 'users' table with the specified columns.
     */
    public function up()
    {
        // Create the 'users' table
        Schema::create('users', function (Blueprint $table) {
            $table->id();                                     // Auto-incrementing ID column
            $table->string('username')->unique();             // Username field, must be unique
            $table->string('password');                       // Password field
            $table->string('role')->default('visitor');       // Role field with a default value of 'visitor'
            $table->timestamps();                             // Adds created_at and updated_at timestamp columns
        });
    }

    /**
     * Reverse the migrations.
     * 
     * This method drops the 'users' table if it exists.
     */
    public function down()
    {
        // Drop the 'users' table
        Schema::dropIfExists('users');
    }
}


