PGDMP                      }            labour_ms_db    17.4    17.4 t    w           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            x           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            y           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            z           1262    16388    labour_ms_db    DATABASE     r   CREATE DATABASE labour_ms_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en-US';
    DROP DATABASE labour_ms_db;
                     postgres    false                       1255    24581 �  usp_persist_establishment_details(bigint, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, integer, character varying, integer, character varying, character varying, integer, character varying, character varying, integer, integer, date, date, numeric, numeric, numeric, numeric, integer, integer, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.usp_persist_establishment_details(IN p_establishment_id bigint, IN p_establishment_name character varying, IN p_contact_person character varying, IN p_email_id character varying, IN p_mobile_number character varying, IN p_door_number character varying, IN p_street character varying, IN p_state_id integer, IN p_state_code character varying, IN p_district_id integer, IN p_district_code character varying, IN p_city_id integer, IN p_city_code character varying, IN p_village_area character varying, IN p_pincode integer, IN p_is_plan_approval_id character varying, IN p_plan_approval_id character varying, IN p_category_id integer, IN p_work_nature_id integer, IN p_commencement_date date, IN p_completion_date date, IN p_construction_estimated_cost numeric, IN p_construction_area numeric, IN p_built_up_area numeric, IN p_basic_estimated_cost numeric, IN p_no_of_male_workers integer, IN p_no_of_female_workers integer, IN p_is_accepted_terms_conditions character varying, OUT p_status_code integer, OUT p_message character varying)
    LANGUAGE plpgsql
    AS $$

	DECLARE 
		lv_establishment_id     bigint;
		lv_record_count			integer;
		lv_error_code			text;
		lv_error_detail			text;
		lv_error_hint			text;
		lv_error_context		text;
		lv_error_message		text;
	
BEGIN

	SELECT COUNT(*) INTO lv_record_count 
		FROM tbl_establishment_details
		WHERE establishment_id = p_establishment_id;
    -- INSERT
    IF lv_record_count = 0 THEN
		IF NOT EXISTS (SELECT 1 FROM tbl_establishment_details WHERE email_id = p_email_id OR mobile_number = p_mobile_number) THEN
	        INSERT INTO tbl_establishment_details 
			(
				establishment_name, 
				contact_person, 
				email_id,
				mobile_number,
				is_accepted_terms_conditions
			)
	        VALUES 
			(
				p_establishment_name, 
				p_contact_person, 
				p_email_id,
				p_mobile_number,
				p_is_accepted_terms_conditions
			)
			RETURNING id INTO lv_establishment_id;

			INSERT INTO tbl_establishment_address_details 
			(
				establishment_id, 
				door_number,
				street,
				state_id,
				state_code,
				district_id,
				district_code,
				city_id,
				city_code,
				village_area,
				pincode
			)
	        VALUES 
			(
				lv_establishment_id,
				p_door_number,
				p_street,
				p_state_id,
				p_state_code,
				p_district_id,
				p_district_code,
				p_city_id,
				p_city_code,
				p_village_area,
				p_pincode
			);

			INSERT INTO tbl_establishment_business_details
			(
				establishment_id,
				is_plan_approval_id,
				plan_approval_id,
				category_id,
				work_nature_id,
				commencement_date,
				completion_date
			)
			VALUES 
			(
				lv_establishment_id,
				p_is_plan_approval_id, 
				p_plan_approval_id, 
				p_category_id,
				p_work_nature_id,
				p_commencement_date,
				p_completion_date
			);

			INSERT INTO tbl_establishment_construction_details
			(
				establishment_id,
				construction_estimated_cost,
				construction_area,
				built_up_area,
				basic_estimated_cost,
				no_of_male_workers,
				no_of_female_workers
			)
			VALUES 
			(
				lv_establishment_id,
				p_construction_estimated_cost, 
				p_construction_area, 
				p_built_up_area,
				p_basic_estimated_cost,
				p_no_of_male_workers,
				p_completion_date,
				p_no_of_female_workers
			);
			COMMIT;
	    	SET p_status_code = 1;
			SET p_message = 'Establishment deatils has been created successfully.';
		ELSE
			SET p_status_code = 0;
			SET p_message = 'Email or mobile number of establishment deatils already exists.';
		END IF;
	ELSE
		IF NOT EXISTS (SELECT 1 FROM tbl_establishment_details 
						WHERE (email_id = p_email_id OR mobile_number = p_mobile_number) 
							AND establishment_id <> p_establishment_id) THEN
							
			UPDATE tbl_establishment_details
	        SET establishment_name	= 	p_establishment_name,
	            contact_person 		= 	p_contact_person,
				email_id 			= 	p_email_id,
				mobile_number 		= 	p_mobile_number
	        WHERE establishment_id	= 	p_establishment_id;

			UPDATE tbl_establishment_address_details
	        SET door_number 		= 	p_door_number,
	            street 				= 	p_street,
				email_id 			= 	p_email_id,
				state_id 			= 	p_state_id,
				state_code 			= 	p_state_code,
				district_id 		= 	p_district_id,
	            district_code 		= 	p_district_code,
				city_id 			= 	p_city_id,
				city_code 			= 	p_city_code,
				village_area 		= 	p_village_area,
				pincode				=	p_pincode
	        WHERE establishment_id = p_establishment_id;

			UPDATE tbl_establishment_business_details
	        SET is_plan_approval_id	= 	p_is_plan_approval_id,
	            plan_approval_id 		= 	p_plan_approval_id,
				category_id 			= 	p_category_id,
				work_nature_id 			= 	p_work_nature_id,
				commencement_date		=	p_commencement_date,
				completion_date			=	p_completion_date
	        WHERE establishment_id		= 	p_establishment_id;

			UPDATE tbl_establishment_construction_details
	        SET construction_estimated_cost	= 	p_construction_estimated_cost,
	            construction_area 				= 	p_construction_area,
				built_up_area 					= 	p_built_up_area,
				basic_estimated_cost 			= 	p_basic_estimated_cost,
				no_of_male_workers				=	p_no_of_male_workers,
				no_of_female_workers			=	p_no_of_female_workers
	        WHERE establishment_id				= 	p_establishment_id;
			COMMIT; 
			SET p_status_code = 1;
			SET p_message = 'Establishment details has been updated successfully.';
	    ELSE
				SET p_status_code = 0;
				SET p_message = 'Email or mobile number of establishment deatils already exists.';
		END IF;		
    END IF;

	EXCEPTION 
		WHEN others THEN	
			ROLLBACK;
			GET STACKED DIAGNOSTICS
				lv_error_code		=	RETURNED_SQLSTATE,
				lv_error_detail 	=	PG_EXCEPTION_DETAIL,
				lv_error_hint		=	PG_EXCEPTION_HINT,
				lv_error_context	=	PG_EXCEPTION_CONTEXT,
				lv_error_message	=	MESSAGE_TEXT;
			SET p_status_code = 0;
			SET p_message = lv_error_message;			
			RAISE EXCEPTION USING MESSAGE = lv_error_code || ', ' || lv_error_detail || ', ' || lv_error_hint || ', ' || lv_error_context || ', ' || lv_error_message;
	
END;
$$;
 "  DROP PROCEDURE public.usp_persist_establishment_details(IN p_establishment_id bigint, IN p_establishment_name character varying, IN p_contact_person character varying, IN p_email_id character varying, IN p_mobile_number character varying, IN p_door_number character varying, IN p_street character varying, IN p_state_id integer, IN p_state_code character varying, IN p_district_id integer, IN p_district_code character varying, IN p_city_id integer, IN p_city_code character varying, IN p_village_area character varying, IN p_pincode integer, IN p_is_plan_approval_id character varying, IN p_plan_approval_id character varying, IN p_category_id integer, IN p_work_nature_id integer, IN p_commencement_date date, IN p_completion_date date, IN p_construction_estimated_cost numeric, IN p_construction_area numeric, IN p_built_up_area numeric, IN p_basic_estimated_cost numeric, IN p_no_of_male_workers integer, IN p_no_of_female_workers integer, IN p_is_accepted_terms_conditions character varying, OUT p_status_code integer, OUT p_message character varying);
       public               postgres    false                       1255    24580 w   usp_persist_state_details(character varying, integer, character varying, character varying, character varying, integer) 	   PROCEDURE       CREATE PROCEDURE public.usp_persist_state_details(OUT p_status_code integer, OUT p_message character varying, IN p_activity character varying, IN p_state_id integer DEFAULT NULL::integer, IN p_state_name character varying DEFAULT NULL::character varying, IN p_state_code character varying DEFAULT NULL::character varying, IN p_is_active character varying DEFAULT NULL::character varying, IN p_user_id integer DEFAULT NULL::integer)
    LANGUAGE plpgsql
    AS $$

	DECLARE 
		lv_record_count			integer;
		lv_error_code			text;
		lv_error_detail			text;
		lv_error_hint			text;
		lv_error_context		text;
		lv_error_message		text;
	
BEGIN
    -- INSERT
    IF UPPER(p_activity) = 'I' THEN
		SELECT COUNT(*) INTO lv_record_count 
		FROM tbl_states
		WHERE (state_name = p_state_name OR state_code = p_state_code);

		IF lv_record_count = 0 THEN
	        INSERT INTO tbl_states 
			(
				state_name, 
				state_code, 
				is_active,
				created_by,
				created_date
			)
	        VALUES 
			(
				p_state_name, 
				p_state_code, 
				p_is_active,
				p_user_id,
				CURRENT_TIMESTAMP
			);
			
	    	SET p_status_code = 1;
			SET p_message = 'State has been created successfully.';
		ELSE
			SET p_status_code = 0;
			SET p_message = 'State already exists.';
		END IF;
		
    -- UPDATE
    ELSIF UPPER(p_activity) = 'U' THEN
		SELECT COUNT(*) INTO lv_record_count 
		FROM tbl_states
		WHERE (state_name = p_state_name AND state_code = p_state_code);

		IF lv_record_count > 0 THEN
		
	        UPDATE tbl_states
	        SET state_name = p_state_name,
	            state_code = p_state_code,
	            modified_by = p_user_id,
				modified_date = CURRENT_TIMESTAMP
	        WHERE state_id = p_state_id;
	
			SET p_status_code = 1;
			SET p_message = 'State has been updated successfully.';
		ELSE
			SET p_status_code = 0;
			SET p_message = 'State not exists.';
		END IF;
		
    -- DELETE
    ELSIF UPPER(p_activity) = 'D' THEN
		SELECT COUNT(*) INTO lv_record_count 
		FROM tbl_states
		WHERE (state_name = p_state_name AND state_code = p_state_code);
		
		IF lv_record_count > 0 THEN
	        DELETE FROM tbl_states 
			WHERE state_id = p_state_id;
	
			SET p_status_code = 1;
			SET p_message = 'State has been deleted successfully.';
		ELSE
			SET p_status_code = 0;
			SET p_message = 'State not exists.';
		END IF;
	ELSE
		SELECT COUNT(*) INTO lv_record_count 
		FROM tbl_states
		WHERE (state_name = p_state_name AND state_code = p_state_code);

		IF lv_record_count > 0 THEN
			UPDATE tbl_states
	        SET is_active = p_is_active,
	            modified_by = p_user_id,
				modified_date = CURRENT_TIMESTAMP
	        WHERE state_id = p_state_id;
			
			SET p_status_code = 1;
			SET p_message = 'State status has been updated successfully.';
	    ELSE
				SET p_status_code = 0;
				SET p_message = 'State not exists.';
		END IF;		
    END IF;

	EXCEPTION 
		WHEN others THEN			
			GET STACKED DIAGNOSTICS
				lv_error_code		=	RETURNED_SQLSTATE,
				lv_error_detail 	=	PG_EXCEPTION_DETAIL,
				lv_error_hint		=	PG_EXCEPTION_HINT,
				lv_error_context	=	PG_EXCEPTION_CONTEXT,
				lv_error_message	=	MESSAGE_TEXT;
			SET p_status_code = 0;
			SET p_message = lv_error_message;
			RAISE EXCEPTION USING MESSAGE = lv_error_code || ', ' || lv_error_detail || ', ' || lv_error_hint || ', ' || lv_error_context || ', ' || lv_error_message;
	
END;
$$;
 #  DROP PROCEDURE public.usp_persist_state_details(OUT p_status_code integer, OUT p_message character varying, IN p_activity character varying, IN p_state_id integer, IN p_state_name character varying, IN p_state_code character varying, IN p_is_active character varying, IN p_user_id integer);
       public               postgres    false            �            1259    16555 
   tbl_cities    TABLE     z  CREATE TABLE public.tbl_cities (
    city_id integer NOT NULL,
    city_name character varying(50) NOT NULL,
    city_code character varying(10),
    district_id integer,
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
    DROP TABLE public.tbl_cities;
       public         heap r       postgres    false            �            1259    16554    tbl_cities_city_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_cities ALTER COLUMN city_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_cities_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    250            �            1259    16411    tbl_department_roles    TABLE     �   CREATE TABLE public.tbl_department_roles (
    department_role_id integer NOT NULL,
    role_name character varying(10) NOT NULL,
    role_description character varying(50) NOT NULL,
    is_active character varying(1) NOT NULL
);
 (   DROP TABLE public.tbl_department_roles;
       public         heap r       postgres    false            �            1259    16410 +   tbl_department_roles_department_role_id_seq    SEQUENCE       ALTER TABLE public.tbl_department_roles ALTER COLUMN department_role_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_department_roles_department_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    220            �            1259    16423    tbl_department_users    TABLE     �  CREATE TABLE public.tbl_department_users (
    department_user_id integer NOT NULL,
    department_role_id integer NOT NULL,
    email_id character varying(250) NOT NULL,
    password character varying(500) NOT NULL,
    regular_place_of_posting character varying(50),
    zone_id integer,
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
 (   DROP TABLE public.tbl_department_users;
       public         heap r       postgres    false            �            1259    16422 +   tbl_department_users_department_user_id_seq    SEQUENCE       ALTER TABLE public.tbl_department_users ALTER COLUMN department_user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_department_users_department_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    224            �            1259    16475    tbl_districts    TABLE     �  CREATE TABLE public.tbl_districts (
    district_id integer NOT NULL,
    district_name character varying(50) NOT NULL,
    district_code character varying(10),
    state_id integer,
    state_code character varying(10),
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
 !   DROP TABLE public.tbl_districts;
       public         heap r       postgres    false            �            1259    16474    tbl_districts_district_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_districts ALTER COLUMN district_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_districts_district_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    240            �            1259    16561 !   tbl_establishment_address_details    TABLE     �  CREATE TABLE public.tbl_establishment_address_details (
    id bigint NOT NULL,
    establishment_id bigint,
    door_number character varying(50) NOT NULL,
    street character varying(10),
    state_id integer,
    state_code character varying(10),
    district_id integer,
    district_code character varying(10),
    city_id integer,
    city_code character varying(10),
    village_area character varying(50),
    pincode integer
);
 5   DROP TABLE public.tbl_establishment_address_details;
       public         heap r       postgres    false            �            1259    16560 (   tbl_establishment_address_details_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_establishment_address_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_establishment_address_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    252            �            1259    16567 "   tbl_establishment_business_details    TABLE     Q  CREATE TABLE public.tbl_establishment_business_details (
    id bigint NOT NULL,
    establishment_id bigint,
    is_plan_approval_id character varying(50),
    plan_approval_id character varying(50),
    category_id integer NOT NULL,
    work_nature_id integer NOT NULL,
    commencement_date date NOT NULL,
    completion_date date
);
 6   DROP TABLE public.tbl_establishment_business_details;
       public         heap r       postgres    false            �            1259    16566 )   tbl_establishment_business_details_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_establishment_business_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_establishment_business_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    254                        1259    16573    tbl_establishment_categories    TABLE     }  CREATE TABLE public.tbl_establishment_categories (
    category_id integer NOT NULL,
    category_name character varying(50) NOT NULL,
    description character varying(50),
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
 0   DROP TABLE public.tbl_establishment_categories;
       public         heap r       postgres    false            �            1259    16572 ,   tbl_establishment_categories_category_id_seq    SEQUENCE       ALTER TABLE public.tbl_establishment_categories ALTER COLUMN category_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_establishment_categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    256                       1259    16579 &   tbl_establishment_construction_details    TABLE     S  CREATE TABLE public.tbl_establishment_construction_details (
    id bigint NOT NULL,
    establishment_id bigint,
    construction_estimated_cost numeric(16,4),
    construction_area numeric(12,4),
    built_up_area numeric(12,4),
    basic_estimated_cost numeric(16,4),
    no_of_male_workers integer,
    no_of_female_workers integer
);
 :   DROP TABLE public.tbl_establishment_construction_details;
       public         heap r       postgres    false                       1259    16578 -   tbl_establishment_construction_details_id_seq    SEQUENCE       ALTER TABLE public.tbl_establishment_construction_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_establishment_construction_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    258            �            1259    16549    tbl_establishment_details    TABLE     b  CREATE TABLE public.tbl_establishment_details (
    establishment_id bigint NOT NULL,
    establishment_name character varying(50) NOT NULL,
    contact_person character varying(50) NOT NULL,
    email_id character varying(250) NOT NULL,
    mobile_number character varying(20) NOT NULL,
    is_accepted_terms_conditions character varying(1) NOT NULL
);
 -   DROP TABLE public.tbl_establishment_details;
       public         heap r       postgres    false            �            1259    16548 .   tbl_establishment_details_establishment_id_seq    SEQUENCE     	  ALTER TABLE public.tbl_establishment_details ALTER COLUMN establishment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_establishment_details_establishment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    248                       1259    16585    tbl_establishment_work_natures    TABLE     �  CREATE TABLE public.tbl_establishment_work_natures (
    work_nature_id integer NOT NULL,
    work_nature_name character varying(50) NOT NULL,
    description character varying(50),
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
 2   DROP TABLE public.tbl_establishment_work_natures;
       public         heap r       postgres    false                       1259    16584 1   tbl_establishment_work_natures_work_nature_id_seq    SEQUENCE       ALTER TABLE public.tbl_establishment_work_natures ALTER COLUMN work_nature_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_establishment_work_natures_work_nature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    260            �            1259    16396 
   tbl_states    TABLE     m  CREATE TABLE public.tbl_states (
    state_id integer NOT NULL,
    state_name character varying(50) NOT NULL,
    state_code character varying(10) NOT NULL,
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
    DROP TABLE public.tbl_states;
       public         heap r       postgres    false            �            1259    16395    tbl_states_state_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_states ALTER COLUMN state_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_states_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    218            �            1259    16463    tbl_trade_of_works    TABLE     r  CREATE TABLE public.tbl_trade_of_works (
    trade_work_id integer NOT NULL,
    work_name character varying(50) NOT NULL,
    description character varying(250),
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
 &   DROP TABLE public.tbl_trade_of_works;
       public         heap r       postgres    false            �            1259    16462 $   tbl_trade_of_works_trade_work_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_trade_of_works ALTER COLUMN trade_work_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_trade_of_works_trade_work_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    236            �            1259    16494    tbl_worker_bank_details    TABLE     k  CREATE TABLE public.tbl_worker_bank_details (
    id bigint NOT NULL,
    account_number character varying(50) NOT NULL,
    bank_name character varying(50) NOT NULL,
    ifsc_code character varying(20) NOT NULL,
    branch_name character varying(50) NOT NULL,
    branch_address character varying(250) NOT NULL,
    pincode integer,
    worker_user_id bigint
);
 +   DROP TABLE public.tbl_worker_bank_details;
       public         heap r       postgres    false            �            1259    16493    tbl_worker_bank_details_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_worker_bank_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_worker_bank_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    242            �            1259    16457    tbl_worker_categories    TABLE     v  CREATE TABLE public.tbl_worker_categories (
    category_id integer NOT NULL,
    category_name character varying(50) NOT NULL,
    description character varying(50),
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
 )   DROP TABLE public.tbl_worker_categories;
       public         heap r       postgres    false            �            1259    16456 %   tbl_worker_categories_category_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_worker_categories ALTER COLUMN category_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_worker_categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    234            �            1259    16450    tbl_worker_dependents    TABLE     /  CREATE TABLE public.tbl_worker_dependents (
    id bigint NOT NULL,
    worker_user_id bigint NOT NULL,
    dependent_name character varying(50) NOT NULL,
    date_of_birth date,
    relationship character varying(50),
    is_nominee_selected character varying(1),
    percentage_of_benefits integer
);
 )   DROP TABLE public.tbl_worker_dependents;
       public         heap r       postgres    false            �            1259    16449    tbl_worker_dependents_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_worker_dependents ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_worker_dependents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    232            �            1259    16443    tbl_worker_identity_details    TABLE       CREATE TABLE public.tbl_worker_identity_details (
    id bigint NOT NULL,
    worker_user_id bigint NOT NULL,
    aadhar_card_number character varying(50) NOT NULL,
    e_shram_id character varying(50),
    bocw_wb_id character varying(50),
    access_card_id character varying(50)
);
 /   DROP TABLE public.tbl_worker_identity_details;
       public         heap r       postgres    false            �            1259    16442 "   tbl_worker_identity_details_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_worker_identity_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_worker_identity_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    230            �            1259    16506 $   tbl_worker_permanent_address_details    TABLE     �  CREATE TABLE public.tbl_worker_permanent_address_details (
    id bigint NOT NULL,
    door_number character varying(50) NOT NULL,
    street character varying(10),
    state_id integer,
    state_code character varying(10),
    district_id integer,
    district_code character varying(10),
    city_id integer,
    city_code character varying(10),
    village_area character varying(50),
    pincode integer,
    worker_user_id bigint
);
 8   DROP TABLE public.tbl_worker_permanent_address_details;
       public         heap r       postgres    false            �            1259    16505 +   tbl_worker_permanent_address_details_id_seq    SEQUENCE       ALTER TABLE public.tbl_worker_permanent_address_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_worker_permanent_address_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    244            �            1259    16512 "   tbl_worker_present_address_details    TABLE     �  CREATE TABLE public.tbl_worker_present_address_details (
    id bigint NOT NULL,
    door_number character varying(50) NOT NULL,
    street character varying(10),
    state_id integer,
    state_code character varying(10),
    district_id integer,
    district_code character varying(10),
    city_id integer,
    city_code character varying(10),
    village_area character varying(50),
    pincode integer,
    worker_user_id bigint
);
 6   DROP TABLE public.tbl_worker_present_address_details;
       public         heap r       postgres    false            �            1259    16511 )   tbl_worker_present_address_details_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_worker_present_address_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_worker_present_address_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    246            �            1259    16437    tbl_worker_users    TABLE     �  CREATE TABLE public.tbl_worker_users (
    worker_user_id bigint NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    middle_name character varying(50),
    gender character varying(1) NOT NULL,
    marital_status character varying(1) NOT NULL,
    date_ofbirth date,
    age integer,
    father_name character varying(50),
    husband_name character varying(50),
    caste character varying(50),
    sub_caste character varying(50),
    status_code character varying(3),
    is_active character varying(1) NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_date timestamp without time zone
);
 $   DROP TABLE public.tbl_worker_users;
       public         heap r       postgres    false            �            1259    16436 #   tbl_worker_users_worker_user_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_worker_users ALTER COLUMN worker_user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_worker_users_worker_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    228            �            1259    16469    tbl_worker_work_places    TABLE       CREATE TABLE public.tbl_worker_work_places (
    work_place_id integer NOT NULL,
    employer_name character varying(50) NOT NULL,
    organisation_name character varying(50),
    category_id integer,
    trade_work_id integer,
    worker_user_id bigint
);
 *   DROP TABLE public.tbl_worker_work_places;
       public         heap r       postgres    false            �            1259    16468 (   tbl_worker_work_places_work_place_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_worker_work_places ALTER COLUMN work_place_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_worker_work_places_work_place_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    238            �            1259    16431    tbl_workflow_status    TABLE     �   CREATE TABLE public.tbl_workflow_status (
    id integer NOT NULL,
    status_code character varying(10) NOT NULL,
    status_name character varying(50) NOT NULL,
    is_active character varying(1) NOT NULL
);
 '   DROP TABLE public.tbl_workflow_status;
       public         heap r       postgres    false            �            1259    16430    tbl_workflow_status_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_workflow_status ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_workflow_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    226            �            1259    16417 	   tbl_zones    TABLE     ;  CREATE TABLE public.tbl_zones (
    zone_id integer NOT NULL,
    zone_name character varying(50) NOT NULL,
    is_active character varying(1) NOT NULL,
    created_by integer NOT NULL,
    created_date timestamp without time zone NOT NULL,
    modified_by integer,
    modified_date timestamp without time zone
);
    DROP TABLE public.tbl_zones;
       public         heap r       postgres    false            �            1259    16416    tbl_zones_zone_id_seq    SEQUENCE     �   ALTER TABLE public.tbl_zones ALTER COLUMN zone_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbl_zones_zone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public               postgres    false    222            j          0    16555 
   tbl_cities 
   TABLE DATA           �   COPY public.tbl_cities (city_id, city_name, city_code, district_id, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    250   ��       L          0    16411    tbl_department_roles 
   TABLE DATA           j   COPY public.tbl_department_roles (department_role_id, role_name, role_description, is_active) FROM stdin;
    public               postgres    false    220   ��       P          0    16423    tbl_department_users 
   TABLE DATA           �   COPY public.tbl_department_users (department_user_id, department_role_id, email_id, password, regular_place_of_posting, zone_id, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    224   -�       `          0    16475    tbl_districts 
   TABLE DATA           �   COPY public.tbl_districts (district_id, district_name, district_code, state_id, state_code, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    240   ��       l          0    16561 !   tbl_establishment_address_details 
   TABLE DATA           �   COPY public.tbl_establishment_address_details (id, establishment_id, door_number, street, state_id, state_code, district_id, district_code, city_id, city_code, village_area, pincode) FROM stdin;
    public               postgres    false    252   ��       n          0    16567 "   tbl_establishment_business_details 
   TABLE DATA           �   COPY public.tbl_establishment_business_details (id, establishment_id, is_plan_approval_id, plan_approval_id, category_id, work_nature_id, commencement_date, completion_date) FROM stdin;
    public               postgres    false    254   ��       p          0    16573    tbl_establishment_categories 
   TABLE DATA           �   COPY public.tbl_establishment_categories (category_id, category_name, description, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    256   ��       r          0    16579 &   tbl_establishment_construction_details 
   TABLE DATA           �   COPY public.tbl_establishment_construction_details (id, establishment_id, construction_estimated_cost, construction_area, built_up_area, basic_estimated_cost, no_of_male_workers, no_of_female_workers) FROM stdin;
    public               postgres    false    258   ��       h          0    16549    tbl_establishment_details 
   TABLE DATA           �   COPY public.tbl_establishment_details (establishment_id, establishment_name, contact_person, email_id, mobile_number, is_accepted_terms_conditions) FROM stdin;
    public               postgres    false    248   ��       t          0    16585    tbl_establishment_work_natures 
   TABLE DATA           �   COPY public.tbl_establishment_work_natures (work_nature_id, work_nature_name, description, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    260   ��       J          0    16396 
   tbl_states 
   TABLE DATA           �   COPY public.tbl_states (state_id, state_name, state_code, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    218   k�       \          0    16463    tbl_trade_of_works 
   TABLE DATA           �   COPY public.tbl_trade_of_works (trade_work_id, work_name, description, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    236   ��       b          0    16494    tbl_worker_bank_details 
   TABLE DATA           �   COPY public.tbl_worker_bank_details (id, account_number, bank_name, ifsc_code, branch_name, branch_address, pincode, worker_user_id) FROM stdin;
    public               postgres    false    242   ��       Z          0    16457    tbl_worker_categories 
   TABLE DATA           �   COPY public.tbl_worker_categories (category_id, category_name, description, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    234   ��       X          0    16450    tbl_worker_dependents 
   TABLE DATA           �   COPY public.tbl_worker_dependents (id, worker_user_id, dependent_name, date_of_birth, relationship, is_nominee_selected, percentage_of_benefits) FROM stdin;
    public               postgres    false    232   e�       V          0    16443    tbl_worker_identity_details 
   TABLE DATA           �   COPY public.tbl_worker_identity_details (id, worker_user_id, aadhar_card_number, e_shram_id, bocw_wb_id, access_card_id) FROM stdin;
    public               postgres    false    230   ��       d          0    16506 $   tbl_worker_permanent_address_details 
   TABLE DATA           �   COPY public.tbl_worker_permanent_address_details (id, door_number, street, state_id, state_code, district_id, district_code, city_id, city_code, village_area, pincode, worker_user_id) FROM stdin;
    public               postgres    false    244   ��       f          0    16512 "   tbl_worker_present_address_details 
   TABLE DATA           �   COPY public.tbl_worker_present_address_details (id, door_number, street, state_id, state_code, district_id, district_code, city_id, city_code, village_area, pincode, worker_user_id) FROM stdin;
    public               postgres    false    246   ��       T          0    16437    tbl_worker_users 
   TABLE DATA           �   COPY public.tbl_worker_users (worker_user_id, first_name, last_name, middle_name, gender, marital_status, date_ofbirth, age, father_name, husband_name, caste, sub_caste, status_code, is_active, created_date, modified_date) FROM stdin;
    public               postgres    false    228   ��       ^          0    16469    tbl_worker_work_places 
   TABLE DATA           �   COPY public.tbl_worker_work_places (work_place_id, employer_name, organisation_name, category_id, trade_work_id, worker_user_id) FROM stdin;
    public               postgres    false    238   ��       R          0    16431    tbl_workflow_status 
   TABLE DATA           V   COPY public.tbl_workflow_status (id, status_code, status_name, is_active) FROM stdin;
    public               postgres    false    226   �       N          0    16417 	   tbl_zones 
   TABLE DATA           x   COPY public.tbl_zones (zone_id, zone_name, is_active, created_by, created_date, modified_by, modified_date) FROM stdin;
    public               postgres    false    222   e�       {           0    0    tbl_cities_city_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.tbl_cities_city_id_seq', 1, false);
          public               postgres    false    249            |           0    0 +   tbl_department_roles_department_role_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.tbl_department_roles_department_role_id_seq', 4, true);
          public               postgres    false    219            }           0    0 +   tbl_department_users_department_user_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.tbl_department_users_department_user_id_seq', 1, true);
          public               postgres    false    223            ~           0    0    tbl_districts_district_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.tbl_districts_district_id_seq', 1, false);
          public               postgres    false    239                       0    0 (   tbl_establishment_address_details_id_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.tbl_establishment_address_details_id_seq', 1, false);
          public               postgres    false    251            �           0    0 )   tbl_establishment_business_details_id_seq    SEQUENCE SET     X   SELECT pg_catalog.setval('public.tbl_establishment_business_details_id_seq', 1, false);
          public               postgres    false    253            �           0    0 ,   tbl_establishment_categories_category_id_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public.tbl_establishment_categories_category_id_seq', 6, true);
          public               postgres    false    255            �           0    0 -   tbl_establishment_construction_details_id_seq    SEQUENCE SET     \   SELECT pg_catalog.setval('public.tbl_establishment_construction_details_id_seq', 1, false);
          public               postgres    false    257            �           0    0 .   tbl_establishment_details_establishment_id_seq    SEQUENCE SET     ]   SELECT pg_catalog.setval('public.tbl_establishment_details_establishment_id_seq', 1, false);
          public               postgres    false    247            �           0    0 1   tbl_establishment_work_natures_work_nature_id_seq    SEQUENCE SET     _   SELECT pg_catalog.setval('public.tbl_establishment_work_natures_work_nature_id_seq', 6, true);
          public               postgres    false    259            �           0    0    tbl_states_state_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.tbl_states_state_id_seq', 1, false);
          public               postgres    false    217            �           0    0 $   tbl_trade_of_works_trade_work_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.tbl_trade_of_works_trade_work_id_seq', 1, false);
          public               postgres    false    235            �           0    0    tbl_worker_bank_details_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.tbl_worker_bank_details_id_seq', 1, false);
          public               postgres    false    241            �           0    0 %   tbl_worker_categories_category_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.tbl_worker_categories_category_id_seq', 4, true);
          public               postgres    false    233            �           0    0    tbl_worker_dependents_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.tbl_worker_dependents_id_seq', 1, false);
          public               postgres    false    231            �           0    0 "   tbl_worker_identity_details_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.tbl_worker_identity_details_id_seq', 1, false);
          public               postgres    false    229            �           0    0 +   tbl_worker_permanent_address_details_id_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public.tbl_worker_permanent_address_details_id_seq', 1, false);
          public               postgres    false    243            �           0    0 )   tbl_worker_present_address_details_id_seq    SEQUENCE SET     X   SELECT pg_catalog.setval('public.tbl_worker_present_address_details_id_seq', 1, false);
          public               postgres    false    245            �           0    0 #   tbl_worker_users_worker_user_id_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.tbl_worker_users_worker_user_id_seq', 1, false);
          public               postgres    false    227            �           0    0 (   tbl_worker_work_places_work_place_id_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.tbl_worker_work_places_work_place_id_seq', 1, false);
          public               postgres    false    237            �           0    0    tbl_workflow_status_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.tbl_workflow_status_id_seq', 4, true);
          public               postgres    false    225            �           0    0    tbl_zones_zone_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.tbl_zones_zone_id_seq', 4, true);
          public               postgres    false    221            �           2606    16559    tbl_cities tbl_cities_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.tbl_cities
    ADD CONSTRAINT tbl_cities_pkey PRIMARY KEY (city_id);
 D   ALTER TABLE ONLY public.tbl_cities DROP CONSTRAINT tbl_cities_pkey;
       public                 postgres    false    250            �           2606    16415 .   tbl_department_roles tbl_department_roles_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.tbl_department_roles
    ADD CONSTRAINT tbl_department_roles_pkey PRIMARY KEY (department_role_id);
 X   ALTER TABLE ONLY public.tbl_department_roles DROP CONSTRAINT tbl_department_roles_pkey;
       public                 postgres    false    220            �           2606    16429 .   tbl_department_users tbl_department_users_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.tbl_department_users
    ADD CONSTRAINT tbl_department_users_pkey PRIMARY KEY (department_user_id);
 X   ALTER TABLE ONLY public.tbl_department_users DROP CONSTRAINT tbl_department_users_pkey;
       public                 postgres    false    224            �           2606    16479     tbl_districts tbl_districts_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.tbl_districts
    ADD CONSTRAINT tbl_districts_pkey PRIMARY KEY (district_id);
 J   ALTER TABLE ONLY public.tbl_districts DROP CONSTRAINT tbl_districts_pkey;
       public                 postgres    false    240            �           2606    16565 H   tbl_establishment_address_details tbl_establishment_address_details_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tbl_establishment_address_details
    ADD CONSTRAINT tbl_establishment_address_details_pkey PRIMARY KEY (id);
 r   ALTER TABLE ONLY public.tbl_establishment_address_details DROP CONSTRAINT tbl_establishment_address_details_pkey;
       public                 postgres    false    252            �           2606    16571 J   tbl_establishment_business_details tbl_establishment_business_details_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tbl_establishment_business_details
    ADD CONSTRAINT tbl_establishment_business_details_pkey PRIMARY KEY (id);
 t   ALTER TABLE ONLY public.tbl_establishment_business_details DROP CONSTRAINT tbl_establishment_business_details_pkey;
       public                 postgres    false    254            �           2606    16577 >   tbl_establishment_categories tbl_establishment_categories_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tbl_establishment_categories
    ADD CONSTRAINT tbl_establishment_categories_pkey PRIMARY KEY (category_id);
 h   ALTER TABLE ONLY public.tbl_establishment_categories DROP CONSTRAINT tbl_establishment_categories_pkey;
       public                 postgres    false    256            �           2606    16583 R   tbl_establishment_construction_details tbl_establishment_construction_details_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tbl_establishment_construction_details
    ADD CONSTRAINT tbl_establishment_construction_details_pkey PRIMARY KEY (id);
 |   ALTER TABLE ONLY public.tbl_establishment_construction_details DROP CONSTRAINT tbl_establishment_construction_details_pkey;
       public                 postgres    false    258            �           2606    16553 8   tbl_establishment_details tbl_establishment_details_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tbl_establishment_details
    ADD CONSTRAINT tbl_establishment_details_pkey PRIMARY KEY (establishment_id);
 b   ALTER TABLE ONLY public.tbl_establishment_details DROP CONSTRAINT tbl_establishment_details_pkey;
       public                 postgres    false    248            �           2606    16589 B   tbl_establishment_work_natures tbl_establishment_work_natures_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tbl_establishment_work_natures
    ADD CONSTRAINT tbl_establishment_work_natures_pkey PRIMARY KEY (work_nature_id);
 l   ALTER TABLE ONLY public.tbl_establishment_work_natures DROP CONSTRAINT tbl_establishment_work_natures_pkey;
       public                 postgres    false    260            �           2606    16510 G   tbl_worker_permanent_address_details tbl_permanent_address_details_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tbl_worker_permanent_address_details
    ADD CONSTRAINT tbl_permanent_address_details_pkey PRIMARY KEY (id);
 q   ALTER TABLE ONLY public.tbl_worker_permanent_address_details DROP CONSTRAINT tbl_permanent_address_details_pkey;
       public                 postgres    false    244            �           2606    16516 C   tbl_worker_present_address_details tbl_present_address_details_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tbl_worker_present_address_details
    ADD CONSTRAINT tbl_present_address_details_pkey PRIMARY KEY (id);
 m   ALTER TABLE ONLY public.tbl_worker_present_address_details DROP CONSTRAINT tbl_present_address_details_pkey;
       public                 postgres    false    246            �           2606    16400    tbl_states tbl_states_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.tbl_states
    ADD CONSTRAINT tbl_states_pkey PRIMARY KEY (state_id);
 D   ALTER TABLE ONLY public.tbl_states DROP CONSTRAINT tbl_states_pkey;
       public                 postgres    false    218            �           2606    16467 *   tbl_trade_of_works tbl_trade_of_works_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.tbl_trade_of_works
    ADD CONSTRAINT tbl_trade_of_works_pkey PRIMARY KEY (trade_work_id);
 T   ALTER TABLE ONLY public.tbl_trade_of_works DROP CONSTRAINT tbl_trade_of_works_pkey;
       public                 postgres    false    236            �           2606    16498 4   tbl_worker_bank_details tbl_worker_bank_details_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.tbl_worker_bank_details
    ADD CONSTRAINT tbl_worker_bank_details_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.tbl_worker_bank_details DROP CONSTRAINT tbl_worker_bank_details_pkey;
       public                 postgres    false    242            �           2606    16461 0   tbl_worker_categories tbl_worker_categories_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY public.tbl_worker_categories
    ADD CONSTRAINT tbl_worker_categories_pkey PRIMARY KEY (category_id);
 Z   ALTER TABLE ONLY public.tbl_worker_categories DROP CONSTRAINT tbl_worker_categories_pkey;
       public                 postgres    false    234            �           2606    16454 0   tbl_worker_dependents tbl_worker_dependents_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.tbl_worker_dependents
    ADD CONSTRAINT tbl_worker_dependents_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.tbl_worker_dependents DROP CONSTRAINT tbl_worker_dependents_pkey;
       public                 postgres    false    232            �           2606    16447 <   tbl_worker_identity_details tbl_worker_identity_details_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.tbl_worker_identity_details
    ADD CONSTRAINT tbl_worker_identity_details_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.tbl_worker_identity_details DROP CONSTRAINT tbl_worker_identity_details_pkey;
       public                 postgres    false    230            �           2606    16441 &   tbl_worker_users tbl_worker_users_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.tbl_worker_users
    ADD CONSTRAINT tbl_worker_users_pkey PRIMARY KEY (worker_user_id);
 P   ALTER TABLE ONLY public.tbl_worker_users DROP CONSTRAINT tbl_worker_users_pkey;
       public                 postgres    false    228            �           2606    16473 2   tbl_worker_work_places tbl_worker_work_places_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.tbl_worker_work_places
    ADD CONSTRAINT tbl_worker_work_places_pkey PRIMARY KEY (work_place_id);
 \   ALTER TABLE ONLY public.tbl_worker_work_places DROP CONSTRAINT tbl_worker_work_places_pkey;
       public                 postgres    false    238            �           2606    16435 ,   tbl_workflow_status tbl_workflow_status_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.tbl_workflow_status
    ADD CONSTRAINT tbl_workflow_status_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.tbl_workflow_status DROP CONSTRAINT tbl_workflow_status_pkey;
       public                 postgres    false    226            �           2606    16421    tbl_zones tbl_zones_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.tbl_zones
    ADD CONSTRAINT tbl_zones_pkey PRIMARY KEY (zone_id);
 B   ALTER TABLE ONLY public.tbl_zones DROP CONSTRAINT tbl_zones_pkey;
       public                 postgres    false    222            j      x������ � �      L   Y   x�3�tt��t,.�,.I�+Qp�������R���|��K�8#��8]�
]RJK*q�2�阒�Y�K�AQ�6�t�D����� ��+7      P   a   x�3�4�LI�)�J4��pH�M���K���H,..�/Jq042���J�L,OLI���4�4202�50�50T0��26�2��342�06��"�=... ��      `      x������ � �      l      x������ � �      n      x������ � �      p   �   x�3�.I,IUp�/K-��M�+����4�4202�50�50R04�22�25�32��05����2�Ъ���ZT�����N�1Ɯ�@�E�9���f�\a�P�Y�NPjqf
И���u��u;���%��9F��� �/c�      r      x������ � �      h      x������ � �      t   �   x���M�0����� �v�D���6Ƅ�Jǔ��� ���^�j]o� ���%��Ų���(Й6I�'��
�
�S�D�����c���>�ͿB��k Y�F�?�e����<o],�;�q�<CE;;�c�?ۦB�/��^�      J      x������ � �      \      x������ � �      b      x������ � �      Z   �   x��ν�0���)�����L.����HiJ���ķ���#&g:�w��s��>3B;<|�	�H��X��0��G3"E\)�p	��/k^
�F�F�B�CUC��$t���'�0!M��ٿ��K��r&����z���������c�^�mn      X      x������ � �      V      x������ � �      d      x������ � �      f      x������ � �      T      x������ � �      ^      x������ � �      R   B   x�3������,�L,IM��2�� 
��E�99�e`&�A�A�Y���1z\\\ ��      N   K   x�3���KU0��4�4202�50�50T0��"#=CS33#�? �2��6"N�1D�1q�M �M�S���� a�&5     