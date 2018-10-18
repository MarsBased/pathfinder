module Recipes
  class Airbrake < Base

    def gems
      @template.gem 'airbrake'
    end

    def cook
      @template.initializer 'airbrake.rb', <<~CODE
      Airbrake.configure do |config|
        config.project_id = ENV['AIRBRAKE_PROJECT_ID']
        config.project_key = ENV['AIRBRAKE_PROJECT_KEY']
        config.root_directory = Rails.root
        config.logger = Rails.logger
        config.environment = Rails.env
        config.ignore_environments = %w(test)
        config.blacklist_keys = [/password/i, /authorization/i]
      end
      CODE

      @template.append_file '.env.example', "\nAIRBRAKE_PROJECT_ID=''"
      @template.append_file '.env.example', "\nAIRBRAKE_PROJECT_KEY=''"
      @template.append_file '.env', "\nAIRBRAKE_PROJECT_ID=''"
      @template.append_file '.env', "\nAIRBRAKE_PROJECT_KEY=''"
    end
  end
end
