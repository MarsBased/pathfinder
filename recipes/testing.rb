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
      @template.gem 'spring-commands-rspec', require: false, group: :development
    end

    def cook
      setup_rspec
      setup_factory_bot
      setup_faker
      setup_fakeredis
      setup_database_cleaner
      setup_simplecov

      setup_example_specs
    end

    private

    def setup_rspec
      @template.generate 'rspec:install'
    end

    def setup_example_specs
      @template.create_file(
        File.join(*RSPEC_UNIT_FOLDERS, 'dependencies_spec.rb')
      ) do |file|
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
    end

    def setup_factory_bot
      Dir.mkdir(File.join(*FACTORIES_FOLDERS))
    end

    def setup_simplecov
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'),
        before: "RSpec.configure do |config|\n"
      ) do
        <<~SIMPLECOV
        require 'simplecov'
        SimpleCov.start 'rails'
        SIMPLECOV
      end
    end

    def setup_fakeredis
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'),
        before: "RSpec.configure do |config|\n"
      ) do
        <<~CONFIG
        require 'fakeredis/rspec'
        CONFIG
      end
    end

    def setup_database_cleaner
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'),
        before: "RSpec.configure do |config|\n"
      ) do
        <<~CONFIG
        require 'database_cleaner'
        CONFIG
      end
    end

    def setup_faker
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'rails_helper.rb'),
        before: "RSpec.configure do |config|\n"
      ) do
        <<~CONFIG
        require 'faker'
        CONFIG
      end
    end
  end
end
