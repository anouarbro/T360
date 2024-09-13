<?php
namespace App\Http\Controllers;

use App\Models\StudyCase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class StudyCaseController extends Controller
{
    public function index()
    {
        return response()->json(StudyCase::all(), 200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nom_etude' => 'required|string|max:255',
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut',
            'timing_attendu' => 'required|date_format:H:i:s',
            'timing_reelle' => 'required|date_format:H:i:s',
            'cadence_attendu' => 'required|numeric',
            'cadence_reelle' => 'required|numeric',
            'zipFile' => 'required|file|mimes:zip,rar,7z,gz,tar|max:10485760',
        ]);

        DB::beginTransaction();

        try {
            $studyCaseName = $request->nom_etude;
            $zipFilePath = $this->storeFile($request->file('zipFile'), $studyCaseName);

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

            return response()->json($studyCase, 201);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Failed to store StudyCase: " . $e->getMessage());
            return response()->json(['error' => 'Failed to store study case.'], 500);
        }
    }

    public function show(StudyCase $studyCase)
    {
        return response()->json($studyCase, 200);
    }

    // Update StudyCase information only
    /* public function updateStudyCaseInfo(Request $request, StudyCase $studyCase)
    {
        Log::info("Received update request for StudyCase ID: {$studyCase->id}", $request->all());

        $validatedData = $request->validate([
            'nom_etude' => 'sometimes|required|string|max:255',
            'date_debut' => 'sometimes|required|date',
            'date_fin' => 'sometimes|required|date|after_or_equal:date_debut',
            'timing_attendu' => 'sometimes|required|date_format:H:i:s',
            'timing_reelle' => 'sometimes|required|date_format:H:i:s',
            'cadence_attendu' => 'sometimes|required|numeric',
            'cadence_reelle' => 'sometimes|required|numeric',
        ]);

        $studyCase->update($validatedData);

        Log::info("Successfully updated study case information for StudyCase ID: {$studyCase->id}");

        return response()->json($studyCase, 200);
    } */
    public function updateStudyCaseInfo(Request $request, StudyCase $studyCase)
    {
        Log::info("Received update request for StudyCase ID: {$studyCase->id}", $request->all());

        $validatedData = $request->validate([
            'nom_etude' => 'sometimes|required|string|max:255',
            'date_debut' => 'sometimes|required|date',
            'date_fin' => 'sometimes|required|date|after_or_equal:date_debut',
            'timing_attendu' => 'sometimes|required|date_format:H:i:s',
            'timing_reelle' => 'sometimes|required|date_format:H:i:s',
            'cadence_attendu' => 'sometimes|required|numeric',
            'cadence_reelle' => 'sometimes|required|numeric',
        ]);

        // Check if the study case name is changing
        if (isset($validatedData['nom_etude']) && $validatedData['nom_etude'] !== $studyCase->nom_etude) {
            Log::info("StudyCase name change detected, old: {$studyCase->nom_etude}, new: {$validatedData['nom_etude']}");

            $oldDirectoryPath = "study_cases_files/{$studyCase->nom_etude}";
            $newDirectoryPath = "study_cases_files/{$validatedData['nom_etude']}";

            // Check if the new directory already exists
            if (Storage::disk('public')->exists($newDirectoryPath)) {
                Log::error("Directory with new name already exists: {$newDirectoryPath}");
                return response()->json(['error' => 'New directory name already exists.'], 409);
            }

            // Move the old directory to the new one if it exists
            if (Storage::disk('public')->exists($oldDirectoryPath)) {
                Storage::disk('public')->move($oldDirectoryPath, $newDirectoryPath);

                // Update the `zipFile` path if it exists in the study case
                if ($studyCase->zipFile) {
                    $validatedData['zipFile'] = str_replace($oldDirectoryPath, $newDirectoryPath, $studyCase->zipFile);
                }

                Log::info("Successfully moved directory from {$oldDirectoryPath} to {$newDirectoryPath}");
            } else {
                Log::error("Old directory does not exist: {$oldDirectoryPath}");
                return response()->json(['error' => 'Old directory does not exist.'], 404);
            }
        }

        // Update the study case with validated data
        $studyCase->update($validatedData);

        Log::info("Successfully updated study case information for StudyCase ID: {$studyCase->id}");

        return response()->json($studyCase, 200);
    }


    // Upload or update the file for the StudyCase
    public function uploadZipFile(Request $request, StudyCase $studyCase)
    {
        Log::info("Received file upload request for StudyCase ID: {$studyCase->id}");

        $request->validate([
            'zipFile' => 'required|file|mimes:zip,rar,7z,gz,tar|max:10485760',  // Required file validation
        ]);

        // Check if a file is provided
        if ($request->hasFile('zipFile')) {
            // Delete old file if it exists
            if ($studyCase->zipFile) {
                Storage::disk('public')->delete($studyCase->zipFile);
            }

            // Store the new file
            $zipFilePath = $this->storeFile($request->file('zipFile'), $studyCase->nom_etude);
            $studyCase->update(['zipFile' => $zipFilePath]);

            Log::info("Successfully uploaded new zip file for StudyCase ID: {$studyCase->id}");
        }

        return response()->json($studyCase, 200);
    }

    private function storeFile($file, $studyCaseName)
    {
        $originalName = $file->getClientOriginalName();
        $fileName = pathinfo($originalName, PATHINFO_FILENAME);
        $extension = $file->getClientOriginalExtension();
        $finalName = $fileName . '_' . time() . '.' . $extension;

        return $file->storeAs("study_cases_files/{$studyCaseName}", $finalName, 'public');
    }


    public function destroy(StudyCase $studyCase)
    {
        $directoryPath = "study_cases_files/{$studyCase->nom_etude}";

        if (Storage::disk('public')->exists($directoryPath)) {
            Storage::disk('public')->deleteDirectory($directoryPath);
        }

        $studyCase->delete();

        return response()->json(null, 204);
    }

}

