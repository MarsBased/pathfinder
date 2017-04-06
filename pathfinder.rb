require_relative 'recipes/base'
require_relative 'recipes/airbrake'
require_relative 'recipes/assets'
require_relative 'recipes/bower_rails'
require_relative 'recipes/carrier_wave'
require_relative 'recipes/devise'
require_relative 'recipes/git_ignore'
require_relative 'recipes/postgres'
require_relative 'recipes/pundit'
require_relative 'recipes/redis'
require_relative 'recipes/rollbar'
require_relative 'recipes/sidekiq'
require_relative 'recipes/simple_form'
require_relative 'recipes/utils'

class Pathfinder

  attr_reader :template, :app_name

   def initialize(app_name, template)
     @template = template
     @recipes_list = []
     @app_name = app_name
   end

   def add_recipe(recipe)
     @recipes_list << recipe
     recipe
   end

   def generate_gems
     recipes_operation(:gems)
   end

   def generate_initializers
     recipes_operation(:init_file)
   end

   def ask_for_recipes
     add_recipe(Recipes::Postgres.new(self))

     add_recipe(Recipes::CarrierWave.new(self)) if @template.yes?("Do you want to use Carrierwave?")
     aux = case @template.ask('Choose Monitoring Engine:',
                    limited_to: %w(rollbar airbrake none))
           when 'rollbar'
             Recipes::Rollbar.new(self)
           when 'airbrake'
             Recipes::Airbrake.new(self)
           else
           end
     add_recipe(aux) if aux.present?
     add_recipe(Recipes::Assets.new(self))
     add_recipe(Recipes::Devise.new(self))
     add_recipe(Recipes::Pundit.new(self))
     add_recipe(Recipes::GitIgnore.new(self))
     add_recipe(Recipes::Redis.new(self))
     add_recipe(Recipes::Sidekiq.new(self))
     add_recipe(Recipes::SimpleForm.new(self))
     add_recipe(Recipes::BowerRails.new(self))
   end

   def call
     ask_for_recipes
     @template.instance_exec(self) do |pathfinder|
       utils = Recipes::Utils.new(self)

       remove_file 'Gemfile'
       run 'touch Gemfile'
       add_source 'https://rubygems.org'

       append_file 'Gemfile', "ruby \'#{utils.ask_with_default('Which version of ruby do you want to use?', default: RUBY_VERSION)}\'"

       gem 'rails', Rails.version
       # Model
       gem 'aasm'
       gem 'keynote'
       gem 'paranoia' if yes?("Do you want to use Soft Deletes?")
       # Searchs
       gem 'ransack' if yes?("Do you want to use Ransack?")
       gem 'kaminari'
       gem 'searchkick' if yes?("Are you going to use ElasticSearch?")
       # Jobs
       gem 'redis'
       gem 'sidekiq'
       gem 'sinatra', require: nil
       # Emails
       gem 'premailer-rails'

       pathfinder.generate_gems

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

         create_file '.rubocop.yml' do <<~CODE
         inherit_from: https://raw.githubusercontent.com/MarsBased/marstyle/master/ruby/.rubocop.yml
         CODE
         end

         pathfinder.generate_initializers

         generate 'rspec:install'
       end
     end
   end

   private

   def recipes_operation(method)
     @recipes_list.map(&method.to_sym)
   end

end
