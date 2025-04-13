-- Description: Disable all RLS policies for flashcards, generations, and generation_error_logs tables
-- This migration is reversible

-- Disable policies for flashcards table
drop policy if exists "Users can view their own flashcards" on public.flashcards;
drop policy if exists "Users can insert their own flashcards" on public.flashcards;
drop policy if exists "Users can update their own flashcards" on public.flashcards;
drop policy if exists "Users can delete their own flashcards" on public.flashcards;

-- Disable policies for generations table
drop policy if exists "Users can view their own generations" on public.generations;
drop policy if exists "Users can insert their own generations" on public.generations;
drop policy if exists "Users can update their own generations" on public.generations;

-- Disable policies for generation_error_logs table
drop policy if exists "Users can view their own error logs" on public.generation_error_logs;
drop policy if exists "Users can insert their own error logs" on public.generation_error_logs;
