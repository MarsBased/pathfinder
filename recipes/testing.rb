module Recipes
  class Testing < Base
    RSPEC_ROOT_FOLDER = 'spec'
    FACTORIES_FOLDERS = [RSPEC_ROOT_FOLDER, 'factories']
    RSPEC_FOLDERS = [RSPEC_ROOT_FOLDER, 'features']
    EXAMPLE_SPEC_FILE = 'spec_spec.rb'

    def gems
      @template.gem_group :test do |group|
        group.gem 'rspec-rails'
        group.gem 'factory_bot_rails'
        group.gem 'simplecov', require: false
        # group.gem 'capybara', require: false
        # group.gem 'capybara-webkit', require: false
        # group.gem 'database_cleaner', require: false
        # group.gem 'fakeredis', require: false
        # group.gem 'poltergeist', require: false
        # group.gem 'shoulda-matchers', require: false
      end

      @template.gem 'spring-commands-rspec', require: false, group: :development
    end

    def init_file
      setup_rspec
      setup_factory_bot
      setup_simplecov
    end

    private

    def setup_rspec
      @template.generate 'rspec:install'

      @template.create_file(File.join(*RSPEC_FOLDERS, EXAMPLE_SPEC_FILE)) do |file|
        <<~RSPEC
          RSpec.describe 'Specs' do
            it { true == true }
          end
        RSPEC
      end
    end

    def setup_factory_bot
      Dir.mkdir(File.join(*FACTORIES_FOLDERS))
    end

    def setup_simplecov
      30.times { puts File.join(RSPEC_ROOT_FOLDER, 'spec_helper.rb')}
      @template.insert_into_file(
        File.join(RSPEC_ROOT_FOLDER, 'spec_helper.rb'),
        before: "RSpec.configure do |config|\n"
      ) do
        <<~SIMPLECOV
        require 'simplecov'
        SimpleCov.start 'rails'
        SIMPLECOV
      end


    end
  end
end
