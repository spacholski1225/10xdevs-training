# Schemat bazy danych PostgreSQL dla aplikacji 10x-cards

## 1. Tabele i ich struktura

### 1.1. Tabela `users`

| Kolumna | Typ | Opis | Ograniczenia |
|---------|-----|------|--------------|
| id | UUID | Unikalny identyfikator użytkownika | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| email | TEXT | Adres email użytkownika | UNIQUE, NOT NULL |
| password_hash | TEXT | Zahaszowane hasło użytkownika | NOT NULL |
| is_active | BOOLEAN | Status aktywności konta (dla soft delete) | NOT NULL, DEFAULT TRUE |
| created_at | TIMESTAMP WITH TIME ZONE | Data utworzenia konta | NOT NULL, DEFAULT NOW() |
| updated_at | TIMESTAMP WITH TIME ZONE | Data ostatniej aktualizacji konta | NOT NULL, DEFAULT NOW() |

### 1.2. Tabela `flashcards`

| Kolumna | Typ | Opis | Ograniczenia |
|---------|-----|------|--------------|
| id | UUID | Unikalny identyfikator fiszki | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| user_id | UUID | Identyfikator właściciela fiszki | REFERENCES users(id), NOT NULL |
| front | TEXT | Treść przedniej strony fiszki | NOT NULL, CHECK (LENGTH(front) <= 1000) |
| back | TEXT | Treść tylnej strony fiszki | NOT NULL, CHECK (LENGTH(back) <= 1000) |
| is_ai_generated | BOOLEAN | Czy fiszka została wygenerowana przez AI | NOT NULL, DEFAULT FALSE |
| created_at | TIMESTAMP WITH TIME ZONE | Data utworzenia fiszki | NOT NULL, DEFAULT NOW() |
| updated_at | TIMESTAMP WITH TIME ZONE | Data ostatniej aktualizacji fiszki | NOT NULL, DEFAULT NOW() |

### 1.3. Tabela `flashcard_repetition_data`

| Kolumna | Typ | Opis | Ograniczenia |
|---------|-----|------|--------------|
| id | UUID | Unikalny identyfikator danych powtórek | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| flashcard_id | UUID | Identyfikator powiązanej fiszki | REFERENCES flashcards(id) ON DELETE CASCADE, UNIQUE, NOT NULL |
| last_review_date | TIMESTAMP WITH TIME ZONE | Data ostatniej powtórki | NULL |
| next_review_date | TIMESTAMP WITH TIME ZONE | Data następnej zaplanowanej powtórki | NULL |
| knowledge_rating | INTEGER | Ocena znajomości materiału (1-5) | NULL, CHECK (knowledge_rating BETWEEN 1 AND 5) |
| created_at | TIMESTAMP WITH TIME ZONE | Data utworzenia rekordu | NOT NULL, DEFAULT NOW() |
| updated_at | TIMESTAMP WITH TIME ZONE | Data ostatniej aktualizacji rekordu | NOT NULL, DEFAULT NOW() |

### 1.4. Tabela `user_statistics`

| Kolumna | Typ | Opis | Ograniczenia |
|---------|-----|------|--------------|
| id | UUID | Unikalny identyfikator statystyk | PRIMARY KEY, DEFAULT uuid_generate_v4() |
| user_id | UUID | Identyfikator powiązanego użytkownika | REFERENCES users(id) ON DELETE CASCADE, UNIQUE, NOT NULL |
| total_flashcards_generated | INTEGER | Liczba wygenerowanych fiszek przez AI | NOT NULL, DEFAULT 0 |
| total_flashcards_accepted | INTEGER | Liczba zaakceptowanych fiszek wygenerowanych przez AI | NOT NULL, DEFAULT 0 |
| created_at | TIMESTAMP WITH TIME ZONE | Data utworzenia rekordu | NOT NULL, DEFAULT NOW() |
| updated_at | TIMESTAMP WITH TIME ZONE | Data ostatniej aktualizacji rekordu | NOT NULL, DEFAULT NOW() |

## 2. Relacje między tabelami

1. **users** 1 → 0..* **flashcards** (Jeden użytkownik może mieć wiele fiszek)
2. **users** 1 → 0..1 **user_statistics** (Jeden użytkownik ma jeden rekord statystyk)
3. **flashcards** 1 → 1 **flashcard_repetition_data** (Jedna fiszka ma jeden rekord danych powtórek)

## 3. Indeksy

| Tabela | Kolumna | Typ indeksu | Uzasadnienie |
|--------|---------|-------------|--------------|
| users | email | BTREE | Przyspiesza wyszukiwanie użytkowników po adresie email |
| flashcards | user_id | BTREE | Przyspiesza wyszukiwanie fiszek należących do danego użytkownika |
| flashcard_repetition_data | next_review_date | BTREE | Przyspiesza wyszukiwanie fiszek do powtórki na daną datę |
| flashcard_repetition_data | flashcard_id | BTREE | Przyspiesza wyszukiwanie danych powtórek dla konkretnej fiszki |

## 4. Polityki Row Level Security (RLS)

### 4.1. Tabela `users`

```sql
-- Tylko administrator ma dostęp do wszystkich użytkowników
CREATE POLICY "Administratorzy mają pełny dostęp do użytkowników" ON users
    FOR ALL
    TO authenticated
    USING (auth.uid() IN (SELECT id FROM administrators));

-- Użytkownicy mogą widzieć tylko swoje dane
CREATE POLICY "Użytkownicy widzą tylko swoje dane" ON users
    FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

-- Użytkownicy mogą aktualizować tylko swoje dane
CREATE POLICY "Użytkownicy mogą aktualizować tylko swoje dane" ON users
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);
```

### 4.2. Tabela `flashcards`

```sql
-- Użytkownicy mogą widzieć tylko swoje fiszki
CREATE POLICY "Użytkownicy widzą tylko swoje fiszki" ON flashcards
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Użytkownicy mogą tworzyć fiszki tylko dla siebie
CREATE POLICY "Użytkownicy mogą tworzyć fiszki tylko dla siebie" ON flashcards
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Użytkownicy mogą aktualizować tylko swoje fiszki
CREATE POLICY "Użytkownicy mogą aktualizować tylko swoje fiszki" ON flashcards
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

-- Użytkownicy mogą usuwać tylko swoje fiszki
CREATE POLICY "Użytkownicy mogą usuwać tylko swoje fiszki" ON flashcards
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);
```

### 4.3. Tabela `flashcard_repetition_data`

```sql
-- Użytkownicy mogą widzieć tylko dane powtórek swoich fiszek
CREATE POLICY "Użytkownicy widzą tylko dane powtórek swoich fiszek" ON flashcard_repetition_data
    FOR SELECT
    TO authenticated
    USING (flashcard_id IN (SELECT id FROM flashcards WHERE user_id = auth.uid()));

-- Użytkownicy mogą tworzyć dane powtórek tylko dla swoich fiszek
CREATE POLICY "Użytkownicy mogą tworzyć dane powtórek tylko dla swoich fiszek" ON flashcard_repetition_data
    FOR INSERT
    TO authenticated
    WITH CHECK (flashcard_id IN (SELECT id FROM flashcards WHERE user_id = auth.uid()));

-- Użytkownicy mogą aktualizować dane powtórek tylko swoich fiszek
CREATE POLICY "Użytkownicy mogą aktualizować dane powtórek tylko swoich fiszek" ON flashcard_repetition_data
    FOR UPDATE
    TO authenticated
    USING (flashcard_id IN (SELECT id FROM flashcards WHERE user_id = auth.uid()));

-- Użytkownicy mogą usuwać dane powtórek tylko swoich fiszek
CREATE POLICY "Użytkownicy mogą usuwać dane powtórek tylko swoich fiszek" ON flashcard_repetition_data
    FOR DELETE
    TO authenticated
    USING (flashcard_id IN (SELECT id FROM flashcards WHERE user_id = auth.uid()));
```

### 4.4. Tabela `user_statistics`

```sql
-- Użytkownicy mogą widzieć tylko swoje statystyki
CREATE POLICY "Użytkownicy widzą tylko swoje statystyki" ON user_statistics
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Użytkownicy mogą tworzyć statystyki tylko dla siebie
CREATE POLICY "Użytkownicy mogą tworzyć statystyki tylko dla siebie" ON user_statistics
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- Użytkownicy mogą aktualizować tylko swoje statystyki
CREATE POLICY "Użytkownicy mogą aktualizować tylko swoje statystyki" ON user_statistics
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid());
```

## 5. Wyzwalacze (Triggers) i funkcje

### 5.1. Automatyczne tworzenie danych powtórek przy tworzeniu fiszki

```sql
CREATE OR REPLACE FUNCTION create_flashcard_repetition_data()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO flashcard_repetition_data (flashcard_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_flashcard_repetition_data
AFTER INSERT ON flashcards
FOR EACH ROW
EXECUTE FUNCTION create_flashcard_repetition_data();
```

### 5.2. Automatyczne tworzenie rekordu statystyk przy tworzeniu użytkownika

```sql
CREATE OR REPLACE FUNCTION create_user_statistics()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_statistics (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_user_statistics
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION create_user_statistics();
```

### 5.3. Aktualizacja statystyk użytkownika przy dodawaniu fiszek

```sql
CREATE OR REPLACE FUNCTION update_user_statistics_on_flashcard_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_ai_generated THEN
        UPDATE user_statistics
        SET 
            total_flashcards_generated = total_flashcards_generated + 1,
            total_flashcards_accepted = total_flashcards_accepted + 1,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_statistics_on_flashcard_insert
AFTER INSERT ON flashcards
FOR EACH ROW
EXECUTE FUNCTION update_user_statistics_on_flashcard_insert();
```

### 5.4. Automatyczna aktualizacja pola updated_at

```sql
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_users_modtime
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER trigger_update_flashcards_modtime
BEFORE UPDATE ON flashcards
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER trigger_update_flashcard_repetition_data_modtime
BEFORE UPDATE ON flashcard_repetition_data
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER trigger_update_user_statistics_modtime
BEFORE UPDATE ON user_statistics
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();
```

## 6. Dodatkowe uwagi i wyjaśnienia

1. **UUID jako klucz główny**: Zastosowano UUID jako klucz główny we wszystkich tabelach, co jest zgodne z dobrymi praktykami Supabase i ułatwia synchronizację danych.

2. **Bezpieczeństwo danych**: Polityki RLS zapewniają, że użytkownicy mają dostęp tylko do własnych danych, co jest zgodne z wymaganiami RODO.

3. **Soft delete dla użytkowników**: Zastosowano miękkie usuwanie (soft delete) dla użytkowników poprzez flagę is_active, co pozwala na zachowanie historycznych danych zgodnie z wymaganiami prawnymi.

4. **Automatyczne tworzenie powiązanych rekordów**: Wyzwalacze zapewniają automatyczne tworzenie danych powtórek i statystyk przy tworzeniu odpowiednio fiszek i użytkowników.

5. **Statystyki użytkownika**: Automatyczna aktualizacja statystyk przy dodawaniu nowych fiszek wygenerowanych przez AI.

6. **Ograniczenia na długość tekstu**: Zastosowano ograniczenia CHECK na długość tekstów fiszek (maksymalnie 1000 znaków).

7. **Indeksy**: Dodano indeksy na kolumnach używanych w zapytaniach filtrujących, szczególnie dla dat zaplanowanych powtórek, co poprawia wydajność zapytań.