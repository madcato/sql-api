require 'sinatra'
require 'sqlite3'

$database_file_path = 'json.db'
$table_file_path = 'table.sql'
$seed_file_path = 'seed.sql'

def read(file_path)
  file = File.open(file_path)
  data = file.read
  file.close
  return data
end

def initialize_db
  table_data = read($table_file_path)
  seed_data = read($seed_file_path)
  db = SQLite3::Database.new($database_file_path)
  db.execute(table_data)
  db.execute(seed_data)
  db.close
end

initialize_db unless File.exist?($database_file_path)

db = SQLite3::Database.new($database_file_path, :readonly => true)

get '/' do
  'Hello world!'
end

post "/api" do
  data = request.body.read
  result = db.execute(data)
  result.to_s
end