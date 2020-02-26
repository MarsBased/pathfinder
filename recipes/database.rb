# frozen_string_literal: true

module Recipes
  class Database < Base
    is_auto_runnable

    def gems
      case @template.options.database
      when 'postgresql'
        @template.gem 'pg'
      when 'mysql'
        @template.gem 'mysql2', '>= 0.3.18'
      when 'sqlite3'
        @template.gem 'sqlite3'
      else
        @template.gem 'pg'
      end
    end

    def cook
      @template.rake 'db:create'
    end
  end
end
