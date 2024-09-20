<?php

namespace App\Http\Controllers;

use App\Models\B2B;
use Illuminate\Http\Request;

class B2BController extends Controller
{
    /**
     *! Get all B2B records.
     * 
     * This method retrieves all B2B records from the database and returns them as a JSON response.
     */
    public function index()
    {
        // Retrieve all B2B records and return them with a 200 status
        return response()->json(B2B::all(), 200);
    }
}

