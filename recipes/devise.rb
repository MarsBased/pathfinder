module Recipes
  class Devise < Base

    is_runnable

    def gems
      @template.gem 'devise'
    end

    def cook
      @template.generate 'devise:install'
      add_development_env_config
      add_route_config
    end

    private

    def add_development_env_config
      @template.insert_into_file 'config/environments/development.rb',
                                 after: "Rails.application.configure do\n" do <<~RUBY
        \n
        \s\sconfig.action_controller.asset_host = 'http://localhost:3000'
        \s\sconfig.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
        \s\sconfig.action_mailer.delivery_method = :letter_opener_web
        \s\sconfig.action_mailer.asset_host = 'http://localhost:3000'
      RUBY
      end
    end

    def add_route_config
      @template.insert_into_file 'config/routes.rb',
                                 after: "Rails.application.routes.draw do\n" do <<~RUBY
        \s\sif Rails.env.development?
        \s\s\s\smount LetterOpenerWeb::Engine, at: "/letter_opener"
        \s\send
      RUBY
      end
    end

  end
end
