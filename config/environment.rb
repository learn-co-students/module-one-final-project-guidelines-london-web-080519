require 'bundler'
require "sinatra/activerecord"
require 'faker' 
require 'tty-prompt'
require 'colorize'
require 'pastel'
require 'tty-font'

Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'lib'
require_all 'app'
ActiveRecord::Base.logger = nil