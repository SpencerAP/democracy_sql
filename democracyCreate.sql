CREATE DATABASE democracy;
\c democracy

CREATE TABLE twitter_user (
id              VARCHAR(18),
location        VARCHAR(29),
name            VARCHAR(20),
followers_count VARCHAR(5),
statuses_count  VARCHAR(5),
time_zone       VARCHAR(27),
verified        VARCHAR(5),
lang            VARCHAR(2),
screen_name     VARCHAR(15),
description     VARCHAR(160),
created_at      VARCHAR(40),
favourites_count VARCHAR(5),
friends_count   VARCHAR(5),
listed_count    VARCHAR(5)
);

COPY twitter_user FROM :users DELIMITER ',' CSV HEADER;

UPDATE twitter_user SET id = null WHERE id = '';
ALTER TABLE twitter_user ADD CONSTRAINT twitter_user_id_key UNIQUE (id);

UPDATE twitter_user SET followers_count = null WHERE followers_count = '';
UPDATE twitter_user SET statuses_count = null WHERE statuses_count = '';
UPDATE twitter_user SET favourites_count = null WHERE favourites_count = '';
UPDATE twitter_user SET friends_count = null WHERE friends_count = '';
UPDATE twitter_user SET listed_count = null WHERE listed_count = '';

ALTER TABLE twitter_user ALTER COLUMN followers_count TYPE integer USING (followers_count::integer);
ALTER TABLE twitter_user ALTER COLUMN statuses_count TYPE integer USING (statuses_count::integer);
ALTER TABLE twitter_user ALTER COLUMN favourites_count TYPE integer USING (favourites_count::integer);
ALTER TABLE twitter_user ALTER COLUMN friends_count TYPE integer USING (friends_count::integer);
ALTER TABLE twitter_user ALTER COLUMN listed_count TYPE integer USING (listed_count::integer);

UPDATE twitter_user SET verified = null WHERE verified = '';
ALTER TABLE twitter_user ALTER COLUMN verified TYPE boolean USING (verified::boolean);

UPDATE twitter_user SET created_at = null WHERE created_at = '';
ALTER TABLE twitter_user ALTER COLUMN created_at TYPE timestamp with time zone USING (created_at::timestamp);

CREATE TABLE tweet (
user_id               VARCHAR(18),
user_key              VARCHAR(15),
created_at            VARCHAR(13),
created_str           VARCHAR(19),
retweet_count         VARCHAR(13),
retweeted             VARCHAR(9),
favorite_count        VARCHAR(14),
text                  VARCHAR(191),
tweet_id              VARCHAR(18),
source                VARCHAR(93),
hashtags              VARCHAR(416),
expanded_urls         VARCHAR(4033),
posted                VARCHAR(6),
mentions              VARCHAR(143),
retweeted_status_id   VARCHAR(19),
in_reply_to_status_id VARCHAR(21)
);

COPY tweet FROM :tweets DELIMITER ',' CSV HEADER;

UPDATE tweet SET user_id = null WHERE user_id = '';

UPDATE tweet SET created_at = null WHERE created_at = '';
ALTER TABLE tweet ALTER COLUMN created_at TYPE bigint USING (round(created_at::bigint / 1000));
ALTER TABLE tweet ALTER COLUMN created_at TYPE timestamp with time zone USING (to_timestamp(created_at));

UPDATE tweet SET retweet_count = null WHERE retweet_count = '';
UPDATE tweet SET favorite_count = null WHERE favorite_count = '';

ALTER TABLE tweet ALTER COLUMN retweet_count TYPE integer USING (retweet_count::integer);
ALTER TABLE tweet ALTER COLUMN favorite_count TYPE integer USING (favorite_count::integer);

UPDATE tweet SET retweeted = null WHERE retweeted = '';
ALTER TABLE tweet ALTER COLUMN retweeted TYPE boolean USING (retweeted::boolean);

ALTER TABLE tweet ALTER COLUMN expanded_urls TYPE json USING (expanded_urls::json);
ALTER TABLE tweet ALTER COLUMN hashtags TYPE json USING (hashtags::json);
ALTER TABLE tweet ALTER COLUMN mentions TYPE json USING (mentions::json);

UPDATE tweet SET retweeted_status_id = null WHERE retweeted_status_id = '';
UPDATE tweet SET in_reply_to_status_id = null WHERE in_reply_to_status_id = '';

UPDATE tweet SET source = null WHERE source = '';

ALTER TABLE tweet ADD CONSTRAINT tweet_twitter_user_fkey FOREIGN KEY (user_id) REFERENCES twitter_user(id);
