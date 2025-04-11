-- Description: Initial schema for the flashcards application
-- Creates tables: flashcards, generations, generation_error_logs
-- Enables RLS and sets up security policies

-- Create generations table first (moved up)
create table if not exists public.generations (
    id bigserial primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    model varchar not null,
    generated_count integer not null,
    accepted_unedited_count integer,
    accepted_edited_count integer,
    source_text_hash varchar not null,
    source_text_length integer not null check (source_text_length between 1000 and 10000),
    generation_duration integer not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Create flashcards table (moved down)
create table if not exists public.flashcards (
    id bigserial primary key,
    front varchar(200) not null,
    back varchar(500) not null,
    source varchar not null check (source in ('ai-full', 'ai-edited', 'manual')),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    generation_id bigint references generations(id) on delete set null,
    user_id uuid not null references auth.users(id) on delete cascade,
    status varchar(20) not null check (status in ('active', 'archived', 'deleted')) default 'active'
);

-- Create generation_error_logs table
create table if not exists public.generation_error_logs (
    id bigserial primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    model varchar not null,
    source_text_hash varchar not null,
    source_text_length integer not null check (source_text_length between 1000 and 10000),
    error_code varchar(100) not null,
    error_message text not null,
    created_at timestamptz not null default now()
);

-- Create indexes
create index flashcards_user_id_idx on public.flashcards(user_id);
create index flashcards_generation_id_idx on public.flashcards(generation_id);
create index flashcards_user_id_status_idx on public.flashcards(user_id, status);
create index generations_user_id_idx on public.generations(user_id);
create index generations_source_text_hash_idx on public.generations(source_text_hash);
create index generations_user_id_created_at_idx on public.generations(user_id, created_at);
create index generation_error_logs_user_id_idx on public.generation_error_logs(user_id);

-- Create trigger for updating updated_at
create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- Add triggers for both flashcards and generations
create trigger set_updated_at
    before update on public.flashcards
    for each row
    execute function public.handle_updated_at();

create trigger set_generations_updated_at
    before update on public.generations
    for each row
    execute function public.handle_updated_at();

-- Enable RLS
alter table public.flashcards enable row level security;
alter table public.generations enable row level security;
alter table public.generation_error_logs enable row level security;

-- RLS Policies for authenticated users
create policy "Users can view their own flashcards"
    on public.flashcards for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can insert their own flashcards"
    on public.flashcards for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own flashcards"
    on public.flashcards for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create policy "Users can delete their own flashcards"
    on public.flashcards for delete
    to authenticated
    using (auth.uid() = user_id);

-- Policies for generations table
create policy "Users can view their own generations"
    on public.generations for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can insert their own generations"
    on public.generations for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own generations"
    on public.generations for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Policies for error logs
create policy "Users can view their own error logs"
    on public.generation_error_logs for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can insert their own error logs"
    on public.generation_error_logs for insert
    to authenticated
    with check (auth.uid() = user_id);
