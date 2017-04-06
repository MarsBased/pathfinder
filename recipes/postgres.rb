module Recipes
  class Postgres < Base

    def gems
      @template.gem 'pg'
    end

    def init_file
      @template.inside 'config' do
        @template.remove_file 'database.yml'
        @template.create_file 'database.yml' do <<~EOF
          default: &default
            adapter: postgresql
            encoding: unicode
            pool: 5

          development:
            <<: *default
            database: #{@pathfinder.app_name}_development

          staging:
            <<: *default
            database: #{@pathfinder.app_name}_staging
            username: #{@pathfinder.app_name}
            password: <%= ENV['#{@pathfinder.app_name.upcase}_DATABASE_PASSWORD'] %>

          test:
            <<: *default
            database: #{@pathfinder.app_name}_test

          production:
            <<: *default
            database: #{@pathfinder.app_name}_production
            username: #{@pathfinder.app_name}
            password: <%= ENV['#{@pathfinder.app_name.upcase}_DATABASE_PASSWORD'] %>

            EOF
        end
        @template.append_file 'application.yml.example', "\n#{@pathfinder.app_name.upcase}_DATABASE_PASSWORD: ''"
        @template.append_file 'application.yml', "\n#{@pathfinder.app_name.upcase}_DATABASE_PASSWORD: ''"
      end
      @template.rake 'db:create'
    end
  end
end
