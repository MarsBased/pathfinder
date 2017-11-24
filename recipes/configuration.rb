module Recipes
  class Configuration < Base
    def initialize(template)
      @template = template
    end

    def gems
      @template.gem 'rails', '~> 5.0'
      # Model
      @template.gem 'aasm'
      @template.gem 'keynote'
      @template.gem 'paranoia' if  @template.yes?('Do you want to use Soft Deletes?')
      # Searchs
      @template.gem 'ransack' if  @template.yes?('Do you want to use Ransack?')
      @template.gem 'kaminari'
      @template.gem 'searchkick' if  @template.yes?('Are you going to use ElasticSearch?')
      # Emails
      @template.gem 'premailer-rails'

      yield if block_given?

      @template.gem_group :development, :test do |group|
        group.gem 'bundler-audit', require: false
        group.gem 'byebug'
        group.gem 'rspec-rails'
        group.gem 'spring'
        group.gem 'figaro'
        group.gem 'mailcatcher'
        group.gem 'factory_bot_rails'
        group.gem 'faker'
        group.gem 'listen'
        group.gem 'pry-rails'
        group.gem 'pry-coolline'
        group.gem 'pry-byebug'
        group.gem 'rubocop', require: false
      end

      @template.gem_group :development do |group|
        group.gem 'spring-commands-rspec', require: false
        group.gem 'better_errors'
      end

      @template.gem_group :test do |group|
        group.gem 'simplecov', require: false
        group.gem 'capybara', require: false
        group.gem 'capybara-webkit', require: false
        group.gem 'database_cleaner', require: false
        group.gem 'fakeredis', require: false
        group.gem 'poltergeist', require: false
        group.gem 'shoulda-matchers', require: false
      end
    end

    def init_file
      create_application_yml
      create_routes_file
      set_error_handling
      add_rubocop
    end

    private

    def create_application_yml
      @template.create_file 'config/application.yml'
      @template.create_file 'config/application.yml.example'
    end

    def create_routes_file
      @template.remove_file 'config/routes.rb'
      @template.create_file 'config/routes.rb' do <<~RUBY
        Rails.application.routes.draw do
        end
      RUBY
      end
    end

    def set_error_handling
      @template.insert_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<~RUBY
        \s\smatch '/404', to: 'errors#not_found', via: :all
        \s\smatch '/500', to: 'errors#internal_error', via: :all
      RUBY
      end
      @template.insert_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do <<~RUBY
        \s\s\s\sconfig.exceptions_app = self.routes
      RUBY
      end
      @template.run 'rails g controller errors not_found internal_error --no-assets --skip-routes --no-controller-specs --no-view-specs --no-helper'
      @template.remove_file 'app/controllers/errors_controller.rb'
      @template.copy_file(File.join(File.dirname(__FILE__), 'controllers', 'errors_controller.rb'), 'app/controllers/errors_controller.rb')
    end

    def add_rubocop
      @template.create_file '.rubocop.yml' do <<~CODE
      inherit_from: https://raw.githubusercontent.com/MarsBased/marstyle/master/ruby/.rubocop.yml
      CODE
      end
      @template.run 'rubocop public'
      @template.remove_file '.rubocop.yml'
      @template.run 'mv .rubocop-https---raw-githubusercontent-com-MarsBased-marstyle-master-ruby--rubocop-yml .rubocop.yml'
    end

  end
end
