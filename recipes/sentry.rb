module Recipes
  class Sentry < Base

    def gems
      @template.gem 'sentry-raven'
    end

    def cook
      @template.append_file '.env.sample', "\nSENTRY_DSN=''"
      @template.append_file '.env', "\nSENTRY_DSN=''"
    end

  end
end
