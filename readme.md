# SQL API with Sqlite3

This is an experimental API. Queries are received in SQL. Sqlite3 reduces this SQL queries, and return the response encoded in json (or plain if set this way).

- [SQLite: JSON Functions And Operators](https://www.sqlite.org/json1.html)

_The JSON functions and operators are built into SQLite by default, as of SQLite version 3.38.0 (2022-02-22)._

## Requirements

- [SQLite (version  2.38.0)](https://www.sqlite.org/index.html)
- [Ruby](https://www.ruby-lang.org/en/)
- [Sinatra](http://sinatrarb.com)

## Usage

1. Initialize sqlite3 db and launch service API by executing: `$ ruby run.rb`
2. Then open another Terminal an launch a curl to try it: `$ curl -d "SELECT json_group_object(email, json_object('full_name', full_name, 'created', created)) AS json_result FROM (SELECT * FROM users WHERE created > '02-01-01');" -X POST http://localhost:4567/api`

If you don't want receive the results encoded in json, try this other way:

```sh
$ curl -d "SELECT * from users;" -X POST http://localhost:4567/api
```

## JSON SQLite Sample

- [Shamelessly copied from akehrer/sqlite_to_json.sql](https://gist.github.com/akehrer/481a38477dd0518ec0086ac66e38e0e2)

### Initialize table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL, 
  full_name TEXT NOT NULL, 
  email TEXT NOT NULL, 
  created DATE NOT NULL
);
INSERT INTO users 
VALUES 
(1, "Bob McFett", "bmcfett@hunters.com", "32-01-01"),
(2, "Angus O'Vader", "angus.o@destroyers.com", "02-03-04"),
(3, "Imperator Colin", "c@c.c", "01-01-01");
```

### Query a row
```sql
SELECT 
json_group_object(
	email, 
	json_object('full_name', full_name, 'created', created)
) AS json_result
FROM (SELECT * FROM users WHERE created > "02-01-01");
```
> {"bmcfett@hunters.com":{"full_name":"Bob McFett","created":"32-01-01"},"angus.o@destroyers.com":{"full_name":"Angus O'Vader","created":"02-03-04"}}

### Query several rows
```sql
SELECT 
json_group_array(
	json_object('id', id, 'full_name', full_name, 'created', created, 'email', email)
) AS json_result
FROM (SELECT * FROM users WHERE created > "00-00-00");
```

> [{"id":1,"full_name":"Bob McFett","created":"32-01-01","email":"bmcfett@hunters.com"},{"id":2,"full_name":"Angus O'Vader","created":"02-03-04","email":"angus.o@destroyers.com"},{"id":3,"full_name":"Imperator Colin","created":"01-01-01","email":"c@c.c"}]

## Open SQLite in readonly mode for security

- [Ruby bindings for the SQLite3 embedded database](https://github.com/sparklemotion/sqlite3-ruby)

Open it in read only mode to avoid update from clients.

(Ruby sample)
```ruby
require 'sqlite3'

db = SQLite3::Database.new('json.db', :readonly => true)
db.execute("INSERT INTO users VALUES (3, 'Bob McFett 2', 'bmcfett2@hunters.com', '32-01-02')")
```
> SQLite3::ReadOnlyException (attempt to write a readonly database)

## Sinatra sample 

Open a service with and endpoint in */api* to answer with the execution of the sql recived as the **post** body.

```ruby
require 'sinatra'

post "/api" do
  request.body.rewind  # in case someone already read it
  data = request.body.read
  result = db.execute(data)
  result.to_s
end
```