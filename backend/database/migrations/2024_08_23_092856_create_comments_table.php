<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCommentsTable extends Migration
{
    /**
     * Run the migrations.
     * 
     * This method creates the 'comments' table with the specified columns.
     */
    public function up()
    {
        // Create the 'comments' table
        Schema::create('comments', function (Blueprint $table) {
            $table->id();                                       // Auto-incrementing ID column
            $table->foreignId('user_id')                        // Foreign key linking to 'users' table
                ->constrained()                                 // Automatically links to 'users' table
                ->onDelete('cascade');                          // Delete comments if the associated user is deleted
            $table->foreignId('study_case_id')                  // Foreign key linking to 'study_cases' table
                ->constrained('study_cases')                    // Specifies the 'study_cases' table
                ->onDelete('cascade');                          // Delete comments if the associated study case is deleted
            $table->text('comment');                            // The comment text itself
            $table->timestamps();                               // Adds created_at and updated_at timestamps
        });
    }

    /**
     * Reverse the migrations.
     * 
     * This method drops the foreign key constraints and then the 'comments' table.
     */
    public function down()
    {
        // Drop the foreign key constraints before dropping the table
        Schema::table('comments', function (Blueprint $table) {
            $table->dropForeign(['user_id']);                   // Drop foreign key for 'user_id'
            $table->dropForeign(['study_case_id']);             // Drop foreign key for 'study_case_id'
        });

        // Drop the 'comments' table
        Schema::dropIfExists('comments');
    }
}

