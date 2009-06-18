require 'rubygems'
require 'sinatra'

require File.dirname(__FILE__) + '/sirb_env'
require File.dirname(__FILE__) + '/helpers'

enable :sessions

before do
  session[:id] = `uuidgen`.strip if session[:id].blank?
  session[:faux_tid] = session[:id].split('-').shift[1..4]
  session[:prompt] = "sirb(main):#{session[:faux_tid]}> "
end

get '/' do
  haml :index
end

get '/stylesheets/style.css' do
  content_type :css
  sass :style
end

post '/sirb' do
  content_type :json
  SIRBServer.execute(session, params['cmd'])
end

get '/sirb_history' do
  content_type :json
  SIRBServer.history(session, params[:page].to_i || 1, params[:per_page].to_i || 10, /#{params['matcher']}/)
end

get '/sirb_prompt' do
  content_type :json
  { :result => session[:prompt] }.to_json
end
