CREATE VIEW VIEW_USER_INFORMATION
(
 USER_ID, FIRST_NAME,LAST_NAME,
 YEAR_OF_BIRTH,MONTH_OF_BIRTH,DAY_OF_BIRTH,GENDER,
 HOMETOWN_CITY,HOMETOWN_STATE,HOMETOWN_COUNTRY,
 CURRENT_CITY,CURRENT_STATE,CURRENT_COUNTRY,
 INSTITUTION_NAME,PROGRAM_YEAR,PROGRAM_CONCENTRATION,PROGRAM_DEGREE
)
AS
SELECT 
users.user_id, 
users.f_name ,
users.l_name, 
users.y_birth, 
users.m_birth, 
users.day_birth, 
users.gender,
A1.city,
A1.state,
A1.country,
A2.city,
A2.state,
A2.country,
university.name,
has_education.year_graduation,
university.concentration,
university.degree
FROM 
((
	(
		(
			(users 
			FULL OUTER JOIN cur_location c ON users.user_id = c.user_id) 
		FULL OUTER JOIN address A1 ON c.aid = A1.aid)
	FULL OUTER JOIN town_location t ON users.user_id = t.user_id)
FULL OUTER JOIN address A2 ON t.aid = A2.aid)
LEFT OUTER JOIN has_education ON users.user_id = has_education.user_id)
LEFT OUTER JOIN university ON has_education.university_id = university.university_id;

CREATE VIEW VIEW_ARE_FRIENDS
(
	USER1_ID,
	USER2_ID
)
AS
SELECT
friend.user1_id,
friend.user2_id
FROM friend;

CREATE VIEW VIEW_PHOTO_INFORMATION
(
	ALBUM_ID,
	OWNER_ID,
	COVER_PHOTO_ID,
	ALBUM_NAME,
	ALBUM_CREATED_TIME,
	ALBUM_MODIFIED_TIME,
	ALBUM_LINK,
	ALBUM_VISIBILITY,
	PHOTO_ID,
	PHOTO_CAPTION,
	PHOTO_CREATED_TIME,
	PHOTO_MODIFIED_TIME,
	PHOTO_LINK
)
AS
SELECT
album.album_id,
users.user_id,
album.cover_photo_id,
album.album_name,
album.album_created_time,
album.album_modified_time,
album.album_link,
album.album_visibility,
photo.photo_id,
photo.photo_caption,
photo.photo_created_time ,
photo.photo_modified_time,
photo.photo_link
FROM
(
	users INNER JOIN album_belong ab ON users.user_id = ab.user_id )
LEFT OUTER JOIN album ON ab.album_id = album.album_id
LEFT OUTER JOIN album_contain ON album.album_id = album_contain.album_id 
LEFT OUTER JOIN photo ON album_contain.photo_id = photo.photo_id; 

CREATE VIEW VIEW_TAG_INFORMATION
(
	PHOTO_ID,
	TAG_SUBJECT_ID,
	TAG_CREATED_TIME,
	TAG_X_COORDINATE,
	TAG_Y_COORDINATE
)
AS
SELECT
photo_tags_IN.photo_id,
photo_tags_IN.user_id,
photo_tags_IN.tag_created_time,
photo_tags_IN.tag_x_coordinate,
photo_tags_IN.tag_y_coordinate 
FROM photo_tags_IN;

CREATE VIEW VIEW_EVENT_INFORMATION
(
	EVENT_ID,
	EVENT_CREATOR_ID,
	EVENT_NAME,
	EVENT_TAGLINE,
	EVENT_DESCRIPTION,
	EVENT_HOST,
	EVENT_TYPE,
	EVENT_SUBTYPE,
	EVENT_LOCATION,
	EVENT_CITY,
	EVENT_STATE,
	EVENT_COUNTRY,
	EVENT_START_TIME,
	EVENT_END_TIME
)
AS
SELECT
event.event_id,
users.user_id,
event.event_name,
event.event_tagline,
event.event_discription,
event.event_host,
event.event_type,
event.event_subtype ,
event.event_location,
address.city,
address.state,
address.country,
event.event_start_time,
event.event_end_time
FROM
( users INNER JOIN create_event ON users.user_id = create_event.user_id)
LEFT OUTER JOIN event ON event.event_id = create_event.event_id
LEFT OUTER JOIN event_at ON event.event_id = event_at.event_id
LEFT OUTER JOIN address ON address.aid = event_at.aid;  