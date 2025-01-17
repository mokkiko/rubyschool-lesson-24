require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

def if_barber_exists? db, name
  db.execute('select * FROM Barbers where name=?', [name]).length > 0

end

configure do
  enable :sessions

  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS
		"Users"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"username" TEXT,
			"phone" TEXT,
			"datestamp" TEXT,
			"barber" TEXT,
			"color" TEXT
		)'
  db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"barber_name" TEXT,
			"personal_address" TEXT,
			"work_address" TEXT
		)'

end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end
before do
  db = get_db
  @db_results_barbers =db.execute 'select * from Barbers'
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about'do
  @error = "something wrong"
  db = get_db
  @db_results_barbers =db.execute 'select * from Barbers'
  erb :about
end

get '/contacts'do
  erb :contacts
end

get '/visit'do
  erb :visit
end

post '/visit' do
  @username = params[:username]
  @phone_number = params[:phone_number]
  @user_date = params[:user_date]
  @time1 = Time.new
  @barber = params[:barber]
  @color = params[:color]
  sex = File.open './public/users.txt', 'a'
  sex.write"Новая запись в  #{@time1}\n"
  sex.write"User #{@username}, in chop at #{@user_date} к мастеру #{@barber}  будет краситься в #{@color} ... можете связаться с ним по номеру #{@phone_number}\n"
  sex.close


   error_hash = {
    :username => 'Введите имя',
    :phone_number => 'Введите телефон',
    :user_date => 'Введите дату'
   }
  error_hash.each do |key, value|
    if params[key] == ''
      @error = error_hash[key]
      return erb :visit
    end
  end

  db = get_db
  db.execute 'insert into Users (username, phone, datestamp, barber, color) values (?, ?, ?, ?, ?)', [@username, @phone_number, @user_date, @barber, @color ]
  erb "Уважаемый дргу, #{@username}, вы записались #{@user_date} к мастеру #{@barber}  будет краситься в #{@color}\n"
  #  erb :visit
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

get '/showusers' do
  db = get_db
  @db_results_users = db.execute 'select * from Users order by id desc'
  erb :showusers
end