module Recipes
  class Testing < Base
    RSPEC_ROOT_FOLDER = 'spec'
    FACTORIES_FOLDERS = [RSPEC_ROOT_FOLDER, 'factories']
    RSPEC_UNIT_FOLDERS = [RSPEC_ROOT_FOLDER, 'models']
    RSPEC_SYSTEM_FOLDERS = [RSPEC_ROOT_FOLDER, 'system']

    def gems
      @template.gem_group :test do |group|
        group.gem 'capybara'
        group.gem 'database_cleaner'
        group.gem 'factory_bot_rails'
        group.gem 'faker'
        group.gem "fakeredis"
        group.gem 'poltergeist'
        group.gem 'rspec-rails', '~> 3.7.2'
        group.gem 'simplecov'
        group.gem 'selenium-webdriver'
        group.gem 'shoulda-matchers'
      end
      @template.gem 'puma'
      @template.gem 'spring-commands-rspec', require: false, group: :development
    end

    def init_file
      setup_rspec
      setup_factory_bot
      setup_capybara
      setup_faker
      setup_fakeredis
      setup_database_cleaner
      setup_simplecov

      setup_example_tests
    end

    private

    def setup_rspec
      @template.generate 'rspec:install'
    end

    def setup_example_tests
      @template.create_file(File.join(*RSPEC_UNIT_FOLDERS, 'dependencies_spec.rb')) do |file|
        <<~RSPEC
          require 'rails_helper'

          RSpec.describe 'Dependencies' do
            it('has rspec') { true == true }
            it('has FakeRedis') { expect(FakeRedis).to_not be nil }
            it('has DatabaseCleaner') { expect(DatabaseCleaner).to_not be nil }
            it('has shoulda_matchers') { expect(self).to respond_to :is_expected }
            it('has Faker') { expect(Faker::Robin.quote).to include 'Holy' }
          end
        RSPEC
      end

      @template.create_file(File.join(*RSPEC_SYSTEM_FOLDERS, 'dependencies_system_spec.rb')) do |file|
        <<~RSPEC
        require 'rails_helper'

        RSpec.describe 'System', type: :system do
          it 'has integration tests' do
            visit('/404')

            expect(page).to have_content("The page you were looking for doesn't exist")
          end
        end
        RSPEC
      end
    end

    def setup_factory_bot
      Dir.mkdir(File.join(*FACTORIES_FOLDERS))
    end

    def setup_simplecov
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'), before: "RSpec.configure do |config|\n"
      ) do
        <<~SIMPLECOV
        require 'simplecov'
        SimpleCov.start 'rails'
        SIMPLECOV
      end
    end

    def setup_fakeredis
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'), before: "RSpec.configure do |config|\n"
      ) do
        <<~CONFIG
        require 'fakeredis/rspec'
        CONFIG
      end
    end

    def setup_database_cleaner
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'), before: "RSpec.configure do |config|\n"
      ) do
        <<~CONFIG
        require 'database_cleaner'
        CONFIG
      end
    end

    def setup_shoulda_matchers
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'), before: "RSpec.configure do |config|\n"
      ) do
        <<~CONFIG
        require 'shoulda_matchers'
        CONFIG
      end
    end

    def setup_faker
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'), before: "RSpec.configure do |config|\n"
      ) do
        <<~CONFIG
        require 'faker'
        CONFIG
      end
    end

    def setup_capybara
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'), after: "require 'rspec/rails'\n"
      ) do
        <<~CONFIG
        require 'capybara/rspec'

        Capybara.javascript_driver = :poltergeist
        CONFIG
      end

      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'), after: "RSpec.configure do |config|\n"
      ) do
        <<~CONFIG
        config.include Capybara::DSL

        config.before(:each, type: :system) do
          driven_by :rack_test
        end

        config.before(:each, type: :system, js: true) do
          driven_by :selenium_chrome_headless
        end
        CONFIG
      end
    end
  end
end
