<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    /**
     *! Store a new comment.
     * 
     * This method validates the input, ensuring the user ID and study case ID exist,
     * and then creates a new comment.
     */
    public function store(Request $request)
    {
        // Validate the request input
        $request->validate([
            'user_id' => 'required|exists:users,id',            // Ensure user ID exists in the users table
            'study_case_id' => 'required|exists:study_cases,id', // Ensure study case ID exists in the study_cases table
            'comment' => 'required',                            // The comment field is required
        ]);

        // Create a new comment using the validated data
        $comment = Comment::create($request->all());

        // Return the newly created comment with a 201 status
        return response()->json($comment, 201);
    }

    /**
     *! Show a specific comment.
     * 
     * This method returns the details of a comment based on its ID.
     */
    public function show(Comment $comment)
    {
        return $comment;
    }

    /**
     *! Update a comment.
     * 
     * This method allows the owner of the comment to update it after validation.
     */
    public function update(Request $request, $id)
    {
        // Validate the request input
        $request->validate([
            'comment' => 'required|string',  // Ensure the comment is a string and required
        ]);

        // Find the comment by its ID
        $comment = Comment::find($id);

        // If the comment doesn't exist, return a 404 error
        if (!$comment) {
            return response()->json(['message' => 'Comment not found'], 404);
        }

        // Check if the authenticated user is the owner of the comment
        if ($comment->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Update the comment
        $comment->comment = $request->comment;
        $comment->save();

        // Return the updated comment with a 200 status
        return response()->json($comment, 200);
    }

    /**
     *! Delete a comment.
     * 
     * This method deletes a comment from the database.
     */
    public function destroy(Comment $comment)
    {
        // Delete the comment
        $comment->delete();

        // Return a 204 No Content response after successful deletion
        return response()->json(null, 204);
    }

    /**
     *! Get comments by study_case_id.
     * 
     * This method retrieves all comments related to a specific study case ID.
     */
    public function getByStudyCaseId($study_case_id)
    {
        // Retrieve all comments for the given study case ID
        $comments = Comment::where('study_case_id', $study_case_id)->get();

        // Return the comments with a 200 status
        return response()->json($comments, 200);
    }

    /**
     *! Get comments by study_case_id and user_id.
     * 
     * This method retrieves all comments related to a specific study case ID and user ID.
     */
    public function getByStudyCaseIdAndUserId($study_case_id, $user_id)
    {
        // Retrieve comments that match both study case ID and user ID
        $comments = Comment::where('study_case_id', $study_case_id)
            ->where('user_id', $user_id)
            ->get();

        // Return the comments with a 200 status
        return response()->json($comments, 200);
    }
}

