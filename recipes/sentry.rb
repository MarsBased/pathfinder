module Recipes
  class Sentry < Base

    def gems
      @template.gem 'sentry-raven'
    end

    def cook
      @template.inside 'config' do
        @template.append_file 'application.yml.example', "\nSENTRY_DSN: ''"
      end
    end

  end
end
