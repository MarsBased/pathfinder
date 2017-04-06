module Recipes
  class Devise < Base

    def gems
      @template.gem 'devise'
    end

    def init_file
      @template.generate 'devise:install'
      @template.insert_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do  <<~RUBY
      \tconfig.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
      \tconfig.action_controller.asset_host = 'http://localhost:3000'
      \tconfig.action_mailer.asset_host = 'http://localhost:3000'
      \tconfig.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
      \tconfig.action_mailer.delivery_method = :smtp
      \tconfig.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
      RUBY
      end
    end
  end
end
