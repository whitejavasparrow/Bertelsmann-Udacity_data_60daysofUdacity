-- In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table.
SELECT add_type, COUNT(*)
FROM(
  SELECT RIGHT(website, 3) add_type
  FROM accounts
) sub
GROUP BY add_type

-- There is much debate about how much the name (or even the first letter of a company name) matters. Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number). 
WITH init_table AS (
  SELECT name, LEFT(name, 1) init
  FROM accounts
), count_table AS (
  SELECT name, init, CASE WHEN init in ('1','2','3','4','5','6','7','8','9','0') THEN 'number'
         ELSE 'letter'
         END AS init_category
  FROM init_table
)

SELECT init, COUNT(name)
FROM count_table
GROUP BY init
ORDER BY count DESC

-- Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second group of those company names that start with a letter. What proportion of company names start with a letter?
WITH init_table AS (
  SELECT name, LEFT(name, 1) init
  FROM accounts
), count_table AS (
  SELECT name, init, CASE WHEN init in ('1','2','3','4','5','6','7','8','9','0') THEN 'number'
         ELSE 'letter'
         END AS init_category
  FROM init_table
)

SELECT init_category, COUNT(name)
FROM count_table
GROUP BY init_category
ORDER BY count DESC

-- Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
WITH init_table AS (
  SELECT name, LEFT(name, 1) init
  FROM accounts
), count_table AS (
  SELECT name, init, 
    CASE WHEN init in ('1','2','3','4','5','6','7','8','9','0') THEN 'number'
    ELSE 'letter'
    END AS init_category,
    CASE WHEN UPPER(init) in ('A', 'E', 'I', 'O', 'U') THEN 'vowel'
    ELSE 'others'
    END AS vowel_category
  FROM init_table
)

SELECT vowel_category, COUNT(*)
FROM count_table
GROUP BY vowel_category

-- Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc. 
SELECT primary_poc,
	   LEFT(primary_poc, POSITION(' ' IN primary_poc)) first_part,
       RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)+1) last_part
FROM accounts

-- Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
WITH name_table AS (
  SELECT name, primary_poc,
      LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) first_name,
      RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) last_name
  FROM accounts                                     ), name_table_email AS (
  SELECT name, first_name, last_name, primary_poc,
      LEFT(name, POSITION(' ' IN primary_poc)-1) com_first_name,
      RIGHT(name, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) com_last_name
  FROM name_table
)
            
SELECT LOWER(first_name) || '.' || LOWER(last_name) || '@' || LOWER(com_first_name) || '.com' email_add
FROM name_table_email

-- We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.
WITH name_table AS (
  SELECT name, primary_poc,
      LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) first_name,
      RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) last_name
  FROM accounts                                     ), name_table_email AS (
  SELECT name, first_name, last_name, primary_poc,
      LEFT(name, POSITION(' ' IN primary_poc)-1) com_first_name,
      RIGHT(name, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) com_last_name
  FROM name_table
)
            
SELECT first_name, last_name, LOWER(first_name) || '.' || LOWER(last_name) || '@' || LOWER(com_first_name) || '.com' email_add,
LOWER(LEFT(first_name, 1)) || LOWER(RIGHT(first_name, 1)) || LOWER(LEFT(last_name, 1)) || LOWER(RIGHT(last_name, 1)) || LENGTH(first_name) || LENGTH(last_name) || LOWER(REPLACE(name, ' ', '')) init_pw
FROM name_table_email
