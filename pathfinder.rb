require_relative 'recipes'
require_relative 'configurators'

class Pathfinder

  attr_reader :template, :app_name

   def initialize(app_name, template)
     @template = template
     @recipes_list = []
     @configurators_list = []
     @app_name = app_name
   end

   def ask_for_recipes
     add_recipe(Recipes::Database.new(self))
     add_recipe(Recipes::CarrierWave.new(self))
     add_recipe(Recipes::Mailgun.new(self))
     add_recipe_from_configurator(Configurators::Monitoring.new(self))
     add_recipe(Recipes::Assets.new(self))
     add_recipe(Recipes::Devise.new(self))
     add_recipe(Recipes::Pundit.new(self))
     add_recipe(Recipes::GitIgnore.new(self))
     add_recipe(Recipes::Redis.new(self))
     add_recipe(Recipes::Sidekiq.new(self))
     add_recipe(Recipes::SimpleForm.new(self))
     add_configurator(Configurators::FormFramework.new(self))
     add_recipe(Recipes::Status.new(self))
     add_recipe(Recipes::Webpacker.new(self))
     add_recipe(Recipes::Modernizr.new(self))
     add_recipe(Recipes::ActiveAdmin.new(self))
     add_recipe(Recipes::Testing.new(self))
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
         pathfinder.generate_gems_configurations
       end

       after_bundle do
         run 'spring stop'

         configuration.cook

         pathfinder.generate_initializers
       end
     end
   end

   def add_recipe(recipe)
     if recipe.class.ask
       @recipes_list << recipe if @template.yes?(recipe.class.ask)
     else
       @recipes_list << recipe
     end

     recipe
   end

   def add_recipe_from_configurator(configurator)
     recipe = Configurators::Monitoring.new(self).recipe
     add_recipe(recipe) if recipe
   end

   def add_configurator(configurator)
     @configurators_list << configurator
   end

   def generate_gems_configurations
     configurators_operation(:cook)
   end

   def generate_gems
     recipes_operation(:gems)
   end

   def generate_initializers
     recipes_operation(:cook)
   end

   private

   def recipes_operation(method)
     @recipes_list.map(&method.to_sym)
   end

   def configurators_operation(method)
     @configurators_list.map(&method.to_sym)
   end

end
