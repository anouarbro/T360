<?php

namespace App\Http\Controllers;

use App\Models\B2C;
use Illuminate\Http\Request;

class B2CController extends Controller
{
    /**
     *! Get all B2C records.
     * 
     * This method retrieves all B2C records from the database and returns them as a JSON response.
     */
    public function index()
    {
        // Retrieve all B2C records and return them with a 200 status
        return response()->json(B2C::all(), 200);
    }
}


