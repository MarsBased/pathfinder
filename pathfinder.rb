require_relative 'configurators'
require_relative 'utils'
require 'tty-prompt'

Dir[File.join(__dir__, 'recipes', '*.rb')].each do |recipe_file|
  require recipe_file
end

class Pathfinder

  attr_reader :template, :app_name, :utils, :prompt, :recipes_list

  def initialize(app_name, template)
    @app_name = app_name
    @template = template
    @prompt = TTY::Prompt.new
    @utils = ::Utils.new(@prompt)
    @recipes_list = []
    @configurators_list = []
  end

  def ask_for_recipes
    ::AutoRunnable.auto_runnables_for_module(::Recipes).each do |recipe|
      add_recipe(recipe.new(self))
    end
  end

  def ask_for_configurators
    add_recipe_from_configurator(Configurators::Monitoring.new(self))
    add_configurator(Configurators::PostgresDatabaseUuids.new(self))
    add_configurator(Configurators::ActiveAdmin.new(self))
    add_configurator(Configurators::FormFramework.new(self))
    add_configurator(Configurators::ImageMagick.new(self))
    add_configurator(Configurators::Sentry.new(self))
  end

  def call
    ask_for_recipes
    ask_for_configurators
    @template.instance_exec(self) do |pathfinder|
      configuration = Recipes::Configuration.new(self)

      remove_file 'Gemfile'
      run 'touch Gemfile'
      add_source 'https://rubygems.org'

      ruby_version = pathfinder.utils.ask_with_default(
        'Which version of ruby do you want to use?',
        RUBY_VERSION)

      append_file 'Gemfile', "ruby '#{ruby_version}'"

      configuration.gems do
        pathfinder.generate_recipes_gems
        pathfinder.generate_configurators_gems
      end

      after_bundle do
        run 'spring stop'

        configuration.cook

        pathfinder.generate_recipes_initializers
      end
    end
  end

  def add_recipe(recipe)
    if recipe.ask?
      @recipes_list << recipe if recipe.ask!
    else
      @recipes_list << recipe
    end

    recipe
  end

  def add_configurator(configurator)
    if configurator.dependent?
      @configurators_list << configurator if configurator.perform?
    else
      @configurators_list << configurator
    end
  end

  def add_recipe_from_configurator(configurator)
    recipe = configurator.recipe
    add_recipe(recipe) if recipe
  end

  def generate_configurators_gems
    configurators_operation(:cook)
  end

  def generate_recipes_gems
    recipes_operation(:gems)
  end

  def generate_recipes_initializers
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
