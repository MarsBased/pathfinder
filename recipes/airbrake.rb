module Recipes
  class Airbrake < Base

    def gems
      @template.gem 'airbrake'
    end

    def init_file
      @template.initializer 'airbrake.rb', <<-CODE
        Airbrake.configure do |config|
          config.api_key = ENV['AIRBRAKE_API_KEY']
        end
      CODE

      @template.inside 'config' do
        @template.append_file 'application.yml.example', "\nAIRBRAKE_API_KEY: ''"
        @template.append_file 'application.yml', "\nAIRBRAKE_API_KEY: ''"
      end
    end
  end
end
