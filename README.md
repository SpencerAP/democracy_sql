# democracy_sql

PostgreSQL create + import script for researching the NBC Russian troll tweet dump.

## Background

NBC has [published a database](https://www.nbcnews.com/tech/social-media/now-available-more-200-000-deleted-russian-troll-tweets-n844731) of the deleted Russian troll tweets. There's even a nifty graph database for exploring them, [Neo4j](https://neo4j.com/sandbox-v2/).

But what if you want to explore the data in your own PostgreSQL database? Here is some SQL to create the database and tables, import the CSV files, and convert text data to more convenient formats.

Tested on PostgreSQL 9.3.21, may require adaptation to work with other SQL databases or versions.

## Usage

Download the [tweets.csv](http://nodeassets.nbcnews.com/russian-twitter-trolls/tweets.csv) and [users.csv](http://nodeassets.nbcnews.com/russian-twitter-trolls/users.csv).

Run (as Postgres super user):

`psql -f democracyCreate.sql -v users="'/path/to/users.csv'" -v tweets="'/path/to/tweets.csv'"`

The schema that results will look like:

```
                     Table "public.twitter_user"
      Column      |           Type           | Modifiers 
------------------+--------------------------+-----------
 id               | character varying(18)    | 
 location         | character varying(29)    | 
 name             | character varying(20)    | 
 followers_count  | integer                  | 
 statuses_count   | integer                  | 
 time_zone        | character varying(27)    | 
 verified         | boolean                  | 
 lang             | character varying(2)     | 
 screen_name      | character varying(15)    | 
 description      | character varying(160)   | 
 created_at       | timestamp with time zone | 
 favourites_count | integer                  | 
 friends_count    | integer                  | 
 listed_count     | integer                  | 
Indexes:
    "twitter_user_id_key" UNIQUE CONSTRAINT, btree (id)
Referenced by:
    TABLE "tweet" CONSTRAINT "tweet_twitter_user_fkey" FOREIGN KEY (user_id) REFERENCES twitter_user(id)

                     Table "public.tweet"
        Column         |           Type           | Modifiers 
-----------------------+--------------------------+-----------
 user_id               | character varying(18)    | 
 user_key              | character varying(15)    | 
 created_at            | timestamp with time zone | 
 created_str           | character varying(19)    | 
 retweet_count         | integer                  | 
 retweeted             | boolean                  | 
 favorite_count        | integer                  | 
 text                  | character varying(191)   | 
 tweet_id              | character varying(18)    | 
 source                | character varying(93)    | 
 hashtags              | json                     | 
 expanded_urls         | json                     | 
 posted                | character varying(6)     | 
 mentions              | json                     | 
 retweeted_status_id   | character varying(19)    | 
 in_reply_to_status_id | character varying(21)    | 
Foreign-key constraints:
    "tweet_twitter_user_fkey" FOREIGN KEY (user_id) REFERENCES twitter_user(id)
```


## Example Queries

What tweets were most popular?

```
SELECT twitter_user.name, tweet.text, (tweet.favorite_count + tweet.retweet_count) AS activity_count
FROM twitter_user
JOIN tweet ON twitter_user.id = tweet.user_id
WHERE (tweet.favorite_count IS NOT NULL OR tweet.retweet_count IS NOT NULL)
ORDER BY (tweet.favorite_count + tweet.retweet_count) DESC
LIMIT 10;
```

What Twitter clients do trolls prefer?

```
SELECT source, COUNT(*) FROM tweet
GROUP BY source
ORDER BY COUNT(*) DESC;
```
