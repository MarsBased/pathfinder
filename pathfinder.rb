require_relative 'utils'

class Pathfinder

  attr_reader :template

   def initialize(template)
     @template = template
     @utils = Utils.new(template)
   end

   def call
     @template.instance_eval do
       remove_file 'Gemfile'
       run 'touch Gemfile'
       add_source 'https://rubygems.org'

       append_file 'Gemfile', "ruby \'#{@utils.ask_with_default('Which version of ruby do you want to use?', default: RUBY_VERSION)}\'"

       gem 'rails', Utils.ask_with_default('Which version of rails do you want to use?', default: '4.2.5')

       # DB
       gem 'pg'

       # User Management
       gem 'devise'
       gem 'pundit'

       # Model
       gem 'aasm'
       gem 'keynote'
       gem 'paranoia'

       # Forms
       gem 'simple_form'

       # Searchs
       gem 'ransack' if yes?("Do you want to use Ransack?")
       gem 'kaminari'
       gem 'searchkick' if yes?("Are you going to use ElasticSearch?")

       # Assets
       gem 'bootstrap-sass', '~> 3.3.3'
       gem 'bootstrap-datepicker-rails', '~> 1.6.0' if yes?("Do you want to use Bootstrap datepicker?")
       gem 'font-awesome-sass', '~> 4.3.0'
       gem 'sass-rails', '~> 5.0'
       gem 'modernizr-rails'
       gem 'autoprefixer-rails'
       gem 'compass-rails', '~> 3.0.1'
       gem 'magnific-popup-rails'
       gem 'jquery-rails'
       gem 'uglifier', '>= 1.3.0'
       gem 'sdoc', '~> 0.4.0', group: :doc
       # Assets
       gem 'bower-rails'

       # Jobs
       gem 'redis'
       gem 'sidekiq'
       gem 'sinatra', require: nil

       # File uploads
       if yes?("Do you want to use Carrierwave?")
         @carrierwave_enabled = true
         gem 'carrierwave'
         gem 'fog-aws'
         gem 'mini_magick' if yes?("Are you going to handle images?")
       end


       # Monitoring
       case ask('Choose Monitoring Engine:', limited_to: %w(rollbar airbrake none))
       when 'rollbar'
         gem 'rollbar'
         @monitoring_enabled = :rollbar
       when 'airbrake'
         gem 'airbrake'
         @monitoring_enabled = :airbrake
       else
       end

       # Emails
       gem 'premailer-rails'

       gem_group :development, :test do
         gem 'bundler-audit', require: false
         gem 'byebug'
         gem 'rspec-rails'
         gem 'spring'
         gem 'quiet_assets'
         gem 'figaro'
         gem 'mailcatcher'
         gem 'factory_girl_rails'
         gem 'faker'
         gem 'pry-rails'
         gem 'pry-coolline'
         gem 'pry-byebug'
         gem 'rubocop', require: false
       end

       gem_group :development do
         gem 'spring-commands-rspec', require: false
         gem 'better_errors'
       end

       gem_group :test do
         gem 'simplecov', require: false
         gem 'capybara', require: false
         gem 'capybara-webkit', require: false
         gem 'database_cleaner', require: false
         gem 'fakeredis', require: false
         gem 'poltergeist', require: false
         gem 'shoulda-matchers', require: false
       end

       after_bundle do
         run 'spring stop'

         inside 'config' do
           create_file 'application.yml'
           create_file 'application.yml.example'
           remove_file 'routes.rb'
           create_file 'routes.rb' do <<-RUBY
             Rails.application.routes.draw do
             end
           RUBY
           end
         end

         configure_database
         configure_carrierwave if @carrierwave_enabled

         generate 'rspec:install'

         generate 'simple_form:install'
         generate 'pundit:install'
         insert_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-RUBY
         include Pundit
         RUBY
         end

         generate 'devise:install'
         insert_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do  <<-RUBY
         config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
         config.action_controller.asset_host = 'http://localhost:3000'
         config.action_mailer.asset_host = 'http://localhost:3000'
         config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
         config.action_mailer.delivery_method = :smtp
         config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
         RUBY
         end

         configure_rollbar if @monitoring_enabled == :rollbar
         configure_airbrake if @monitoring_enabled == :airbrake
         configure_redis
         configure_sidekiq
         configure_gitignore


         run 'rails g bower_rails:initialize json'
         configure_bower_resources @bower_packages
         rake 'bower:install'
         rake 'bower:resolve'

       end
     end
   end

end
