Frontend - Astro z React dla komponentów interaktywnych:
- Astro 5 pozwala na tworzenie szybkich, wydajnych stron i aplikacji z minimalną ilością JavaScript
- React 19 zapewni interaktywność tam, gdzie jest potrzebna
- TypeScript 5 dla statycznego typowania kodu i lepszego wsparcia IDE
- Tailwind 4 pozwala na wygodne stylowanie aplikacji
- Shadcn/ui zapewnia bibliotekę dostępnych komponentów React, na których oprzemy UI

Backend - Supabase jako kompleksowe rozwiązanie backendowe:
- Zapewnia bazę danych PostgreSQL
- Zapewnia SDK w wielu językach, które posłużą jako Backend-as-a-Service
- Jest rozwiązaniem open source, które można hostować lokalnie lub na własnym serwerze
- Posiada wbudowaną autentykację użytkowników

AI - Komunikacja z modelami przez usługę Openrouter.ai:
- Dostęp do szerokiej gamy modeli (OpenAI, Anthropic, Google i wiele innych), które pozwolą nam znaleźć rozwiązanie zapewniające wysoką efektywność i niskie koszta
- Pozwala na ustawianie limitów finansowych na klucze API

Testowanie - Kompleksowa strategia testów:
- Vitest do testów jednostkowych i integracyjnych:
  - Szybkie wykonanie testów
  - Natywne wsparcie dla TypeScript
  - Integracja z React Testing Library
  - Mockowanie modułów i API
- Playwright do testów E2E i API:
  - Automatyzacja testów w różnych przeglądarkach
  - Testy API z wbudowanym wsparciem dla REST
  - Generowanie raportów i zrzutów ekranu
  - Nagrywanie i odtwarzanie scenariuszy testowych
- Chrome DevTools do testów wydajnościowych:
  - Analiza wydajności renderowania
  - Profilowanie zużycia pamięci
  - Audyty wydajności i dostępności

CI/CD i Hosting:
- Github Actions do tworzenia pipeline'ów CI/CD:
  - Automatyczne uruchamianie testów
  - Generowanie raportów pokrycia kodu
  - Weryfikacja jakości kodu
- DigitalOcean do hostowania aplikacji za pośrednictwem obrazu docker