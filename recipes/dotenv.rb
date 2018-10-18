module Recipes
  class Dotenv < Base

    is_auto_runnable

    def gems
      @template.gem_group :development, :test do |group|
        group.gem 'dotenv-rails'
      end
    end

    def cook
      create_env_file
      create_test_file
    end

    private

    def create_env_file
      secret = "\nMYSECRET=IFoundAliensAndIDidntTellNASA"
      @template.append_file '.env', secret
      @template.append_file '.env.sample', secret
    end

    def create_test_file
      @template.create_file(
        File.join('spec', 'unit' 'dotenv_spec.rb')
      ) do |file|
        <<~RSPEC
          require 'rails_helper'

          RSpec.describe 'Dotenv' do
            it { expect(ENV['MYSECRET']).to eql "IFoundAliensAndIDidntTellNASA" }
          end
        RSPEC
      end
    end
  end
end
