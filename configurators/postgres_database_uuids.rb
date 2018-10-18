module Configurators
  class PostgresDatabaseUuids < Base

    def cook
      return unless is_pg?
      add_migration
      add_initializer
    end

    private

    def add_migration
      @template.generate 'migration enable_extension_for_uuid'
      @template.insert_into_file "db/migrate/#{migration_file_name}",
                                 after: "def change\n" do <<~RUBY
        \s\s\s\senable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
      RUBY
      end
    end

    def add_initializer
      @template.initializer 'generators.rb', <<~CODE
        Rails.application.config.generators do |g|
        \s\sg.orm :active_record, primary_key_type: :uuid
        end
      CODE
    end

    def migration_file_name
      Dir["#{@template.destination_root}/db/migrate/*enable_extension_for_uuid.rb"]
        .first.split('/').last
    end

    def is_pg?
      @template.options.database == 'postgresql'
    end

  end
end
