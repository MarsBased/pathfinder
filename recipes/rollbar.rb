require_relative 'base'

module Recipes
  class Rollbar < Base

    def gems
      @template.gem 'rollbar'
    end

    def init_file
      @template.initializer 'rollbar.rb', <<-CODE
      Rollbar.configure do |config|
        config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
        config.environment = ENV['ROLLBAR_ENV'] || Rails.env
        config.exception_level_filters.merge!(
          'ActionController::RoutingError': 'ignore'
        )

        if Rails.env.test? || Rails.env.development?
          config.enabled = false
        end
      end
      CODE

      @template.inside 'config' do
        @template.append_file 'application.yml.example', "\nROLLBAR_ACCESS_TOKEN: ''"
        @template.append_file 'application.yml', "\nROLLBAR_ACCESS_TOKEN: ''"
      end
    end
  end
end
