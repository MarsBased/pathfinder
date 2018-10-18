module Recipes
  class Rollbar < Base

    def gems
      @template.gem 'rollbar'
    end

    def cook
      @template.initializer 'rollbar.rb', <<~CODE
      Rollbar.configure do |config|
        config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
        config.environment = ENV['ROLLBAR_ENV'] || Rails.env
        config.exception_level_filters['ActionController::RoutingError'] = 'ignore'

        if Rails.env.test? || Rails.env.development?
          config.enabled = false
        end
      end
      CODE

      @template.append_file '.env.example', "\nROLLBAR_ACCESS_TOKEN=''"
      @template.append_file '.env', "\nROLLBAR_ACCESS_TOKEN=''"
    end
  end
end
