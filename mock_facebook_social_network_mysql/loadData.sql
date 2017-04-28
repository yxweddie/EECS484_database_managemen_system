INSERT INTO users (user_id,f_name,l_name,gender,y_birth,m_birth,day_birth) 
	SELECT DISTINCT 
		USER_ID, 
		FIRST_NAME,
		LAST_NAME,
		GENDER,
		YEAR_OF_BIRTH,
		MONTH_OF_BIRTH,
		DAY_OF_BIRTH 
	FROM keykholt.PUBLIC_USER_INFORMATION;

INSERT INTO address(city,state,country)
	SELECT DISTINCT
		CURRENT_CITY,
		CURRENT_STATE,
		CURRENT_COUNTRY
	FROM keykholt.PUBLIC_USER_INFORMATION
	UNION
	SELECT DISTINCT
		HOMETOWN_CITY,
		HOMETOWN_STATE,
		HOMETOWN_COUNTRY
	FROM keykholt.PUBLIC_USER_INFORMATION
	UNION
	SELECT DISTINCT
		EVENT_CITY,
		EVENT_STATE,
		EVENT_COUNTRY
	FROM keykholt.PUBLIC_EVENT_INFORMATION;

INSERT INTO town_location(user_id,aid)
	SELECT DISTINCT
		keykholt.PUBLIC_USER_INFORMATION.USER_ID,
		address.aid
		FROM keykholt.PUBLIC_USER_INFORMATION
		LEFT JOIN address
		ON  (address.city = keykholt.PUBLIC_USER_INFORMATION.HOMETOWN_CITY)
		AND (address.state = keykholt.PUBLIC_USER_INFORMATION.HOMETOWN_STATE)
		AND (address.country = keykholt.PUBLIC_USER_INFORMATION.HOMETOWN_COUNTRY);

INSERT INTO cur_location(user_id,aid)
	SELECT DISTINCT
		keykholt.PUBLIC_USER_INFORMATION.USER_ID,
		address.aid
		FROM keykholt.PUBLIC_USER_INFORMATION
		LEFT JOIN address
		ON  (address.city = keykholt.PUBLIC_USER_INFORMATION.CURRENT_CITY)
		AND (address.state = keykholt.PUBLIC_USER_INFORMATION.CURRENT_STATE)
		AND (address.country = keykholt.PUBLIC_USER_INFORMATION.CURRENT_COUNTRY);

INSERT INTO university(name,concentration,degree)
	SELECT DISTINCT
		INSTITUTION_NAME,
		PROGRAM_CONCENTRATION,
		PROGRAM_DEGREE
	FROM keykholt.PUBLIC_USER_INFORMATION;

INSERT INTO has_education(user_id,year_graduation,university_id)
	SELECT DISTINCT
		keykholt.PUBLIC_USER_INFORMATION.USER_ID,
		keykholt.PUBLIC_USER_INFORMATION.PROGRAM_YEAR,
		university.university_id
		FROM keykholt.PUBLIC_USER_INFORMATION, university
		where(university.name = keykholt.PUBLIC_USER_INFORMATION.INSTITUTION_NAME)
		AND(university.concentration = keykholt.PUBLIC_USER_INFORMATION.PROGRAM_CONCENTRATION)
		AND(university.degree = keykholt.PUBLIC_USER_INFORMATION.PROGRAM_DEGREE);

SET AUTOCOMMIT ON;
INSERT INTO friend(user1_id,user2_id)
	SELECT DISTINCT
		USER1_ID,
		USER2_ID
	FROM keykholt.PUBLIC_ARE_FRIENDS;


INSERT INTO photo(photo_id,photo_caption,photo_link,photo_created_time,photo_modified_time)
	SELECT DISTINCT
		PHOTO_ID,
		PHOTO_CAPTION,
		PHOTO_LINK,
		PHOTO_CREATED_TIME,
		PHOTO_MODIFIED_TIME
	FROM keykholt.PUBLIC_PHOTO_INFORMATION;

INSERT INTO album(album_id,album_name,album_created_time,album_modified_time,
				  cover_photo_ID,album_link,album_visibility)
	SELECT DISTINCT
		ALBUM_ID,
		ALBUM_NAME,
		ALBUM_CREATED_TIME,
		ALBUM_MODIFIED_TIME,
		COVER_PHOTO_ID,
		ALBUM_LINK,
		ALBUM_VISIBILITY
	FROM keykholt.PUBLIC_PHOTO_INFORMATION;

INSERT INTO album_belong(user_id,album_id)
	SELECT DISTINCT
		OWNER_ID,
		ALBUM_ID
	FROM keykholt.PUBLIC_PHOTO_INFORMATION;

INSERT INTO album_contain(album_id,photo_id)
	SELECT DISTINCT
		ALBUM_ID,
		PHOTO_ID
	FROM keykholt.PUBLIC_PHOTO_INFORMATION;

INSERT INTO photo_tags_IN(photo_id,user_id,tag_created_time,tag_x_coordinate,tag_y_coordinate)
	SELECT DISTINCT
		PHOTO_ID,
		TAG_SUBJECT_ID,
		TAG_CREATED_TIME,
		TAG_X_COORDINATE,
		TAG_Y_COORDINATE
	FROM keykholt.PUBLIC_TAG_INFORMATION;

INSERT INTO event(event_id, event_location, event_tagline, event_discription, event_type,
				  event_host, event_subtype, event_name,event_start_time,event_end_time)
	SELECT DISTINCT
		EVENT_ID,
		EVENT_LOCATION,
		EVENT_TAGLINE,
		EVENT_DESCRIPTION,
		EVENT_TYPE,
		EVENT_HOST,
		EVENT_SUBTYPE,
		EVENT_NAME,
		EVENT_START_TIME,
		EVENT_END_TIME
	FROM keykholt.PUBLIC_EVENT_INFORMATION;

INSERT INTO create_event(user_id,event_id)
	SELECT DISTINCT
		EVENT_CREATOR_ID,
		EVENT_ID
	FROM keykholt.PUBLIC_EVENT_INFORMATION;

INSERT INTO event_at(event_id,aid)
	SELECT DISTINCT
		keykholt.PUBLIC_EVENT_INFORMATION.EVENT_ID,
		address.aid
	FROM keykholt.PUBLIC_EVENT_INFORMATION
	LEFT JOIN address
		ON(address.city = keykholt.PUBLIC_EVENT_INFORMATION.EVENT_CITY)
		AND(address.state = keykholt.PUBLIC_EVENT_INFORMATION.EVENT_STATE)
		AND(address.country = keykholt.PUBLIC_EVENT_INFORMATION.EVENT_COUNTRY);