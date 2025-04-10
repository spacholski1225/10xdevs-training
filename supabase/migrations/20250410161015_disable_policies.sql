-- Migration: Disable RLS policies for flashcards, flashcard_repetition_data, and user_statistics
-- Description: Drops all RLS policies from specified tables while maintaining RLS enabled

-- Drop policies for flashcards table
drop policy if exists "Users can view their own flashcards" on flashcards;
drop policy if exists "Users can create flashcards for themselves" on flashcards;
drop policy if exists "Users can update their own flashcards" on flashcards;
drop policy if exists "Users can delete their own flashcards" on flashcards;

-- Drop policies for flashcard_repetition_data table
drop policy if exists "Users can view repetition data for their flashcards" on flashcard_repetition_data;
drop policy if exists "Users can create repetition data for their flashcards" on flashcard_repetition_data;
drop policy if exists "Users can update repetition data for their flashcards" on flashcard_repetition_data;
drop policy if exists "Users can delete repetition data for their flashcards" on flashcard_repetition_data;

-- Drop policies for user_statistics table
drop policy if exists "Users can view their own statistics" on user_statistics;
drop policy if exists "Users can create their own statistics" on user_statistics;
drop policy if exists "Users can update their own statistics" on user_statistics;