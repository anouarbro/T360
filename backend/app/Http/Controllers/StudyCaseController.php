<?php
namespace App\Http\Controllers;

use App\Models\StudyCase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class StudyCaseController extends Controller
{
    /**
     *! Get all study cases.
     * 
     * This method returns all study cases in a JSON response.
     */
    public function index()
    {
        return response()->json(StudyCase::all(), 200);
    }

    /**
     *! Store a new study case.
     * 
     * This method validates the input, stores the file, and creates a new study case.
     */
    public function store(Request $request)
    {
        // Validate the input data
        $request->validate([
            'nom_etude' => 'required|string|max:255',
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut', // Ensure end date is after or same as start date
            'timing_attendu' => 'required|date_format:H:i:s',        // Expected timing
            'timing_reelle' => 'required|date_format:H:i:s',         // Actual timing
            'cadence_attendu' => 'required|numeric',                 // Expected cadence
            'cadence_reelle' => 'required|numeric',                  // Actual cadence
            'zipFile' => 'required|file|mimes:zip,rar,7z,gz,tar|max:10485760', // File validation for zip format
        ]);

        DB::beginTransaction();

        try {
            // Store the file and create the study case
            $studyCaseName = $request->nom_etude;
            $zipFilePath = $this->storeFile($request->file('zipFile'), $studyCaseName);

            // Create a new study case
            $studyCase = StudyCase::create([
                'nom_etude' => $request->nom_etude,
                'date_debut' => $request->date_debut,
                'date_fin' => $request->date_fin,
                'timing_attendu' => $request->timing_attendu,
                'timing_reelle' => $request->timing_reelle,
                'cadence_attendu' => $request->cadence_attendu,
                'cadence_reelle' => $request->cadence_reelle,
                'zipFile' => $zipFilePath,
            ]);

            DB::commit();

            // Return the created study case in a response
            return response()->json($studyCase, 201);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Failed to store StudyCase: " . $e->getMessage());
            return response()->json(['error' => 'Failed to store study case.'], 500);
        }
    }

    /**
     *! Show a specific study case.
     * 
     * This method returns a single study case in a JSON response.
     */
    public function show(StudyCase $studyCase)
    {
        return response()->json($studyCase, 200);
    }

    /**
     *! Update the information of a study case.
     * 
     * This method updates the study case details and handles renaming the associated directory if needed.
     */
    public function updateStudyCaseInfo(Request $request, StudyCase $studyCase)
    {
        Log::info("Received update request for StudyCase ID: {$studyCase->id}", $request->all());

        // Validate the input data for the update
        $validatedData = $request->validate([
            'nom_etude' => 'sometimes|required|string|max:255',
            'date_debut' => 'sometimes|required|date',
            'date_fin' => 'sometimes|required|date|after_or_equal:date_debut',
            'timing_attendu' => 'sometimes|required|date_format:H:i:s',
            'timing_reelle' => 'sometimes|required|date_format:H:i:s',
            'cadence_attendu' => 'sometimes|required|numeric',
            'cadence_reelle' => 'sometimes|required|numeric',
        ]);

        // Check if the study case name is being updated
        if (isset($validatedData['nom_etude']) && $validatedData['nom_etude'] !== $studyCase->nom_etude) {
            Log::info("StudyCase name change detected, old: {$studyCase->nom_etude}, new: {$validatedData['nom_etude']}");

            $oldDirectoryPath = "study_cases_files/{$studyCase->nom_etude}";
            $newDirectoryPath = "study_cases_files/{$validatedData['nom_etude']}";

            // Ensure the new directory name does not already exist
            if (Storage::disk('public')->exists($newDirectoryPath)) {
                Log::error("Directory with new name already exists: {$newDirectoryPath}");
                return response()->json(['error' => 'New directory name already exists.'], 409);
            }

            // Move the old directory to the new one
            if (Storage::disk('public')->exists($oldDirectoryPath)) {
                Storage::disk('public')->move($oldDirectoryPath, $newDirectoryPath);

                // Update the `zipFile` path
                if ($studyCase->zipFile) {
                    $validatedData['zipFile'] = str_replace($oldDirectoryPath, $newDirectoryPath, $studyCase->zipFile);
                }

                Log::info("Successfully moved directory from {$oldDirectoryPath} to {$newDirectoryPath}");
            } else {
                Log::error("Old directory does not exist: {$oldDirectoryPath}");
                return response()->json(['error' => 'Old directory does not exist.'], 404);
            }
        }

        // Update the study case with the validated data
        $studyCase->update($validatedData);

        Log::info("Successfully updated study case information for StudyCase ID: {$studyCase->id}");

        return response()->json($studyCase, 200);
    }

    /**
     *! Upload or update the zip file for the study case.
     * 
     * This method handles the file upload and updates the file path in the study case.
     */
    public function uploadZipFile(Request $request, StudyCase $studyCase)
    {
        Log::info("Received file upload request for StudyCase ID: {$studyCase->id}");

        // Validate the file input
        $request->validate([
            'zipFile' => 'required|file|mimes:zip,rar,7z,gz,tar|max:10485760',  // File validation for specific formats and max size
        ]);

        // Handle file upload
        if ($request->hasFile('zipFile')) {
            // Delete the old file if it exists
            if ($studyCase->zipFile) {
                Storage::disk('public')->delete($studyCase->zipFile);
            }

            // Store the new file and update the study case
            $zipFilePath = $this->storeFile($request->file('zipFile'), $studyCase->nom_etude);
            $studyCase->update(['zipFile' => $zipFilePath]);

            Log::info("Successfully uploaded new zip file for StudyCase ID: {$studyCase->id}");
        }

        return response()->json($studyCase, 200);
    }

    /**
     *! Store the uploaded file.
     * 
     * This method handles the logic for storing files in the proper directory structure.
     */
    private function storeFile($file, $studyCaseName)
    {
        $originalName = $file->getClientOriginalName();
        $fileName = pathinfo($originalName, PATHINFO_FILENAME);
        $extension = $file->getClientOriginalExtension();
        $finalName = $fileName . '_' . time() . '.' . $extension;

        // Store the file in a directory named after the study case
        return $file->storeAs("study_cases_files/{$studyCaseName}", $finalName, 'public');
    }

    /**
     *! Delete a study case and its associated files.
     * 
     * This method deletes the study case from the database and removes its files from storage.
     */
    public function destroy(StudyCase $studyCase)
    {
        $directoryPath = "study_cases_files/{$studyCase->nom_etude}";

        // Delete the directory if it exists
        if (Storage::disk('public')->exists($directoryPath)) {
            Storage::disk('public')->deleteDirectory($directoryPath);
        }

        // Delete the study case from the database
        $studyCase->delete();

        return response()->json(null, 204); // No content response after deletion
    }
}
