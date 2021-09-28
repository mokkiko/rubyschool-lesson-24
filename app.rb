require 'rubygems'
require 'sinatra'
#require 'jquery'
#require 'sinatra-reloader'

configure do
  enable :sessions
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

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about'do
  @error = "something wrong"
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
