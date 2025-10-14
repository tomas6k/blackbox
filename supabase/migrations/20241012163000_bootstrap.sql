

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "auth";


ALTER SCHEMA "auth" OWNER TO "supabase_admin";


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE SCHEMA IF NOT EXISTS "storage";


ALTER SCHEMA "storage" OWNER TO "supabase_admin";


CREATE TYPE "auth"."aal_level" AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE "auth"."aal_level" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."code_challenge_method" AS ENUM (
    's256',
    'plain'
);


ALTER TYPE "auth"."code_challenge_method" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."factor_status" AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE "auth"."factor_status" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."factor_type" AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE "auth"."factor_type" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."oauth_registration_type" AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE "auth"."oauth_registration_type" OWNER TO "supabase_auth_admin";


CREATE TYPE "auth"."one_time_token_type" AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE "auth"."one_time_token_type" OWNER TO "supabase_auth_admin";


CREATE TYPE "storage"."buckettype" AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


ALTER TYPE "storage"."buckettype" OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "auth"."email"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION "auth"."email"() OWNER TO "supabase_auth_admin";


COMMENT ON FUNCTION "auth"."email"() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';



CREATE OR REPLACE FUNCTION "auth"."jwt"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION "auth"."jwt"() OWNER TO "supabase_auth_admin";


CREATE OR REPLACE FUNCTION "auth"."role"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION "auth"."role"() OWNER TO "supabase_auth_admin";


COMMENT ON FUNCTION "auth"."role"() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';



CREATE OR REPLACE FUNCTION "auth"."uid"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION "auth"."uid"() OWNER TO "supabase_auth_admin";


COMMENT ON FUNCTION "auth"."uid"() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';



CREATE OR REPLACE FUNCTION "public"."apply_agio_penalties"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    saison_record RECORD;
    penalite_record RECORD;
    user_team_record RECORD;
    owner_record RECORD;
    negative_sum DECIMAL;
    positive_sum DECIMAL;
    total_sum DECIMAL;
BEGIN
    -- Parcourir toutes les saisons où agio est TRUE
    FOR saison_record IN
        SELECT id, team_id, agio_step1, agio_step2, agio_step3
        FROM saisons
        WHERE agio = TRUE
    LOOP
        RAISE NOTICE 'Processing season ID: %', saison_record.id;

        -- Trouver le propriétaire de l'équipe
        SELECT * INTO owner_record
        FROM user_teams
        WHERE team_id = saison_record.team_id
        AND role = 'owner'
        LIMIT 1;

        IF owner_record.id IS NOT NULL THEN
            RAISE NOTICE 'Found team owner ID: %', owner_record.id;

            -- Parcourir tous les utilisateurs de l'équipe
            FOR user_team_record IN
                SELECT id, agio
                FROM user_teams
                WHERE team_id = saison_record.team_id
            LOOP
                -- Calculer la somme des transactions négatives en excluant celles du mois actuel
                SELECT COALESCE(SUM(transaction_value), 0) INTO negative_sum
                FROM transactions
                WHERE transaction_to = user_team_record.id
                AND saison_id = saison_record.id
                AND statut = '1'
                AND transaction_value < 0
                AND transaction_date < date_trunc('month', CURRENT_DATE);

                -- Calculer la somme des transactions positives
                SELECT COALESCE(SUM(transaction_value), 0) INTO positive_sum
                FROM transactions
                WHERE transaction_to = user_team_record.id
                AND saison_id = saison_record.id
                AND statut = '1'
                AND transaction_value > 0;

                -- Calculer la somme totale
                total_sum := positive_sum + negative_sum;

                -- Correction: Ne pas appliquer de pénalité si total_sum >= 0
                IF total_sum >= 0 THEN
                    -- Si la somme est positive ou zéro, mettre à jour la colonne "agio" à 0
                    UPDATE user_teams
                    SET agio = 0
                    WHERE id = user_team_record.id;

                ELSE
                    -- Si la somme est négative, traiter en fonction de la valeur actuelle de "agio"
                    IF user_team_record.agio = 0 THEN
                        -- Augmenter agio de +1 et appliquer agio_step1
                        UPDATE user_teams
                        SET agio = 1
                        WHERE id = user_team_record.id;

                        -- Rechercher la pénalité "agio"
                        SELECT * INTO penalite_record
                        FROM penalties
                        WHERE saison_id = saison_record.id
                        AND penalitie_custom = 'agio'
                        LIMIT 1;

                        IF penalite_record.id IS NOT NULL THEN
                            -- Créer une transaction avec agio_step1
                            INSERT INTO transactions (
                                transaction_value,
                                transaction_to,
                                penalitie_id,
                                saison_id,
                                created_by,
                                created_time,
                                transaction_date,
                                statut
                            ) VALUES (
                                saison_record.agio_step1,
                                user_team_record.id,
                                penalite_record.id,
                                saison_record.id,
                                owner_record.id,
                                NOW(),
                                NOW(),
                                1
                            );
                        END IF;

                    ELSIF user_team_record.agio = 1 THEN
                        -- Augmenter agio de +1 et appliquer agio_step2
                        UPDATE user_teams
                        SET agio = 2
                        WHERE id = user_team_record.id;

                        -- Rechercher la pénalité "agio"
                        SELECT * INTO penalite_record
                        FROM penalties
                        WHERE saison_id = saison_record.id
                        AND penalitie_custom = 'agio'
                        LIMIT 1;

                        IF penalite_record.id IS NOT NULL THEN
                            -- Créer une transaction avec agio_step2
                            INSERT INTO transactions (
                                transaction_value,
                                transaction_to,
                                penalitie_id,
                                saison_id,
                                created_by,
                                created_time,
                                transaction_date,
                                statut
                            ) VALUES (
                                saison_record.agio_step2,
                                user_team_record.id,
                                penalite_record.id,
                                saison_record.id,
                                owner_record.id,
                                NOW(),
                                NOW(),
                                1
                            );
                        END IF;

                    ELSE
                        -- Augmenter agio de +1 et appliquer agio_step3
                        UPDATE user_teams
                        SET agio = agio + 1
                        WHERE id = user_team_record.id;

                        -- Rechercher la pénalité "agio"
                        SELECT * INTO penalite_record
                        FROM penalties
                        WHERE saison_id = saison_record.id
                        AND penalitie_custom = 'agio'
                        LIMIT 1;

                        IF penalite_record.id IS NOT NULL THEN
                            -- Créer une transaction avec agio_step3
                            INSERT INTO transactions (
                                transaction_value,
                                transaction_to,
                                penalitie_id,
                                saison_id,
                                created_by,
                                created_time,
                                transaction_date,
                                statut
                            ) VALUES (
                                saison_record.agio_step3,
                                user_team_record.id,
                                penalite_record.id,
                                saison_record.id,
                                owner_record.id,
                                NOW(),
                                NOW(),
                                1
                            );
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        ELSE
            RAISE NOTICE 'No owner found for team ID: %', saison_record.team_id;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."apply_agio_penalties"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."apply_away_penalties"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    saison_record RECORD;
    penalite_record RECORD;
    user_team_absent RECORD;
    user_team_present RECORD;
    owner_record RECORD;
    negative_sums DECIMAL[] := '{}'; -- Tableau pour stocker les sommes négatives
    median_negative_sum DECIMAL;
BEGIN
    -- Parcourir toutes les saisons où "away" est TRUE
    FOR saison_record IN
        SELECT id, team_id
        FROM saisons
        WHERE away = TRUE
    LOOP
        RAISE NOTICE 'Processing season ID: %', saison_record.id;

        -- Trouver le propriétaire de l'équipe
        SELECT * INTO owner_record
        FROM user_teams
        WHERE team_id = saison_record.team_id
        AND role = 'owner'
        LIMIT 1;

        IF owner_record.id IS NOT NULL THEN
            RAISE NOTICE 'Found team owner ID: %', owner_record.id;

            -- Rechercher les utilisateurs avec "away" = FALSE et calculer les sommes négatives du mois précédent
            FOR user_team_present IN
                SELECT id
                FROM user_teams
                WHERE team_id = saison_record.team_id
                AND away = FALSE
            LOOP
                DECLARE
                    sum_negatives DECIMAL;
                BEGIN
                    SELECT COALESCE(SUM(transaction_value), 0) INTO sum_negatives
                    FROM transactions
                    WHERE transaction_to = user_team_present.id
                    AND saison_id = saison_record.id
                    AND statut = '1'
                    AND transaction_value < 0
                    AND transaction_date >= date_trunc('month', CURRENT_DATE - INTERVAL '1 month')
                    AND transaction_date < date_trunc('month', CURRENT_DATE);
                    
                    -- Ajouter la somme négative au tableau
                    negative_sums := array_append(negative_sums, sum_negatives);
                END;
            END LOOP;

            -- Si aucune somme négative trouvée, passer à la saison suivante
            IF array_length(negative_sums, 1) IS NULL THEN
                RAISE NOTICE 'No negative sums found for season ID: %', saison_record.id;
                CONTINUE;
            END IF;

            -- Calculer la médiane des sommes négatives en utilisant une requête latérale
            SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY val)
            INTO median_negative_sum
            FROM unnest(negative_sums) AS val;

            RAISE NOTICE 'Median negative sum calculated: %', median_negative_sum;

            -- Rechercher la pénalité "away"
            SELECT * INTO penalite_record
            FROM penalties
            WHERE saison_id = saison_record.id
            AND penalitie_custom = 'away'
            LIMIT 1;

            IF penalite_record.id IS NOT NULL THEN
                -- Créer une transaction pour chaque utilisateur absent (away = TRUE)
                FOR user_team_absent IN
                    SELECT id
                    FROM user_teams
                    WHERE team_id = saison_record.team_id
                    AND away = TRUE
                LOOP
                    INSERT INTO transactions (
                        transaction_value,
                        transaction_to,
                        penalitie_id,
                        saison_id,
                        created_by,
                        created_time,
                        transaction_date,
                        statut
                    ) VALUES (
                        median_negative_sum, -- Valeur de la médiane négative
                        user_team_absent.id, -- ID de l'utilisateur absent
                        penalite_record.id, -- ID de la pénalité
                        saison_record.id, -- ID de la saison
                        owner_record.id, -- ID du propriétaire de l'équipe
                        NOW(), -- Date de création
                        NOW() - INTERVAL '1 day', -- Date de la transaction (veille)
                        1 -- Statut par défaut (ex: 1 pour validé)
                    );
                    RAISE NOTICE 'Transaction created for absent user team ID: %', user_team_absent.id;
                END LOOP;
            ELSE
                RAISE NOTICE 'No penalty found for season ID: %', saison_record.id;
            END IF;
        ELSE
            RAISE NOTICE 'No owner found for team ID: %', saison_record.team_id;
        END IF;

        -- Réinitialiser le tableau des sommes négatives pour la saison suivante
        negative_sums := '{}';
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."apply_away_penalties"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."apply_blacktax_penalties"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    current_day INTEGER := EXTRACT(DAY FROM CURRENT_DATE);
    saison_record RECORD;
    penalite_record RECORD;
    user_team_record RECORD;
    owner_record RECORD;
    transaction_count INTEGER := 0;  -- Compteur de transactions créées
BEGIN
    -- Parcourir toutes les saisons actives avec la colonne blacktax égale au jour actuel
    FOR saison_record IN
        SELECT *
        FROM saisons
        WHERE active = TRUE
        AND blacktax = current_day
    LOOP
        RAISE NOTICE 'Processing season ID: %', saison_record.id;

        -- Rechercher la pénalité avec penalitie_custom = 'blacktax'
        SELECT * INTO penalite_record
        FROM penalties
        WHERE saison_id = saison_record.id
        AND penalitie_custom = 'blacktax'
        LIMIT 1;

        IF penalite_record.id IS NOT NULL THEN
            RAISE NOTICE 'Found penalty ID: %', penalite_record.id;

            -- Trouver le propriétaire de l'équipe
            SELECT * INTO owner_record
            FROM user_teams
            WHERE team_id = saison_record.team_id
            AND role = 'owner'
            LIMIT 1;

            IF owner_record.id IS NOT NULL THEN
                RAISE NOTICE 'Found team owner ID: %', owner_record.id;

                -- Parcourir tous les utilisateurs de l'équipe avec blacktax = TRUE
                FOR user_team_record IN
                    SELECT *
                    FROM user_teams
                    WHERE team_id = saison_record.team_id
                    AND blacktax = TRUE
                LOOP
                    RAISE NOTICE 'Processing user team ID: %', user_team_record.id;

                    -- Créer une transaction pour chaque utilisateur
                    INSERT INTO transactions (
                        transaction_value,
                        transaction_to,
                        penalitie_id,
                        saison_id,
                        created_by,
                        created_time,
                        transaction_date,
                        statut
                    ) VALUES (
                        penalite_record.penalitie_value, -- Valeur de la pénalité
                        user_team_record.id, -- ID de l'utilisateur dans user_teams
                        penalite_record.id, -- ID de la pénalité
                        saison_record.id, -- ID de la saison
                        owner_record.id, -- ID du propriétaire de l'équipe
                        NOW(), -- Date de création
                        NOW() - INTERVAL '1 day', -- Date de la transaction (veille)
                        1 -- Statut par défaut (ex: 1 pour validé)
                    );
                    -- Incrémenter le compteur de transactions
                    transaction_count := transaction_count + 1;
                    RAISE NOTICE 'Transaction created for user team ID: %', user_team_record.id;
                END LOOP;
            ELSE
                RAISE NOTICE 'No owner found for team ID: %', saison_record.team_id;
            END IF;
        ELSE
            RAISE NOTICE 'No penalty found for season ID: %', saison_record.id;
        END IF;
    END LOOP;

    -- Afficher un message de succès ou d'absence de création
    IF transaction_count > 0 THEN
        RAISE NOTICE 'Success: % transactions were created.', transaction_count;
    ELSE
        RAISE NOTICE 'No transactions were created.';
    END IF;
END;
$$;


ALTER FUNCTION "public"."apply_blacktax_penalties"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."apply_eco_penalties"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    current_day INTEGER := EXTRACT(DAY FROM CURRENT_DATE);
    saison_record RECORD;
    penalite_record RECORD;
    user_team_record RECORD;
    owner_record RECORD;
    transaction_count INTEGER := 0;  -- Compteur de transactions créées
BEGIN
    -- Parcourir toutes les saisons actives avec la colonne eco égale au jour actuel
    FOR saison_record IN
        SELECT *
        FROM saisons
        WHERE active = TRUE
        AND eco = current_day
    LOOP
        RAISE NOTICE 'Processing season ID: %', saison_record.id;

        -- Rechercher la pénalité avec penalitie_custom = 'eco'
        SELECT * INTO penalite_record
        FROM penalties
        WHERE saison_id = saison_record.id
        AND penalitie_custom = 'eco'
        LIMIT 1;

        IF penalite_record.id IS NOT NULL THEN
            RAISE NOTICE 'Found penalty ID: %', penalite_record.id;

            -- Trouver le propriétaire de l'équipe
            SELECT * INTO owner_record
            FROM user_teams
            WHERE team_id = saison_record.team_id
            AND role = 'owner'
            LIMIT 1;

            IF owner_record.id IS NOT NULL THEN
                RAISE NOTICE 'Found team owner ID: %', owner_record.id;

                -- Parcourir tous les utilisateurs de l'équipe avec eco = TRUE
                FOR user_team_record IN
                    SELECT *
                    FROM user_teams
                    WHERE team_id = saison_record.team_id
                    AND eco = TRUE
                LOOP
                    RAISE NOTICE 'Processing user team ID: %', user_team_record.id;

                    -- Créer une transaction pour chaque utilisateur
                    INSERT INTO transactions (
                        transaction_value,
                        transaction_to,
                        penalitie_id,
                        saison_id,
                        created_by,
                        created_time,
                        transaction_date,
                        statut
                    ) VALUES (
                        penalite_record.penalitie_value, -- Valeur de la pénalité
                        user_team_record.id, -- ID de l'utilisateur dans user_teams
                        penalite_record.id, -- ID de la pénalité
                        saison_record.id, -- ID de la saison
                        owner_record.id, -- ID du propriétaire de l'équipe
                        NOW(), -- Date de création
                        NOW() - INTERVAL '1 day', -- Date de la transaction (veille)
                        1 -- Statut par défaut (ex: 1 pour validé)
                    );
                    -- Incrémenter le compteur de transactions
                    transaction_count := transaction_count + 1;
                    RAISE NOTICE 'Transaction created for user team ID: %', user_team_record.id;
                END LOOP;
            ELSE
                RAISE NOTICE 'No owner found for team ID: %', saison_record.team_id;
            END IF;
        ELSE
            RAISE NOTICE 'No penalty found for season ID: %', saison_record.id;
        END IF;
    END LOOP;

    -- Afficher un message de succès ou d'absence de création
    IF transaction_count > 0 THEN
        RAISE NOTICE 'Success: % transactions were created.', transaction_count;
    ELSE
        RAISE NOTICE 'No transactions were created.';
    END IF;
END;
$$;


ALTER FUNCTION "public"."apply_eco_penalties"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."apply_fees_penalties"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$DECLARE
    saison_record RECORD;
    penalite_record RECORD;
    user_team_record RECORD;
    owner_record RECORD;
    negative_sum DECIMAL;
    difference DECIMAL;
BEGIN
    -- Parcourir toutes les saisons où "fees" est TRUE
    FOR saison_record IN
        SELECT id, team_id
        FROM saisons
        WHERE fees = TRUE
    LOOP
        RAISE NOTICE 'Processing season ID: %', saison_record.id;

        -- Trouver le propriétaire de l'équipe
        SELECT * INTO owner_record
        FROM user_teams
        WHERE team_id = saison_record.team_id
        AND role = 'owner'
        LIMIT 1;

        IF owner_record.id IS NOT NULL THEN
            RAISE NOTICE 'Found team owner ID: %', owner_record.id;

            -- Rechercher la pénalité "fees"
            SELECT * INTO penalite_record
            FROM penalties
            WHERE saison_id = saison_record.id
            AND penalitie_custom = 'fees'
            LIMIT 1;

            IF penalite_record.id IS NOT NULL THEN
                RAISE NOTICE 'Found penalty with value: %', penalite_record.penalitie_value;

                -- Parcourir tous les utilisateurs de l'équipe
                FOR user_team_record IN
                    SELECT id
                    FROM user_teams
                    WHERE team_id = saison_record.team_id
                LOOP
                    -- Calculer la somme des transactions négatives du mois passé
                    -- Ignorer les transactions avec penalitie_custom = 'eco' ou 'blacktax'
                    SELECT COALESCE(SUM(transaction_value), 0) INTO negative_sum
                    FROM transactions
                    WHERE transaction_to = user_team_record.id
                    AND saison_id = saison_record.id
                    AND statut = '1'
                    AND transaction_value < 0
                    AND transaction_date >= date_trunc('month', CURRENT_DATE - INTERVAL '1 month')
                    AND transaction_date < date_trunc('month', CURRENT_DATE)
                    AND penalitie_id NOT IN (
                        SELECT id FROM penalties
                        WHERE saison_id = saison_record.id
                        AND penalitie_custom IN ('eco', 'blacktax')
                    );

                    RAISE NOTICE 'Calculated negative sum for user team ID %: %', user_team_record.id, negative_sum;

                    -- Vérifier si la somme est supérieure à penalitie_value
                    IF negative_sum > penalite_record.penalitie_value THEN
                        -- Calculer la différence nécessaire pour atteindre penalitie_value
                        difference := penalite_record.penalitie_value - negative_sum;

                        RAISE NOTICE 'Difference to be penalized for user team ID %: %', user_team_record.id, difference;

                        -- Créer une transaction pour la différence calculée
                        INSERT INTO transactions (
                            transaction_value,
                            transaction_to,
                            penalitie_id,
                            saison_id,
                            created_by,
                            created_time,
                            transaction_date,
                            statut
                        ) VALUES (
                            difference, -- Valeur de la différence (négative)
                            user_team_record.id, -- ID de l'utilisateur
                            penalite_record.id, -- ID de la pénalité
                            saison_record.id, -- ID de la saison
                            owner_record.id, -- ID du propriétaire de l'équipe
                            NOW(), -- Date de création
                            date_trunc('month', CURRENT_DATE) - INTERVAL '1 day', -- Date de la transaction (dernier jour du mois précédent)
                            1 -- Statut par défaut (ex: 1 pour validé)
                        );

                        RAISE NOTICE 'Transaction created for user team ID: %', user_team_record.id;
                    END IF;
                END LOOP;
            ELSE
                RAISE NOTICE 'No penalty found for season ID: %', saison_record.id;
            END IF;
        ELSE
            RAISE NOTICE 'No owner found for team ID: %', saison_record.team_id;
        END IF;
    END LOOP;
END;$$;


ALTER FUNCTION "public"."apply_fees_penalties"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_user_sold"("season_uid" "uuid", "user_uid" "text" DEFAULT NULL::"text", "statut_param" integer DEFAULT 1, "sort_order" "text" DEFAULT 'ASC'::"text") RETURNS TABLE("user_id" "uuid", "user_name" "text", "user_img" "text", "positive_sum" numeric, "negative_sum" numeric, "total_sum" numeric, "positive_sum_exclude_thismonth" numeric, "negative_sum_exclude_thismonth" numeric, "total_sum_exclude_thismonth" numeric, "total_due_sum" numeric, "team_id" "uuid", "team_name" "text", "team_img" "text", "team_goal" "text")
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
    current_month_start DATE := date_trunc('month', current_date);
    user_uid_uuid UUID;
    team_id_val UUID;
    team_name_val TEXT;
    team_img_val TEXT;
    team_goal_val TEXT;
    owner_id UUID;
    owner_name TEXT;
    owner_img TEXT;
    sort_clause TEXT;
BEGIN
    -- Vérifier et définir l'ordre de tri
    IF upper(sort_order) NOT IN ('ASC', 'DESC') THEN
        RAISE EXCEPTION 'Invalid sort order. Use ASC or DESC.';
    END IF;
    sort_clause := format(' ORDER BY user_name %s', sort_order);

    -- Convertir user_uid en UUID s'il n'est pas vide, sinon le définir sur NULL
    user_uid_uuid := CASE 
        WHEN user_uid = '' OR user_uid IS NULL THEN NULL 
        WHEN user_uid = 'allteam' THEN NULL
        ELSE user_uid::UUID 
    END;

    -- Récupérer les détails de l'équipe
    SELECT t.id, t.team_name, t.team_img, s.goal
    INTO team_id_val, team_name_val, team_img_val, team_goal_val
    FROM teams t
    JOIN saisons s ON t.id = s.team_id
    WHERE s.id = season_uid;

    -- Récupérer les détails du propriétaire
    IF user_uid = 'allteam' THEN
        SELECT ut.id, ut.display_name, ut.display_img
        INTO owner_id, owner_name, owner_img
        FROM user_teams ut
        WHERE ut.team_id = team_id_val AND ut.role = 'owner'
        LIMIT 1;

        RETURN QUERY EXECUTE format('
        SELECT
            $1::UUID AS user_id,
            $2::TEXT AS user_name,
            $3::TEXT AS user_img,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_value > 0 
                THEN t.transaction_value::NUMERIC 
                ELSE 0 
            END), 0)::NUMERIC, 2) AS positive_sum,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_value < 0 
                THEN t.transaction_value::NUMERIC
                ELSE 0 
            END), 0)::NUMERIC, 2) AS negative_sum,
            ROUND(COALESCE(SUM(t.transaction_value), 0)::NUMERIC, 2) AS total_sum,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_value > 0 AND t.transaction_date < $4 
                THEN t.transaction_value::NUMERIC 
                ELSE 0 
            END), 0)::NUMERIC, 2) AS positive_sum_exclude_thismonth,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_value < 0 AND t.transaction_date < $4 
                THEN t.transaction_value::NUMERIC
                ELSE 0 
            END), 0)::NUMERIC, 2) AS negative_sum_exclude_thismonth,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_date < $4 
                THEN t.transaction_value::NUMERIC
                ELSE 0 
            END), 0)::NUMERIC, 2) AS total_sum_exclude_thismonth,
            ROUND((COALESCE(SUM(CASE 
                WHEN t.transaction_value > 0 
                THEN t.transaction_value::NUMERIC 
                ELSE 0 
            END), 0) 
            + COALESCE(SUM(CASE 
                WHEN t.transaction_value < 0 AND t.transaction_date < $4 
                THEN t.transaction_value::NUMERIC
                ELSE 0 
            END), 0))::NUMERIC, 2) AS total_due_sum,
            $5::UUID AS team_id,
            $6::TEXT AS team_name,
            $7::TEXT AS team_img,
            $8::TEXT AS team_goal
        FROM
            transactions t
        WHERE
            t.saison_id = $9
            AND ($10 = 2 OR t.statut = 1)
        %s', sort_clause)
        USING 
            owner_id, owner_name, owner_img, current_month_start,
            team_id_val, team_name_val, team_img_val, team_goal_val,
            season_uid, statut_param;
    ELSE
        RETURN QUERY EXECUTE format('
        SELECT
            ut.id AS user_id,
            ut.display_name AS user_name,
            ut.display_img AS user_img,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_value > 0 
                THEN t.transaction_value::NUMERIC 
                ELSE 0 
            END), 0)::NUMERIC, 2) AS positive_sum,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_value < 0 
                THEN t.transaction_value::NUMERIC
                ELSE 0 
            END), 0)::NUMERIC, 2) AS negative_sum,
            ROUND(COALESCE(SUM(t.transaction_value), 0)::NUMERIC, 2) AS total_sum,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_value > 0 AND t.transaction_date < $1 
                THEN t.transaction_value::NUMERIC 
                ELSE 0 
            END), 0)::NUMERIC, 2) AS positive_sum_exclude_thismonth,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_value < 0 AND t.transaction_date < $1 
                THEN t.transaction_value::NUMERIC
                ELSE 0 
            END), 0)::NUMERIC, 2) AS negative_sum_exclude_thismonth,
            ROUND(COALESCE(SUM(CASE 
                WHEN t.transaction_date < $1 
                THEN t.transaction_value::NUMERIC
                ELSE 0 
            END), 0)::NUMERIC, 2) AS total_sum_exclude_thismonth,
            ROUND((COALESCE(SUM(CASE 
                WHEN t.transaction_value > 0 
                THEN t.transaction_value::NUMERIC 
                ELSE 0 
            END), 0) 
            + COALESCE(SUM(CASE 
                WHEN t.transaction_value < 0 AND t.transaction_date < $1 
                THEN t.transaction_value::NUMERIC
                ELSE 0 
            END), 0))::NUMERIC, 2) AS total_due_sum,
            $2::UUID AS team_id,
            $3::TEXT AS team_name,
            $4::TEXT AS team_img,
            $5::TEXT AS team_goal
        FROM
            user_teams ut
        LEFT JOIN
            transactions t ON t.transaction_to = ut.id 
            AND t.saison_id = $6
            AND ($7 = 2 OR t.statut = 1)
        WHERE
            ut.team_id = $2
            AND ($8::UUID IS NULL OR ut.id = $8::UUID)
        GROUP BY
            ut.id, ut.display_name, ut.display_img
        %s', sort_clause)
        USING 
            current_month_start, team_id_val, team_name_val, team_img_val, team_goal_val,
            season_uid, statut_param, user_uid_uuid;
    END IF;
END;
$_$;


ALTER FUNCTION "public"."calculate_user_sold"("season_uid" "uuid", "user_uid" "text", "statut_param" integer, "sort_order" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_usertable_for_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$BEGIN
  INSERT INTO public.users(id, email_address)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;$$;


ALTER FUNCTION "public"."create_usertable_for_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."execute_agio_on_last_day"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF (EXTRACT(DAY FROM (CURRENT_DATE + INTERVAL '1 day'))) = 1 THEN
        -- Exécuter uniquement si demain est le premier jour du mois suivant
        PERFORM apply_agio_penalties();
    END IF;
END;
$$;


ALTER FUNCTION "public"."execute_agio_on_last_day"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_unique_id"() RETURNS character varying
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN LEFT(md5(random()::text), 8);
END;
$$;


ALTER FUNCTION "public"."generate_unique_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_active_months"("p_saison_id" "uuid", "p_user_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("active_month" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        date_trunc('month', t.transaction_date) AS active_month
    FROM
        transactions t
    WHERE
        t.saison_id = p_saison_id
        AND (p_user_id IS NULL OR t.created_by = p_user_id OR t.transaction_to = p_user_id)
    ORDER BY
        active_month DESC;  -- Trie les mois du plus récent au plus ancien
END;
$$;


ALTER FUNCTION "public"."get_active_months"("p_saison_id" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_season_transactions"("p_saison_id" "uuid", "p_user_id" "text" DEFAULT NULL::"text") RETURNS TABLE("transaction_id" "uuid", "transaction_date" timestamp with time zone, "transaction_value" numeric, "note" "text", "created_time" timestamp with time zone, "created_by" "uuid", "created_by_name" "text", "transaction_to" "uuid", "transaction_to_name" "text", "penalitie_name" "text", "saison_id" "uuid", "statut" numeric)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Convertir une chaîne vide en NULL et s'assurer que p_user_id est bien un UUID
    IF p_user_id IS NULL OR p_user_id = '' THEN
        p_user_id := NULL;
    ELSE
        BEGIN
            -- Tentative de conversion en UUID, lever une exception si non valide
            p_user_id := p_user_id::UUID;
        EXCEPTION WHEN others THEN
            RAISE EXCEPTION 'Invalid UUID format for p_user_id: "%".', p_user_id;
        END;
    END IF;

    RETURN QUERY
    SELECT
        t.id AS transaction_id,
        t.transaction_date,
        t.transaction_value,
        t.note,
        t.created_time,
        t.created_by,
        ut1.display_name AS created_by_name,
        t.transaction_to,
        ut2.display_name AS transaction_to_name,
        p.penalitie_name::TEXT,
        t.saison_id,
        t.statut
    FROM
        transactions t
    LEFT JOIN
        penalties p ON t.penalitie_id = p.id
    LEFT JOIN
        user_teams ut1 ON t.created_by = ut1.id
    LEFT JOIN
        user_teams ut2 ON t.transaction_to = ut2.id
    WHERE
        t.saison_id = p_saison_id
        AND (p_user_id IS NULL OR t.created_by = p_user_id::UUID OR t.transaction_to = p_user_id::UUID)
    ORDER BY
        t.transaction_date DESC;
END;
$$;


ALTER FUNCTION "public"."get_season_transactions"("p_saison_id" "uuid", "p_user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_transactions_grouped_by_day"("season_uid" "uuid") RETURNS TABLE("transaction_day" "date", "transactions" numeric[], "users" "uuid"[], "statuts" "text"[])
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        date_trunc('day', transaction_date)::DATE AS transaction_day,
        ARRAY_AGG(transaction_value) AS transactions,
        ARRAY_AGG(transaction_to) AS users,
        ARRAY_AGG(statut::TEXT) AS statuts
    FROM 
        transactions
    WHERE 
        saison_id = season_uid
    GROUP BY 
        transaction_day
    ORDER BY 
        transaction_day ASC;
END;
$$;


ALTER FUNCTION "public"."get_transactions_grouped_by_day"("season_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user_team"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_saison_id UUID;
    owner_id UUID;
    penalitie_id UUID;
    penalitie_value DECIMAL;
BEGIN
    -- Récupérer l'ID de la saison actuelle à partir de la table "teams"
    SELECT t.current_saison INTO current_saison_id
    FROM teams t
    WHERE t.id = NEW.team_id;

    -- Vérifier si la saison est ouverte (colonne "opening" = true)
    IF EXISTS (
        SELECT 1
        FROM saisons s
        WHERE s.id = current_saison_id AND s.opening = true
    ) THEN
        -- Récupérer les informations de la pénalité d'ouverture
        SELECT p.id, p.penalitie_value INTO penalitie_id, penalitie_value
        FROM penalties p
        WHERE p.saison_id = current_saison_id AND p.penalitie_custom = 'opening'
        LIMIT 1;

        -- Récupérer l'ID du owner de l'équipe
        SELECT ut.id INTO owner_id
        FROM user_teams ut
        WHERE ut.team_id = NEW.team_id AND ut.role = 'owner'
        LIMIT 1;

        -- Insérer une nouvelle transaction
        INSERT INTO transactions (
            transaction_value,
            created_by,
            transaction_to,
            penalitie_id,
            saison_id
        ) VALUES (
            penalitie_value,
            owner_id,
            NEW.id,
            penalitie_id,
            current_saison_id
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user_team"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."setAdminTeam"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$begin
insert into public.user_teams(user_id, team_id,role)
values(new.team_owner, new.id, 'owner');
return new;
end;$$;


ALTER FUNCTION "public"."setAdminTeam"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_transaction_details"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
    -- Mettre à jour transaction_to_name à partir de user_teams
    IF NEW.transaction_to IS NOT NULL THEN
        SELECT display_name INTO NEW.transaction_to_name
        FROM user_teams
        WHERE id = NEW.transaction_to;
    ELSE
        NEW.transaction_to_name := NULL;
    END IF;

    -- Mettre à jour transaction_name et transaction_img à partir de penalties
    IF NEW.penalitie_id IS NOT NULL THEN
        SELECT penalitie_name, penalitie_img INTO NEW.transaction_name, NEW.transaction_img
        FROM penalties
        WHERE id = NEW.penalitie_id;
    ELSE
        NEW.transaction_name := NULL;
        NEW.transaction_img := NULL;
    END IF;

    -- Mettre à jour created_by_name à partir de user_teams
    IF NEW.created_by IS NOT NULL THEN
        SELECT display_name INTO NEW.created_by_name
        FROM user_teams
        WHERE id = NEW.created_by;
    ELSE
        NEW.created_by_name := NULL;
    END IF;

    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."set_transaction_details"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_created_by_name"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    UPDATE transactions
    SET created_by_name = NEW.display_name
    WHERE created_by = NEW.id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_created_by_name"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_created_by_name_on_change"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
    -- Vérifiez si la mise à jour est nécessaire pour éviter la récursion
    IF NEW.created_by_name IS DISTINCT FROM (
        SELECT display_name FROM user_teams WHERE id = NEW.created_by
    ) THEN
        UPDATE transactions
        SET created_by_name = (
            SELECT display_name FROM user_teams WHERE id = NEW.created_by
        )
        WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."update_created_by_name_on_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_transaction_name_and_img"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    UPDATE transactions
    SET 
        transaction_name = NEW.penalitie_name,
        transaction_img = NEW.penalitie_img
    WHERE penalitie_id = NEW.id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_transaction_name_and_img"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_transaction_name_and_img_on_change"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    UPDATE transactions
    SET 
        transaction_name = (
            SELECT penalitie_name FROM penalties WHERE id = NEW.penalitie_id
        ),
        transaction_img = (
            SELECT penalitie_img FROM penalties WHERE id = NEW.penalitie_id
        )
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_transaction_name_and_img_on_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_transaction_to_name"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    UPDATE transactions
    SET transaction_to_name = NEW.display_name
    WHERE transaction_to = NEW.id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_transaction_to_name"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_transaction_to_name_on_change"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    UPDATE transactions
    SET transaction_to_name = (
        SELECT display_name FROM user_teams WHERE id = NEW.transaction_to
    )
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_transaction_to_name_on_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "storage"."add_prefixes"("_bucket_id" "text", "_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION "storage"."add_prefixes"("_bucket_id" "text", "_name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."delete_leaf_prefixes"("bucket_ids" "text"[], "names" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION "storage"."delete_leaf_prefixes"("bucket_ids" "text"[], "names" "text"[]) OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."delete_prefix"("_bucket_id" "text", "_name" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION "storage"."delete_prefix"("_bucket_id" "text", "_name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."delete_prefix_hierarchy_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION "storage"."delete_prefix_hierarchy_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."enforce_bucket_name_length"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION "storage"."enforce_bucket_name_length"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."extension"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION "storage"."extension"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."filename"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION "storage"."filename"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."foldername"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION "storage"."foldername"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."get_level"("name" "text") RETURNS integer
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION "storage"."get_level"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."get_prefix"("name" "text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION "storage"."get_prefix"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."get_prefixes"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql" IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION "storage"."get_prefixes"("name" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."get_size_by_bucket"() RETURNS TABLE("size" bigint, "bucket_id" "text")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION "storage"."get_size_by_bucket"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "next_key_token" "text" DEFAULT ''::"text", "next_upload_token" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "id" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "next_key_token" "text", "next_upload_token" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "start_after" "text" DEFAULT ''::"text", "next_token" "text" DEFAULT ''::"text") RETURNS TABLE("name" "text", "id" "uuid", "metadata" "jsonb", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "start_after" "text", "next_token" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."lock_top_prefixes"("bucket_ids" "text"[], "names" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION "storage"."lock_top_prefixes"("bucket_ids" "text"[], "names" "text"[]) OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_delete_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."objects_delete_cleanup"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_insert_prefix_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_insert_prefix_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_update_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."objects_update_cleanup"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_update_level_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_update_level_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."objects_update_prefix_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."objects_update_prefix_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."operation"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION "storage"."operation"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."prefixes_delete_cleanup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION "storage"."prefixes_delete_cleanup"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."prefixes_insert_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION "storage"."prefixes_insert_trigger"() OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql"
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."search_legacy_v1"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION "storage"."search_legacy_v1"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."search_v1_optimised"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION "storage"."search_v1_optimised"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."search_v2"("prefix" "text", "bucket_name" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "start_after" "text" DEFAULT ''::"text", "sort_order" "text" DEFAULT 'asc'::"text", "sort_column" "text" DEFAULT 'name'::"text", "sort_column_after" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION "storage"."search_v2"("prefix" "text", "bucket_name" "text", "limits" integer, "levels" integer, "start_after" "text", "sort_order" "text", "sort_column" "text", "sort_column_after" "text") OWNER TO "supabase_storage_admin";


CREATE OR REPLACE FUNCTION "storage"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION "storage"."update_updated_at_column"() OWNER TO "supabase_storage_admin";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "auth"."audit_log_entries" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "payload" "json",
    "created_at" timestamp with time zone,
    "ip_address" character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE "auth"."audit_log_entries" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."audit_log_entries" IS 'Auth: Audit trail for user actions.';



CREATE TABLE IF NOT EXISTS "auth"."flow_state" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid",
    "auth_code" "text" NOT NULL,
    "code_challenge_method" "auth"."code_challenge_method" NOT NULL,
    "code_challenge" "text" NOT NULL,
    "provider_type" "text" NOT NULL,
    "provider_access_token" "text",
    "provider_refresh_token" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "authentication_method" "text" NOT NULL,
    "auth_code_issued_at" timestamp with time zone
);


ALTER TABLE "auth"."flow_state" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."flow_state" IS 'stores metadata for pkce logins';



CREATE TABLE IF NOT EXISTS "auth"."identities" (
    "provider_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "identity_data" "jsonb" NOT NULL,
    "provider" "text" NOT NULL,
    "last_sign_in_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "email" "text" GENERATED ALWAYS AS ("lower"(("identity_data" ->> 'email'::"text"))) STORED,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "auth"."identities" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."identities" IS 'Auth: Stores identities associated to a user.';



COMMENT ON COLUMN "auth"."identities"."email" IS 'Auth: Email is a generated column that references the optional email property in the identity_data';



CREATE TABLE IF NOT EXISTS "auth"."instances" (
    "id" "uuid" NOT NULL,
    "uuid" "uuid",
    "raw_base_config" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "auth"."instances" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."instances" IS 'Auth: Manages users across multiple sites.';



CREATE TABLE IF NOT EXISTS "auth"."mfa_amr_claims" (
    "session_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "authentication_method" "text" NOT NULL,
    "id" "uuid" NOT NULL
);


ALTER TABLE "auth"."mfa_amr_claims" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."mfa_amr_claims" IS 'auth: stores authenticator method reference claims for multi factor authentication';



CREATE TABLE IF NOT EXISTS "auth"."mfa_challenges" (
    "id" "uuid" NOT NULL,
    "factor_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "verified_at" timestamp with time zone,
    "ip_address" "inet" NOT NULL,
    "otp_code" "text",
    "web_authn_session_data" "jsonb"
);


ALTER TABLE "auth"."mfa_challenges" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."mfa_challenges" IS 'auth: stores metadata about challenge requests made';



CREATE TABLE IF NOT EXISTS "auth"."mfa_factors" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "friendly_name" "text",
    "factor_type" "auth"."factor_type" NOT NULL,
    "status" "auth"."factor_status" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "secret" "text",
    "phone" "text",
    "last_challenged_at" timestamp with time zone,
    "web_authn_credential" "jsonb",
    "web_authn_aaguid" "uuid"
);


ALTER TABLE "auth"."mfa_factors" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."mfa_factors" IS 'auth: stores metadata about factors';



CREATE TABLE IF NOT EXISTS "auth"."oauth_clients" (
    "id" "uuid" NOT NULL,
    "client_id" "text" NOT NULL,
    "client_secret_hash" "text" NOT NULL,
    "registration_type" "auth"."oauth_registration_type" NOT NULL,
    "redirect_uris" "text" NOT NULL,
    "grant_types" "text" NOT NULL,
    "client_name" "text",
    "client_uri" "text",
    "logo_uri" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "deleted_at" timestamp with time zone,
    CONSTRAINT "oauth_clients_client_name_length" CHECK (("char_length"("client_name") <= 1024)),
    CONSTRAINT "oauth_clients_client_uri_length" CHECK (("char_length"("client_uri") <= 2048)),
    CONSTRAINT "oauth_clients_logo_uri_length" CHECK (("char_length"("logo_uri") <= 2048))
);


ALTER TABLE "auth"."oauth_clients" OWNER TO "supabase_auth_admin";


CREATE TABLE IF NOT EXISTS "auth"."one_time_tokens" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token_type" "auth"."one_time_token_type" NOT NULL,
    "token_hash" "text" NOT NULL,
    "relates_to" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "one_time_tokens_token_hash_check" CHECK (("char_length"("token_hash") > 0))
);


ALTER TABLE "auth"."one_time_tokens" OWNER TO "supabase_auth_admin";


CREATE TABLE IF NOT EXISTS "auth"."refresh_tokens" (
    "instance_id" "uuid",
    "id" bigint NOT NULL,
    "token" character varying(255),
    "user_id" character varying(255),
    "revoked" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "parent" character varying(255),
    "session_id" "uuid"
);


ALTER TABLE "auth"."refresh_tokens" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."refresh_tokens" IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';



CREATE SEQUENCE IF NOT EXISTS "auth"."refresh_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "auth"."refresh_tokens_id_seq" OWNER TO "supabase_auth_admin";


ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNED BY "auth"."refresh_tokens"."id";



CREATE TABLE IF NOT EXISTS "auth"."saml_providers" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "entity_id" "text" NOT NULL,
    "metadata_xml" "text" NOT NULL,
    "metadata_url" "text",
    "attribute_mapping" "jsonb",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "name_id_format" "text",
    CONSTRAINT "entity_id not empty" CHECK (("char_length"("entity_id") > 0)),
    CONSTRAINT "metadata_url not empty" CHECK ((("metadata_url" = NULL::"text") OR ("char_length"("metadata_url") > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK (("char_length"("metadata_xml") > 0))
);


ALTER TABLE "auth"."saml_providers" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."saml_providers" IS 'Auth: Manages SAML Identity Provider connections.';



CREATE TABLE IF NOT EXISTS "auth"."saml_relay_states" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "request_id" "text" NOT NULL,
    "for_email" "text",
    "redirect_to" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "flow_state_id" "uuid",
    CONSTRAINT "request_id not empty" CHECK (("char_length"("request_id") > 0))
);


ALTER TABLE "auth"."saml_relay_states" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."saml_relay_states" IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';



CREATE TABLE IF NOT EXISTS "auth"."schema_migrations" (
    "version" character varying(255) NOT NULL
);


ALTER TABLE "auth"."schema_migrations" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."schema_migrations" IS 'Auth: Manages updates to the auth system.';



CREATE TABLE IF NOT EXISTS "auth"."sessions" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "factor_id" "uuid",
    "aal" "auth"."aal_level",
    "not_after" timestamp with time zone,
    "refreshed_at" timestamp without time zone,
    "user_agent" "text",
    "ip" "inet",
    "tag" "text"
);


ALTER TABLE "auth"."sessions" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."sessions" IS 'Auth: Stores session data associated to a user.';



COMMENT ON COLUMN "auth"."sessions"."not_after" IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';



CREATE TABLE IF NOT EXISTS "auth"."sso_domains" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "domain" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK (("char_length"("domain") > 0))
);


ALTER TABLE "auth"."sso_domains" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."sso_domains" IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';



CREATE TABLE IF NOT EXISTS "auth"."sso_providers" (
    "id" "uuid" NOT NULL,
    "resource_id" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "disabled" boolean,
    CONSTRAINT "resource_id not empty" CHECK ((("resource_id" = NULL::"text") OR ("char_length"("resource_id") > 0)))
);


ALTER TABLE "auth"."sso_providers" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."sso_providers" IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';



COMMENT ON COLUMN "auth"."sso_providers"."resource_id" IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';



CREATE TABLE IF NOT EXISTS "auth"."users" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" "jsonb",
    "raw_user_meta_data" "jsonb",
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" "text" DEFAULT NULL::character varying,
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" "text" DEFAULT ''::character varying,
    "phone_change_token" character varying(255) DEFAULT ''::character varying,
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST("email_confirmed_at", "phone_confirmed_at")) STORED,
    "email_change_token_current" character varying(255) DEFAULT ''::character varying,
    "email_change_confirm_status" smallint DEFAULT 0,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255) DEFAULT ''::character varying,
    "reauthentication_sent_at" timestamp with time zone,
    "is_sso_user" boolean DEFAULT false NOT NULL,
    "deleted_at" timestamp with time zone,
    "is_anonymous" boolean DEFAULT false NOT NULL,
    CONSTRAINT "users_email_change_confirm_status_check" CHECK ((("email_change_confirm_status" >= 0) AND ("email_change_confirm_status" <= 2)))
);


ALTER TABLE "auth"."users" OWNER TO "supabase_auth_admin";


COMMENT ON TABLE "auth"."users" IS 'Auth: Stores user login data within a secure schema.';



COMMENT ON COLUMN "auth"."users"."is_sso_user" IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';



CREATE TABLE IF NOT EXISTS "public"."penalties" (
    "penalitie_name" character varying(255) NOT NULL,
    "penalitie_value" numeric(10,2) NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "saison_id" "uuid",
    "penalitie_img" "text",
    "created_time" timestamp without time zone DEFAULT "now"(),
    "penalitie_custom" "text" DEFAULT 'default'::"text" NOT NULL
);


ALTER TABLE "public"."penalties" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."saisons" (
    "created_time" timestamp with time zone DEFAULT "now"() NOT NULL,
    "saison_name" character varying(255) NOT NULL,
    "goal" "text",
    "active" boolean DEFAULT true,
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "team_id" "uuid",
    "blacktax" numeric DEFAULT '0'::numeric NOT NULL,
    "eco" numeric DEFAULT '0'::numeric NOT NULL,
    "agio" boolean DEFAULT false NOT NULL,
    "agio_step1" numeric DEFAULT '0'::numeric NOT NULL,
    "agio_step2" numeric DEFAULT '0'::numeric NOT NULL,
    "agio_step3" numeric DEFAULT '0'::numeric NOT NULL,
    "away" boolean DEFAULT false NOT NULL,
    "fees" boolean DEFAULT false NOT NULL,
    "opening" boolean DEFAULT false
);


ALTER TABLE "public"."saisons" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."team_saisons" (
    "team_id" "uuid" NOT NULL,
    "saison_id" "uuid" NOT NULL
);


ALTER TABLE "public"."team_saisons" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."teams" (
    "created_time" timestamp with time zone DEFAULT "now"() NOT NULL,
    "team_code" character varying(255) DEFAULT "public"."generate_unique_id"() NOT NULL,
    "sport" character varying(255),
    "team_img" "text",
    "team_name" character varying(255) NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "current_saison" "uuid",
    "team_owner" "uuid"
);


ALTER TABLE "public"."teams" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "transaction_date" timestamp with time zone DEFAULT "now"() NOT NULL,
    "transaction_value" numeric(10,2) NOT NULL,
    "note" "text" DEFAULT ''::"text",
    "created_time" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "transaction_to" "uuid",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "penalitie_id" "uuid" NOT NULL,
    "saison_id" "uuid" NOT NULL,
    "statut" numeric DEFAULT '1'::numeric,
    "blackweek" boolean DEFAULT false,
    "gameday" boolean DEFAULT false,
    "blackpowered" boolean DEFAULT false,
    "steal" boolean DEFAULT false,
    "contest" boolean DEFAULT false,
    "transaction_to_name" "text",
    "transaction_name" "text",
    "transaction_img" "text",
    "date" timestamp with time zone DEFAULT "now"(),
    "transaction_amount" numeric DEFAULT '1'::numeric,
    "created_by_name" "text"
);


ALTER TABLE "public"."transactions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_teams" (
    "role" character varying(50) DEFAULT 'member'::character varying,
    "user_id" "uuid" NOT NULL,
    "team_id" "uuid" NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "display_name" "text",
    "display_img" "text",
    "eco" boolean DEFAULT true,
    "blacktax" boolean DEFAULT true,
    "agio" numeric DEFAULT '0'::numeric,
    "away" boolean DEFAULT false
);


ALTER TABLE "public"."user_teams" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "display_name" "text",
    "team_setup" "uuid",
    "email_address" "text",
    "level" numeric DEFAULT '1'::numeric NOT NULL,
    "user_setup" "uuid"
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "storage"."buckets" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "public" boolean DEFAULT false,
    "avif_autodetection" boolean DEFAULT false,
    "file_size_limit" bigint,
    "allowed_mime_types" "text"[],
    "owner_id" "text",
    "type" "storage"."buckettype" DEFAULT 'STANDARD'::"storage"."buckettype" NOT NULL
);


ALTER TABLE "storage"."buckets" OWNER TO "supabase_storage_admin";


COMMENT ON COLUMN "storage"."buckets"."owner" IS 'Field is deprecated, use owner_id instead';



CREATE TABLE IF NOT EXISTS "storage"."buckets_analytics" (
    "id" "text" NOT NULL,
    "type" "storage"."buckettype" DEFAULT 'ANALYTICS'::"storage"."buckettype" NOT NULL,
    "format" "text" DEFAULT 'ICEBERG'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "storage"."buckets_analytics" OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "storage"."migrations" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "hash" character varying(40) NOT NULL,
    "executed_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "storage"."migrations" OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "storage"."objects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bucket_id" "text",
    "name" "text",
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "last_accessed_at" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb",
    "path_tokens" "text"[] GENERATED ALWAYS AS ("string_to_array"("name", '/'::"text")) STORED,
    "version" "text",
    "owner_id" "text",
    "user_metadata" "jsonb",
    "level" integer
);


ALTER TABLE "storage"."objects" OWNER TO "supabase_storage_admin";


COMMENT ON COLUMN "storage"."objects"."owner" IS 'Field is deprecated, use owner_id instead';



CREATE TABLE IF NOT EXISTS "storage"."prefixes" (
    "bucket_id" "text" NOT NULL,
    "name" "text" NOT NULL COLLATE "pg_catalog"."C",
    "level" integer GENERATED ALWAYS AS ("storage"."get_level"("name")) STORED NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "storage"."prefixes" OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "storage"."s3_multipart_uploads" (
    "id" "text" NOT NULL,
    "in_progress_size" bigint DEFAULT 0 NOT NULL,
    "upload_signature" "text" NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "version" "text" NOT NULL,
    "owner_id" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_metadata" "jsonb"
);


ALTER TABLE "storage"."s3_multipart_uploads" OWNER TO "supabase_storage_admin";


CREATE TABLE IF NOT EXISTS "storage"."s3_multipart_uploads_parts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "upload_id" "text" NOT NULL,
    "size" bigint DEFAULT 0 NOT NULL,
    "part_number" integer NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "etag" "text" NOT NULL,
    "owner_id" "text",
    "version" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "storage"."s3_multipart_uploads_parts" OWNER TO "supabase_storage_admin";


ALTER TABLE ONLY "auth"."refresh_tokens" ALTER COLUMN "id" SET DEFAULT "nextval"('"auth"."refresh_tokens_id_seq"'::"regclass");



ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "amr_id_pk" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."audit_log_entries"
    ADD CONSTRAINT "audit_log_entries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."flow_state"
    ADD CONSTRAINT "flow_state_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_provider_id_provider_unique" UNIQUE ("provider_id", "provider");



ALTER TABLE ONLY "auth"."instances"
    ADD CONSTRAINT "instances_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_authentication_method_pkey" UNIQUE ("session_id", "authentication_method");



ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_last_challenged_at_key" UNIQUE ("last_challenged_at");



ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_client_id_key" UNIQUE ("client_id");



ALTER TABLE ONLY "auth"."oauth_clients"
    ADD CONSTRAINT "oauth_clients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_token_unique" UNIQUE ("token");



ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_entity_id_key" UNIQUE ("entity_id");



ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");



ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."sso_providers"
    ADD CONSTRAINT "sso_providers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");



ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."penalties"
    ADD CONSTRAINT "penalties_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."penalties"
    ADD CONSTRAINT "penalties_uid_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."saisons"
    ADD CONSTRAINT "saisons_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."saisons"
    ADD CONSTRAINT "saisons_uid_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."team_saisons"
    ADD CONSTRAINT "team_saisons_pkey" PRIMARY KEY ("team_id", "saison_id");



ALTER TABLE ONLY "public"."teams"
    ADD CONSTRAINT "teams_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."teams"
    ADD CONSTRAINT "teams_team_code_key" UNIQUE ("team_code");



ALTER TABLE ONLY "public"."teams"
    ADD CONSTRAINT "teams_uid_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_uid_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."user_teams"
    ADD CONSTRAINT "user_teams_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."buckets_analytics"
    ADD CONSTRAINT "buckets_analytics_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."buckets"
    ADD CONSTRAINT "buckets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_name_key" UNIQUE ("name");



ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_pkey" PRIMARY KEY ("bucket_id", "level", "name");



ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_pkey" PRIMARY KEY ("id");



CREATE INDEX "audit_logs_instance_id_idx" ON "auth"."audit_log_entries" USING "btree" ("instance_id");



CREATE UNIQUE INDEX "confirmation_token_idx" ON "auth"."users" USING "btree" ("confirmation_token") WHERE (("confirmation_token")::"text" !~ '^[0-9 ]*$'::"text");



CREATE UNIQUE INDEX "email_change_token_current_idx" ON "auth"."users" USING "btree" ("email_change_token_current") WHERE (("email_change_token_current")::"text" !~ '^[0-9 ]*$'::"text");



CREATE UNIQUE INDEX "email_change_token_new_idx" ON "auth"."users" USING "btree" ("email_change_token_new") WHERE (("email_change_token_new")::"text" !~ '^[0-9 ]*$'::"text");



CREATE INDEX "factor_id_created_at_idx" ON "auth"."mfa_factors" USING "btree" ("user_id", "created_at");



CREATE INDEX "flow_state_created_at_idx" ON "auth"."flow_state" USING "btree" ("created_at" DESC);



CREATE INDEX "identities_email_idx" ON "auth"."identities" USING "btree" ("email" "text_pattern_ops");



COMMENT ON INDEX "auth"."identities_email_idx" IS 'Auth: Ensures indexed queries on the email column';



CREATE INDEX "identities_user_id_idx" ON "auth"."identities" USING "btree" ("user_id");



CREATE INDEX "idx_auth_code" ON "auth"."flow_state" USING "btree" ("auth_code");



CREATE INDEX "idx_user_id_auth_method" ON "auth"."flow_state" USING "btree" ("user_id", "authentication_method");



CREATE INDEX "mfa_challenge_created_at_idx" ON "auth"."mfa_challenges" USING "btree" ("created_at" DESC);



CREATE UNIQUE INDEX "mfa_factors_user_friendly_name_unique" ON "auth"."mfa_factors" USING "btree" ("friendly_name", "user_id") WHERE (TRIM(BOTH FROM "friendly_name") <> ''::"text");



CREATE INDEX "mfa_factors_user_id_idx" ON "auth"."mfa_factors" USING "btree" ("user_id");



CREATE INDEX "oauth_clients_client_id_idx" ON "auth"."oauth_clients" USING "btree" ("client_id");



CREATE INDEX "oauth_clients_deleted_at_idx" ON "auth"."oauth_clients" USING "btree" ("deleted_at");



CREATE INDEX "one_time_tokens_relates_to_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("relates_to");



CREATE INDEX "one_time_tokens_token_hash_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("token_hash");



CREATE UNIQUE INDEX "one_time_tokens_user_id_token_type_key" ON "auth"."one_time_tokens" USING "btree" ("user_id", "token_type");



CREATE UNIQUE INDEX "reauthentication_token_idx" ON "auth"."users" USING "btree" ("reauthentication_token") WHERE (("reauthentication_token")::"text" !~ '^[0-9 ]*$'::"text");



CREATE UNIQUE INDEX "recovery_token_idx" ON "auth"."users" USING "btree" ("recovery_token") WHERE (("recovery_token")::"text" !~ '^[0-9 ]*$'::"text");



CREATE INDEX "refresh_tokens_instance_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id");



CREATE INDEX "refresh_tokens_instance_id_user_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id", "user_id");



CREATE INDEX "refresh_tokens_parent_idx" ON "auth"."refresh_tokens" USING "btree" ("parent");



CREATE INDEX "refresh_tokens_session_id_revoked_idx" ON "auth"."refresh_tokens" USING "btree" ("session_id", "revoked");



CREATE INDEX "refresh_tokens_updated_at_idx" ON "auth"."refresh_tokens" USING "btree" ("updated_at" DESC);



CREATE INDEX "saml_providers_sso_provider_id_idx" ON "auth"."saml_providers" USING "btree" ("sso_provider_id");



CREATE INDEX "saml_relay_states_created_at_idx" ON "auth"."saml_relay_states" USING "btree" ("created_at" DESC);



CREATE INDEX "saml_relay_states_for_email_idx" ON "auth"."saml_relay_states" USING "btree" ("for_email");



CREATE INDEX "saml_relay_states_sso_provider_id_idx" ON "auth"."saml_relay_states" USING "btree" ("sso_provider_id");



CREATE INDEX "sessions_not_after_idx" ON "auth"."sessions" USING "btree" ("not_after" DESC);



CREATE INDEX "sessions_user_id_idx" ON "auth"."sessions" USING "btree" ("user_id");



CREATE UNIQUE INDEX "sso_domains_domain_idx" ON "auth"."sso_domains" USING "btree" ("lower"("domain"));



CREATE INDEX "sso_domains_sso_provider_id_idx" ON "auth"."sso_domains" USING "btree" ("sso_provider_id");



CREATE UNIQUE INDEX "sso_providers_resource_id_idx" ON "auth"."sso_providers" USING "btree" ("lower"("resource_id"));



CREATE INDEX "sso_providers_resource_id_pattern_idx" ON "auth"."sso_providers" USING "btree" ("resource_id" "text_pattern_ops");



CREATE UNIQUE INDEX "unique_phone_factor_per_user" ON "auth"."mfa_factors" USING "btree" ("user_id", "phone");



CREATE INDEX "user_id_created_at_idx" ON "auth"."sessions" USING "btree" ("user_id", "created_at");



CREATE UNIQUE INDEX "users_email_partial_key" ON "auth"."users" USING "btree" ("email") WHERE ("is_sso_user" = false);



COMMENT ON INDEX "auth"."users_email_partial_key" IS 'Auth: A partial unique index that applies only when is_sso_user is false';



CREATE INDEX "users_instance_id_email_idx" ON "auth"."users" USING "btree" ("instance_id", "lower"(("email")::"text"));



CREATE INDEX "users_instance_id_idx" ON "auth"."users" USING "btree" ("instance_id");



CREATE INDEX "users_is_anonymous_idx" ON "auth"."users" USING "btree" ("is_anonymous");



CREATE UNIQUE INDEX "bname" ON "storage"."buckets" USING "btree" ("name");



CREATE UNIQUE INDEX "bucketid_objname" ON "storage"."objects" USING "btree" ("bucket_id", "name");



CREATE INDEX "idx_multipart_uploads_list" ON "storage"."s3_multipart_uploads" USING "btree" ("bucket_id", "key", "created_at");



CREATE UNIQUE INDEX "idx_name_bucket_level_unique" ON "storage"."objects" USING "btree" ("name" COLLATE "C", "bucket_id", "level");



CREATE INDEX "idx_objects_bucket_id_name" ON "storage"."objects" USING "btree" ("bucket_id", "name" COLLATE "C");



CREATE INDEX "idx_objects_lower_name" ON "storage"."objects" USING "btree" (("path_tokens"["level"]), "lower"("name") "text_pattern_ops", "bucket_id", "level");



CREATE INDEX "idx_prefixes_lower_name" ON "storage"."prefixes" USING "btree" ("bucket_id", "level", (("string_to_array"("name", '/'::"text"))["level"]), "lower"("name") "text_pattern_ops");



CREATE INDEX "name_prefix_search" ON "storage"."objects" USING "btree" ("name" "text_pattern_ops");



CREATE UNIQUE INDEX "objects_bucket_id_level_idx" ON "storage"."objects" USING "btree" ("bucket_id", "level", "name" COLLATE "C");



CREATE OR REPLACE TRIGGER "new_user_trigger" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."create_usertable_for_new_user"();



CREATE OR REPLACE TRIGGER "before_insert_transaction_details" BEFORE INSERT ON "public"."transactions" FOR EACH ROW EXECUTE FUNCTION "public"."set_transaction_details"();



CREATE OR REPLACE TRIGGER "handle_new_user_team_trigger" AFTER INSERT ON "public"."user_teams" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user_team"();



CREATE OR REPLACE TRIGGER "setAdminTeam" AFTER INSERT ON "public"."teams" FOR EACH ROW EXECUTE FUNCTION "public"."setAdminTeam"();



CREATE OR REPLACE TRIGGER "transaction_name_and_img_trigger" AFTER UPDATE OF "penalitie_name", "penalitie_img" ON "public"."penalties" FOR EACH ROW EXECUTE FUNCTION "public"."update_transaction_name_and_img"();



CREATE OR REPLACE TRIGGER "transaction_name_and_img_update_trigger" AFTER UPDATE OF "penalitie_id" ON "public"."transactions" FOR EACH ROW EXECUTE FUNCTION "public"."update_transaction_name_and_img_on_change"();



CREATE OR REPLACE TRIGGER "transaction_to_name_trigger" AFTER UPDATE OF "display_name" ON "public"."user_teams" FOR EACH ROW EXECUTE FUNCTION "public"."update_transaction_to_name"();



CREATE OR REPLACE TRIGGER "transaction_to_name_update_trigger" AFTER UPDATE OF "transaction_to" ON "public"."transactions" FOR EACH ROW EXECUTE FUNCTION "public"."update_transaction_to_name_on_change"();



CREATE OR REPLACE TRIGGER "update_created_by_name_trigger" AFTER UPDATE ON "public"."user_teams" FOR EACH ROW EXECUTE FUNCTION "public"."update_created_by_name"();



CREATE OR REPLACE TRIGGER "update_created_by_name_update_trigger" AFTER UPDATE ON "public"."transactions" FOR EACH ROW EXECUTE FUNCTION "public"."update_created_by_name_on_change"();



CREATE OR REPLACE TRIGGER "enforce_bucket_name_length_trigger" BEFORE INSERT OR UPDATE OF "name" ON "storage"."buckets" FOR EACH ROW EXECUTE FUNCTION "storage"."enforce_bucket_name_length"();



CREATE OR REPLACE TRIGGER "objects_delete_delete_prefix" AFTER DELETE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();



CREATE OR REPLACE TRIGGER "objects_insert_create_prefix" BEFORE INSERT ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."objects_insert_prefix_trigger"();



CREATE OR REPLACE TRIGGER "objects_update_create_prefix" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW WHEN ((("new"."name" <> "old"."name") OR ("new"."bucket_id" <> "old"."bucket_id"))) EXECUTE FUNCTION "storage"."objects_update_prefix_trigger"();



CREATE OR REPLACE TRIGGER "prefixes_create_hierarchy" BEFORE INSERT ON "storage"."prefixes" FOR EACH ROW WHEN (("pg_trigger_depth"() < 1)) EXECUTE FUNCTION "storage"."prefixes_insert_trigger"();



CREATE OR REPLACE TRIGGER "prefixes_delete_hierarchy" AFTER DELETE ON "storage"."prefixes" FOR EACH ROW EXECUTE FUNCTION "storage"."delete_prefix_hierarchy_trigger"();



CREATE OR REPLACE TRIGGER "update_objects_updated_at" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."update_updated_at_column"();



ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_auth_factor_id_fkey" FOREIGN KEY ("factor_id") REFERENCES "auth"."mfa_factors"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_flow_state_id_fkey" FOREIGN KEY ("flow_state_id") REFERENCES "auth"."flow_state"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."penalties"
    ADD CONSTRAINT "penalties_saison_id_fkey" FOREIGN KEY ("saison_id") REFERENCES "public"."saisons"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."saisons"
    ADD CONSTRAINT "saisons_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_teams"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."saisons"
    ADD CONSTRAINT "saisons_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."team_saisons"
    ADD CONSTRAINT "team_saisons_saison_id_fkey" FOREIGN KEY ("saison_id") REFERENCES "public"."saisons"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."team_saisons"
    ADD CONSTRAINT "team_saisons_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."teams"
    ADD CONSTRAINT "teams_current_saison_fkey" FOREIGN KEY ("current_saison") REFERENCES "public"."saisons"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."teams"
    ADD CONSTRAINT "teams_team_owner_fkey" FOREIGN KEY ("team_owner") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user_teams"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_penalitie_id_fkey" FOREIGN KEY ("penalitie_id") REFERENCES "public"."penalties"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_saison_id_fkey" FOREIGN KEY ("saison_id") REFERENCES "public"."saisons"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_transaction_to_fkey" FOREIGN KEY ("transaction_to") REFERENCES "public"."user_teams"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_teams"
    ADD CONSTRAINT "user_teams_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_teams"
    ADD CONSTRAINT "user_teams_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_team_setup_fkey" FOREIGN KEY ("team_setup") REFERENCES "public"."teams"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_user_setup_fkey" FOREIGN KEY ("user_setup") REFERENCES "public"."user_teams"("id");



ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");



ALTER TABLE ONLY "storage"."prefixes"
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");



ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");



ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");



ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_upload_id_fkey" FOREIGN KEY ("upload_id") REFERENCES "storage"."s3_multipart_uploads"("id") ON DELETE CASCADE;



ALTER TABLE "auth"."audit_log_entries" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."flow_state" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."identities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."instances" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."mfa_amr_claims" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."mfa_challenges" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."mfa_factors" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."one_time_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."refresh_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."saml_providers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."saml_relay_states" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."schema_migrations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."sso_domains" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."sso_providers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Allow admin and owner to manage transactions" ON "public"."transactions" USING ((EXISTS ( SELECT 1
   FROM ("public"."user_teams" "ut"
     JOIN "public"."teams" "t" ON (("t"."id" = "ut"."team_id")))
  WHERE (("ut"."user_id" = "auth"."uid"()) AND ((("ut"."role")::"text" = 'admin'::"text") OR (("ut"."role")::"text" = 'owner'::"text")) AND ("t"."current_saison" = "transactions"."saison_id")))));



CREATE POLICY "Allow delete own transactions" ON "public"."transactions" FOR DELETE USING (("created_by" = ( SELECT "user_teams"."id"
   FROM "public"."user_teams"
  WHERE (("user_teams"."user_id" = "auth"."uid"()) AND ("user_teams"."id" = "transactions"."created_by")))));



CREATE POLICY "Allow owners to delete their team's user_teams rows" ON "public"."user_teams" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."user_teams" "ut"
  WHERE (("ut"."user_id" = "auth"."uid"()) AND ("ut"."team_id" = "user_teams"."team_id") AND (("ut"."role")::"text" = 'owner'::"text")))));



CREATE POLICY "Allow owners to update their team's user_teams rows" ON "public"."user_teams" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."user_teams" "ut"
  WHERE (("ut"."user_id" = "auth"."uid"()) AND ("ut"."team_id" = "user_teams"."team_id") AND (("ut"."role")::"text" = 'owner'::"text")))));



CREATE POLICY "Allow users to create transactions with statut = 2" ON "public"."transactions" FOR INSERT WITH CHECK ((("statut" = (2)::numeric) AND (EXISTS ( SELECT 1
   FROM ("public"."user_teams" "ut"
     JOIN "public"."teams" "t" ON (("t"."id" = "ut"."team_id")))
  WHERE (("ut"."user_id" = "auth"."uid"()) AND ("t"."current_saison" = "transactions"."saison_id"))))));



CREATE POLICY "Allow users to insert their own user_teams row" ON "public"."user_teams" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Enable read access for all users" ON "public"."penalties" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."saisons" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."team_saisons" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."teams" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."transactions" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."user_teams" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."users" FOR SELECT USING (true);



ALTER TABLE "public"."penalties" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."saisons" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."team_saisons" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."teams" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_teams" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."buckets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."buckets_analytics" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."migrations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."objects" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."prefixes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."s3_multipart_uploads" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "storage"."s3_multipart_uploads_parts" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "auth" TO "anon";
GRANT USAGE ON SCHEMA "auth" TO "authenticated";
GRANT USAGE ON SCHEMA "auth" TO "service_role";
GRANT ALL ON SCHEMA "auth" TO "supabase_auth_admin";
GRANT ALL ON SCHEMA "auth" TO "dashboard_user";
GRANT USAGE ON SCHEMA "auth" TO "postgres";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT USAGE ON SCHEMA "storage" TO "postgres" WITH GRANT OPTION;
GRANT USAGE ON SCHEMA "storage" TO "anon";
GRANT USAGE ON SCHEMA "storage" TO "authenticated";
GRANT USAGE ON SCHEMA "storage" TO "service_role";
GRANT ALL ON SCHEMA "storage" TO "supabase_storage_admin";
GRANT ALL ON SCHEMA "storage" TO "dashboard_user";



GRANT ALL ON FUNCTION "auth"."email"() TO "dashboard_user";
GRANT ALL ON FUNCTION "auth"."email"() TO "postgres";



GRANT ALL ON FUNCTION "auth"."jwt"() TO "postgres";
GRANT ALL ON FUNCTION "auth"."jwt"() TO "dashboard_user";



GRANT ALL ON FUNCTION "auth"."role"() TO "dashboard_user";
GRANT ALL ON FUNCTION "auth"."role"() TO "postgres";



GRANT ALL ON FUNCTION "auth"."uid"() TO "dashboard_user";
GRANT ALL ON FUNCTION "auth"."uid"() TO "postgres";



GRANT ALL ON FUNCTION "public"."apply_agio_penalties"() TO "anon";
GRANT ALL ON FUNCTION "public"."apply_agio_penalties"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."apply_agio_penalties"() TO "service_role";



GRANT ALL ON FUNCTION "public"."apply_away_penalties"() TO "anon";
GRANT ALL ON FUNCTION "public"."apply_away_penalties"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."apply_away_penalties"() TO "service_role";



GRANT ALL ON FUNCTION "public"."apply_blacktax_penalties"() TO "anon";
GRANT ALL ON FUNCTION "public"."apply_blacktax_penalties"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."apply_blacktax_penalties"() TO "service_role";



GRANT ALL ON FUNCTION "public"."apply_eco_penalties"() TO "anon";
GRANT ALL ON FUNCTION "public"."apply_eco_penalties"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."apply_eco_penalties"() TO "service_role";



GRANT ALL ON FUNCTION "public"."apply_fees_penalties"() TO "anon";
GRANT ALL ON FUNCTION "public"."apply_fees_penalties"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."apply_fees_penalties"() TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_user_sold"("season_uid" "uuid", "user_uid" "text", "statut_param" integer, "sort_order" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_user_sold"("season_uid" "uuid", "user_uid" "text", "statut_param" integer, "sort_order" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_user_sold"("season_uid" "uuid", "user_uid" "text", "statut_param" integer, "sort_order" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_usertable_for_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_usertable_for_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_usertable_for_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."execute_agio_on_last_day"() TO "anon";
GRANT ALL ON FUNCTION "public"."execute_agio_on_last_day"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."execute_agio_on_last_day"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_unique_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_unique_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_unique_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_active_months"("p_saison_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_active_months"("p_saison_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_active_months"("p_saison_id" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_season_transactions"("p_saison_id" "uuid", "p_user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_season_transactions"("p_saison_id" "uuid", "p_user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_season_transactions"("p_saison_id" "uuid", "p_user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_transactions_grouped_by_day"("season_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_transactions_grouped_by_day"("season_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_transactions_grouped_by_day"("season_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user_team"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user_team"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user_team"() TO "service_role";



GRANT ALL ON FUNCTION "public"."setAdminTeam"() TO "anon";
GRANT ALL ON FUNCTION "public"."setAdminTeam"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."setAdminTeam"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_transaction_details"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_transaction_details"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_transaction_details"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_created_by_name"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_created_by_name"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_created_by_name"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_created_by_name_on_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_created_by_name_on_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_created_by_name_on_change"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_transaction_name_and_img"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_transaction_name_and_img"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_transaction_name_and_img"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_transaction_name_and_img_on_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_transaction_name_and_img_on_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_transaction_name_and_img_on_change"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_transaction_to_name"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_transaction_to_name"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_transaction_to_name"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_transaction_to_name_on_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_transaction_to_name_on_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_transaction_to_name_on_change"() TO "service_role";



GRANT ALL ON FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") TO "postgres";



GRANT ALL ON FUNCTION "storage"."extension"("name" "text") TO "postgres";



GRANT ALL ON FUNCTION "storage"."filename"("name" "text") TO "postgres";



GRANT ALL ON FUNCTION "storage"."foldername"("name" "text") TO "postgres";



GRANT ALL ON FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "next_key_token" "text", "next_upload_token" "text") TO "postgres";



GRANT ALL ON FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "start_after" "text", "next_token" "text") TO "postgres";



GRANT ALL ON FUNCTION "storage"."operation"() TO "postgres";



GRANT ALL ON FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text") TO "postgres";



GRANT ALL ON FUNCTION "storage"."update_updated_at_column"() TO "postgres";



GRANT ALL ON TABLE "auth"."audit_log_entries" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."audit_log_entries" TO "postgres";
GRANT SELECT ON TABLE "auth"."audit_log_entries" TO "postgres" WITH GRANT OPTION;



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."flow_state" TO "postgres";
GRANT SELECT ON TABLE "auth"."flow_state" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."flow_state" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."identities" TO "postgres";
GRANT SELECT ON TABLE "auth"."identities" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."identities" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."instances" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."instances" TO "postgres";
GRANT SELECT ON TABLE "auth"."instances" TO "postgres" WITH GRANT OPTION;



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."mfa_amr_claims" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_amr_claims" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_amr_claims" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."mfa_challenges" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_challenges" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_challenges" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."mfa_factors" TO "postgres";
GRANT SELECT ON TABLE "auth"."mfa_factors" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."mfa_factors" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."oauth_clients" TO "postgres";
GRANT ALL ON TABLE "auth"."oauth_clients" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."one_time_tokens" TO "postgres";
GRANT SELECT ON TABLE "auth"."one_time_tokens" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."one_time_tokens" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."refresh_tokens" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."refresh_tokens" TO "postgres";
GRANT SELECT ON TABLE "auth"."refresh_tokens" TO "postgres" WITH GRANT OPTION;



GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "dashboard_user";
GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "postgres";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."saml_providers" TO "postgres";
GRANT SELECT ON TABLE "auth"."saml_providers" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."saml_providers" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."saml_relay_states" TO "postgres";
GRANT SELECT ON TABLE "auth"."saml_relay_states" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."saml_relay_states" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."sessions" TO "postgres";
GRANT SELECT ON TABLE "auth"."sessions" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sessions" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."sso_domains" TO "postgres";
GRANT SELECT ON TABLE "auth"."sso_domains" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sso_domains" TO "dashboard_user";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."sso_providers" TO "postgres";
GRANT SELECT ON TABLE "auth"."sso_providers" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "auth"."sso_providers" TO "dashboard_user";



GRANT ALL ON TABLE "auth"."users" TO "dashboard_user";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "auth"."users" TO "postgres";
GRANT SELECT ON TABLE "auth"."users" TO "postgres" WITH GRANT OPTION;



GRANT ALL ON TABLE "public"."penalties" TO "anon";
GRANT ALL ON TABLE "public"."penalties" TO "authenticated";
GRANT ALL ON TABLE "public"."penalties" TO "service_role";



GRANT ALL ON TABLE "public"."saisons" TO "anon";
GRANT ALL ON TABLE "public"."saisons" TO "authenticated";
GRANT ALL ON TABLE "public"."saisons" TO "service_role";



GRANT ALL ON TABLE "public"."team_saisons" TO "anon";
GRANT ALL ON TABLE "public"."team_saisons" TO "authenticated";
GRANT ALL ON TABLE "public"."team_saisons" TO "service_role";



GRANT ALL ON TABLE "public"."teams" TO "anon";
GRANT ALL ON TABLE "public"."teams" TO "authenticated";
GRANT ALL ON TABLE "public"."teams" TO "service_role";



GRANT ALL ON TABLE "public"."transactions" TO "anon";
GRANT ALL ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";



GRANT ALL ON TABLE "public"."user_teams" TO "anon";
GRANT ALL ON TABLE "public"."user_teams" TO "authenticated";
GRANT ALL ON TABLE "public"."user_teams" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "storage"."buckets" TO "anon";
GRANT ALL ON TABLE "storage"."buckets" TO "authenticated";
GRANT ALL ON TABLE "storage"."buckets" TO "service_role";
GRANT ALL ON TABLE "storage"."buckets" TO "postgres" WITH GRANT OPTION;



GRANT ALL ON TABLE "storage"."buckets_analytics" TO "service_role";
GRANT ALL ON TABLE "storage"."buckets_analytics" TO "authenticated";
GRANT ALL ON TABLE "storage"."buckets_analytics" TO "anon";



GRANT ALL ON TABLE "storage"."objects" TO "anon";
GRANT ALL ON TABLE "storage"."objects" TO "authenticated";
GRANT ALL ON TABLE "storage"."objects" TO "service_role";
GRANT ALL ON TABLE "storage"."objects" TO "postgres" WITH GRANT OPTION;



GRANT ALL ON TABLE "storage"."prefixes" TO "service_role";
GRANT ALL ON TABLE "storage"."prefixes" TO "authenticated";
GRANT ALL ON TABLE "storage"."prefixes" TO "anon";



GRANT ALL ON TABLE "storage"."s3_multipart_uploads" TO "service_role";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads" TO "authenticated";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads" TO "anon";
GRANT ALL ON TABLE "storage"."s3_multipart_uploads" TO "postgres";



GRANT ALL ON TABLE "storage"."s3_multipart_uploads_parts" TO "service_role";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads_parts" TO "authenticated";
GRANT SELECT ON TABLE "storage"."s3_multipart_uploads_parts" TO "anon";
GRANT ALL ON TABLE "storage"."s3_multipart_uploads_parts" TO "postgres";



ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES  TO "dashboard_user";



ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS  TO "dashboard_user";



ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES  TO "dashboard_user";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON SEQUENCES  TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON FUNCTIONS  TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "storage" GRANT ALL ON TABLES  TO "service_role";



RESET ALL;
