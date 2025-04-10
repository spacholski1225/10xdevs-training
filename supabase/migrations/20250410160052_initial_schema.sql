-- Migration: Initial database schema for 10x-cards application
-- Description: Creates users, flashcards, flashcard_repetition_data, and user_statistics tables
--             with proper constraints, RLS policies, triggers, and indexes

-- Enable UUID extension if not already enabled
create extension if not exists "uuid-ossp";

-- Create tables
create table users (
    id uuid primary key default uuid_generate_v4(),
    email text not null unique,
    password_hash text not null,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table flashcards (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references users(id),
    front text not null check (length(front) <= 1000),
    back text not null check (length(back) <= 1000),
    is_ai_generated boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table flashcard_repetition_data (
    id uuid primary key default uuid_generate_v4(),
    flashcard_id uuid not null unique references flashcards(id) on delete cascade,
    last_review_date timestamptz,
    next_review_date timestamptz,
    knowledge_rating integer check (knowledge_rating between 1 and 5),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table user_statistics (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null unique references users(id) on delete cascade,
    total_flashcards_generated integer not null default 0,
    total_flashcards_accepted integer not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Create indexes
create index users_email_idx on users using btree (email);
create index flashcards_user_id_idx on flashcards using btree (user_id);
create index flashcard_repetition_data_next_review_date_idx on flashcard_repetition_data using btree (next_review_date);
create index flashcard_repetition_data_flashcard_id_idx on flashcard_repetition_data using btree (flashcard_id);

-- Enable Row Level Security
alter table users enable row level security;
alter table flashcards enable row level security;
alter table flashcard_repetition_data enable row level security;
alter table user_statistics enable row level security;

-- Create RLS policies for users table
-- Users can only access their own data for security
create policy "Users can view their own data" on users
    for select
    to authenticated
    using (auth.uid() = id);

create policy "Users can create their own data" on users
    for insert
    to authenticated
    with check (auth.uid() = id);

create policy "Users can update their own data" on users
    for update
    to authenticated
    using (auth.uid() = id);

-- Create RLS policies for flashcards table
create policy "Users can view their own flashcards" on flashcards
    for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can create flashcards for themselves" on flashcards
    for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own flashcards" on flashcards
    for update
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can delete their own flashcards" on flashcards
    for delete
    to authenticated
    using (auth.uid() = user_id);

-- Create RLS policies for flashcard_repetition_data table
create policy "Users can view repetition data for their flashcards" on flashcard_repetition_data
    for select
    to authenticated
    using (flashcard_id in (select id from flashcards where user_id = auth.uid()));

create policy "Users can create repetition data for their flashcards" on flashcard_repetition_data
    for insert
    to authenticated
    with check (flashcard_id in (select id from flashcards where user_id = auth.uid()));

create policy "Users can update repetition data for their flashcards" on flashcard_repetition_data
    for update
    to authenticated
    using (flashcard_id in (select id from flashcards where user_id = auth.uid()));

create policy "Users can delete repetition data for their flashcards" on flashcard_repetition_data
    for delete
    to authenticated
    using (flashcard_id in (select id from flashcards where user_id = auth.uid()));

-- Create RLS policies for user_statistics table
create policy "Users can view their own statistics" on user_statistics
    for select
    to authenticated
    using (user_id = auth.uid());

create policy "Users can create their own statistics" on user_statistics
    for insert
    to authenticated
    with check (user_id = auth.uid());

create policy "Users can update their own statistics" on user_statistics
    for update
    to authenticated
    using (user_id = auth.uid());

-- Create functions and triggers
create or replace function create_flashcard_repetition_data()
returns trigger as $$
begin
    insert into flashcard_repetition_data (flashcard_id)
    values (new.id);
    return new;
end;
$$ language plpgsql;

create trigger trigger_create_flashcard_repetition_data
    after insert on flashcards
    for each row
    execute function create_flashcard_repetition_data();

create or replace function create_user_statistics()
returns trigger as $$
begin
    insert into user_statistics (user_id)
    values (new.id);
    return new;
end;
$$ language plpgsql;

create trigger trigger_create_user_statistics
    after insert on users
    for each row
    execute function create_user_statistics();

create or replace function update_user_statistics_on_flashcard_insert()
returns trigger as $$
begin
    if new.is_ai_generated then
        update user_statistics
        set 
            total_flashcards_generated = total_flashcards_generated + 1,
            total_flashcards_accepted = total_flashcards_accepted + 1,
            updated_at = now()
        where user_id = new.user_id;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trigger_update_user_statistics_on_flashcard_insert
    after insert on flashcards
    for each row
    execute function update_user_statistics_on_flashcard_insert();

create or replace function update_modified_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger trigger_update_users_modtime
    before update on users
    for each row
    execute function update_modified_column();

create trigger trigger_update_flashcards_modtime
    before update on flashcards
    for each row
    execute function update_modified_column();

create trigger trigger_update_flashcard_repetition_data_modtime
    before update on flashcard_repetition_data
    for each row
    execute function update_modified_column();

create trigger trigger_update_user_statistics_modtime
    before update on user_statistics
    for each row
    execute function update_modified_column();