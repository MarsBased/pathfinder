require_relative 'base'

module Recipes
  class SimpleForm < Base

    def gems
      # Forms
      @template.gem 'simple_form'
    end

    def init_file
      @template.generate 'simple_form:install'
    end
  end
end
