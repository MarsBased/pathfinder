require_relative 'recipes/base'
require_relative 'recipes/airbrake'
require_relative 'recipes/assets'
require_relative 'recipes/bower_rails'
require_relative 'recipes/carrier_wave'
require_relative 'recipes/configuration'
require_relative 'recipes/devise'
require_relative 'recipes/git_ignore'
require_relative 'recipes/postgres'
require_relative 'recipes/pundit'
require_relative 'recipes/redis'
require_relative 'recipes/rollbar'
require_relative 'recipes/sidekiq'
require_relative 'recipes/simple_form'
require_relative 'recipes/status'
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

     add_recipe(Recipes::CarrierWave.new(self)) if @template.yes?('Do you want to use Carrierwave?')
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
     add_recipe(Recipes::Status.new(self))
     add_recipe(Recipes::BowerRails.new(self))
   end

   def call
     ask_for_recipes
     @template.instance_exec(self) do |pathfinder|
       utils = Recipes::Utils.new(self)
       configuration = Recipes::Configuration.new(self)

       remove_file 'Gemfile'
       run 'touch Gemfile'
       add_source 'https://rubygems.org'

       append_file 'Gemfile', "ruby \'#{utils.ask_with_default('Which version of ruby do you want to use?', default: RUBY_VERSION)}\'"

       configuration.gems do
         pathfinder.generate_gems
       end

       after_bundle do
         run 'spring stop'

         configuration.init_file

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
