module Recipes
  class CarrierWave < Base

    is_auto_runnable

    askable 'Do you want to use Carrierwave?'
    is_confirmable

    def gems
      @template.gem 'carrierwave'
      @template.gem 'fog-aws'
    end

    def cook
      @template.initializer 'carrierwave.rb', <<~CODE
      require 'carrierwave/storage/fog'
      CarrierWave.configure do |config|
        config.fog_provider = 'fog/aws'
        config.fog_directory = ENV['AWS_S3_BUCKET']
        config.fog_public = true
        config.storage = :fog
        config.cache_dir = Rails.root.join('tmp', 'cache')

        config.fog_credentials = {
          provider: 'AWS',
          aws_access_key_id: ENV['AWS_ACCESS_KEY'],
          aws_secret_access_key: ENV['AWS_SECRET_KEY'],
          region: 'eu-west-1'
        }
      end
      CODE

      @template.append_file '.env.example', "\nAWS_ACCESS_KEY=''"
      @template.append_file '.env', "\nAWS_ACCESS_KEY=''"
      @template.append_file '.env.example', "\nAWS_SECRET_KEY=''"
      @template.append_file '.env', "\nAWS_SECRET_KEY=''"
      @template.append_file '.env.example', "\nAWS_S3_BUCKET=''"
      @template.append_file '.env', "\nAWS_S3_BUCKET=''"
    end

  end
end
