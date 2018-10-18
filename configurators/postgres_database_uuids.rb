module Configurators
  class PostgresDatabaseUuids < Base

    is_auto_runnable

    def cook
      return unless is_pg?
      @template.generate 'migration enable_extension_for_uuid'
    end

    private

    def is_pg?
      @template.options.database == 'postgresql'
    end

  end
end
