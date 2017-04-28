CREATE TABLE users
(
	user_id        VARCHAR2(100)  PRIMARY KEY,
	f_name         VARCHAR2(100)  NOT NULL,
	l_name         VARCHAR2(100)  NOT NULL,
	gender         VARCHAR2(100),
	y_birth        number(38),
	m_birth        number(38),
	day_birth      number(38)
);

CREATE TABLE address 
(
	aid       INT   PRIMARY KEY,
	city      VARCHAR2(100),
	state     VARCHAR2(100),
	country   VARCHAR2(100),
	constraint unique_address unique(city, state, country)
);

CREATE SEQUENCE address_sequence
START WITH 1
INCREMENT BY 1;

CREATE TRIGGER address_trigger
BEFORE INSERT ON address
FOR EACH ROW
BEGIN
SELECT address_sequence.nextval into :new.aid from dual;
END;
.
RUN;

CREATE TABLE town_location
(
	aid       INT,
	user_id   VARCHAR2(100),
	PRIMARY KEY(aid, user_id),
	FOREIGN KEY(aid) REFERENCES address, 
	FOREIGN KEY(user_id) REFERENCES users
);


CREATE TABLE cur_location
(
	aid       INT,
	user_id   VARCHAR2(100),
	PRIMARY KEY(aid, user_id),
	FOREIGN KEY(aid) REFERENCES address, 
	FOREIGN KEY(user_id) REFERENCES users
);

CREATE TABLE university
(
	university_id   INT  PRIMARY KEY,
	name            VARCHAR2(100),
	concentration    CHAR(100),
	degree          VARCHAR2(100)
);

CREATE SEQUENCE university_sequence
START WITH 1
INCREMENT BY 1;

CREATE TRIGGER university_trigger
BEFORE INSERT ON university
FOR EACH ROW
BEGIN
SELECT university_sequence.nextval into :new.university_id from dual;
END;
.
RUN;

CREATE TABLE has_education
(
	university_id    INT,
	user_id			 VARCHAR2(100),
	year_graduation  NUMBER(38),
	PRIMARY KEY(university_id, user_id),
	FOREIGN KEY(university_id) REFERENCES university,
	FOREIGN KEY(user_id) REFERENCES users
);

CREATE TABLE message
(
	mid               number(38)  PRIMARY KEY,
	sent_time  		  timestamp(6),
	message_content   VARCHAR2(400)
);

CREATE SEQUENCE message_sequence
START WITH 1
INCREMENT BY 1;

CREATE TRIGGER message_trigger
BEFORE INSERT ON message
FOR EACH ROW
BEGIN
SELECT message_sequence.nextval into :new.mid from dual;
END;
.
RUN; 

CREATE TABLE chat
(
	sender_id    VARCHAR2(100),
	reveive_id   VARCHAR2(100),
	mid          number(38),
	PRIMARY KEY(sender_id, reveive_id, mid),
	FOREIGN KEY(sender_id) REFERENCES users,
	FOREIGN KEY(reveive_id) REFERENCES users,
	FOREIGN KEY(mid) REFERENCES message
);

CREATE TABLE friend
(
	user1_id    VARCHAR2(100),
	user2_id    VARCHAR2(100),
	PRIMARY KEY(user1_id, user2_id),
	check (user1_id != user2_id),
	FOREIGN KEY (user1_id) REFERENCES users,
	FOREIGN KEY (user2_id) REFERENCES users
);

CREATE TRIGGER checkDup
	AFTER INSERT ON friend
	FOR EACH ROW
		DECLARE i NUMBER:=0;
		PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		SELECT COUNT (*) INTO i 
		FROM friend 
		WHERE :new.user1_id = user2_id AND :new.user2_id = user1_id ;
		IF i <> 0 THEN
			DELETE FROM friend WHERE user1_id=:new.user2_id AND user2_id =:new.user1_id; 
			--RAISE_APPLICATION_ERROR(-20001, 'Duplicate friendship');
		END IF;
		COMMIT;
END;
.
RUN;

CREATE TABLE photo(
	photo_id              VARCHAR2(100)  PRIMARY KEY,
	photo_caption         VARCHAR2(2000),
	photo_link            VARCHAR2(2000),
	photo_created_time    TIMESTAMP(6),
	photo_modified_time   TIMESTAMP(6)
);

CREATE TABLE album
(
	album_id              VARCHAR2(100) PRIMARY KEY,
	album_name	          VARCHAR2(100),
	album_created_time    TIMESTAMP(6),
	album_modified_time   TIMESTAMP(6),
	cover_photo_ID        VARCHAR2(100) not null,
	album_link            VARCHAR2(2000),
	album_visibility      VARCHAR2(100),
	constraint visibility_enum check(
		(album_visibility='EVERYONE') OR
		(album_visibility='FRIENDS') OR
		(album_visibility='MYSELF') OR
		(album_visibility='FRIENDS_OF_FRIENDS') OR
		(album_visibility='CUSTOM')
	),
	FOREIGN KEY (cover_photo_ID) REFERENCES photo
);

CREATE TABLE album_belong(
	user_id       VARCHAR2(100),
	album_id      VARCHAR2(100),
	PRIMARY KEY (user_id, album_id),
	FOREIGN KEY (user_id) REFERENCES users,
	FOREIGN KEY (album_id) REFERENCES album
);

CREATE TABLE album_contain(
	album_id        VARCHAR2(100),
	photo_id        VARCHAR2(100),
	PRIMARY KEY (album_id, photo_id),
	FOREIGN KEY (album_id) REFERENCES album,
	FOREIGN KEY (photo_id) REFERENCES photo
);

CREATE TABLE photo_tags_IN(
	photo_id              VARCHAR2(100),
	user_id               VARCHAR2(100),
	tag_created_time      TIMESTAMP(6),
	tag_x_coordinate      number,
	tag_y_coordinate      number,
	PRIMARY KEY (photo_id, user_id),
	FOREIGN KEY (photo_id) REFERENCES photo,
	FOREIGN KEY (user_id) REFERENCES users
);

CREATE TABLE event(
	event_id 				VARCHAR2(100) PRIMARY KEY,
	event_location 	 	    VARCHAR2(200),
	event_tagline    		VARCHAR2(1000),
	event_discription 		VARCHAR2(4000),
	event_type 				VARCHAR2(100),
	event_host 				VARCHAR2(100),
	event_subtype 			VARCHAR2(100),
	event_name 				VARCHAR2(100),
	event_start_time 		TIMESTAMP(6),
	event_end_time 			TIMESTAMP(6)
);

CREATE TABLE create_event(
	event_id          VARCHAR2(100),
	user_id           VARCHAR2(100),
	PRIMARY KEY (event_id, user_id),
	FOREIGN KEY (event_id) REFERENCES event,
	FOREIGN KEY (user_id) REFERENCES users
);

CREATE TABLE event_at(
	aid             INT,
	event_id        VARCHAR2(100),
	PRIMARY KEY (event_id, aid),
	FOREIGN KEY (event_id) REFERENCES event,
	FOREIGN KEY (aid) REFERENCES address
);

CREATE TABLE participate(
	user_id          VARCHAR2(100),
	event_id         VARCHAR2(100),
	confirm_status   VARCHAR2(100),
	PRIMARY KEY (event_id,user_id),
	FOREIGN KEY (event_id) REFERENCES event(event_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);
