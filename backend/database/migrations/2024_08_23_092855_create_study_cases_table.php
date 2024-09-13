<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateStudyCasesTable extends Migration
{
    public function up()
    {
        Schema::create('study_cases', function (Blueprint $table) {
            $table->id();
            $table->string('nom_etude');
            $table->date('date_debut');
            $table->date('date_fin');
            $table->time('timing_attendu');
            $table->time('timing_reelle');
            $table->decimal('cadence_attendu', 8, 2);
            $table->decimal('cadence_reelle', 8, 2);
            $table->string('zipFile');  // Single column for all compressed file formats
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('study_cases');
    }
}
