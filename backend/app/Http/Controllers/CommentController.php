<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    /* public function index()
    {
        return Comment::all();
    } */

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'study_case_id' => 'required|exists:study_cases,id',
            'comment' => 'required',
        ]);

        $comment = Comment::create($request->all());

        return response()->json($comment, 201);
    }

    public function show(Comment $comment)
    {
        return $comment;
    }

    /* public function update(Request $request, Comment $comment)
    {
        $validatedData = $request->validate([
            'user_id' => 'sometimes|required|exists:users,id',
            'study_case_id' => 'sometimes|required|exists:study_cases,id',
            'comment' => 'sometimes|required',
        ]);

        $comment->update($validatedData);

        return response()->json($comment, 200);
    } */
    public function update(Request $request, $id)
    {
        $request->validate([
            'comment' => 'required|string',
        ]);

        $comment = Comment::find($id);

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

        return response()->json($comment, 200);
    }



    public function destroy(Comment $comment)
    {
        $comment->delete();
        return response()->json(null, 204);
    }

    /**
     * Get comments by study_case_id.
     */
    public function getByStudyCaseId($study_case_id)
    {
        $comments = Comment::where('study_case_id', $study_case_id)->get();
        return response()->json($comments, 200);
    }

    /**
     * Get comments by user_id.
     */
    /* public function getByUserId($user_id)
    {
        $comments = Comment::where('user_id', $user_id)->get();
        return response()->json($comments, 200);
    } */

    /**
     * Get comments by study_case_id and user_id.
     */
    public function getByStudyCaseIdAndUserId($study_case_id, $user_id)
    {
        $comments = Comment::where('study_case_id', $study_case_id)
            ->where('user_id', $user_id)
            ->get();
        return response()->json($comments, 200);
    }
}
