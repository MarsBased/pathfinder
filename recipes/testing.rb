module Recipes
  class Testing < Base
    FACTORIES_FOLDER = 'factories'
    RSPEC_FOLDERS = %w[spec features]
    EXAMPLE_SPEC_FILE = 'spec_spec.rb'

    def gems
      @template.gem_group :test do |group|
        group.gem 'rspec-rails'
        group.gem 'factory_bot_rails'

        # group.gem 'simplecov', require: false
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
      @template.generate 'rspec:install'
      Dir.mkdir(FACTORIES_FOLDER)
      @template.create_file(File.join(*RSPEC_FOLDERS, EXAMPLE_SPEC_FILE)) do |file|
        <<~RSPEC
          RSpec.describe 'Specs' do
            it { true == true }
          end
        RSPEC
      end
    end
  end
end
