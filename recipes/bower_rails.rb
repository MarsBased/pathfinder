module Recipes
  class BowerRails < Base

    def gems
      @template.gem 'bower-rails'
    end

    def init_file
      @template.run 'rails g bower_rails:initialize json'
      @template.remove_file 'bower.json'
      @template.create_file 'bower.json' do <<~TEXT
        {
          "lib": {
            "name": "bower-rails generated lib assets",
            "dependencies": { }
          },
          "vendor": {
            "name": "bower-rails generated vendor assets",
            "dependencies": {
          TEXT
          end


          packages = resources.map { |package, version| "\t\t\t\"#{package}\": \"#{version}\"" }
                              .join(",\n")

          @template.append_file 'bower.json', "#{packages}\n" unless packages.empty?
          @template.append_file 'bower.json' do <<~TEXT
            }
          }
        }
      TEXT
      end
      @template.rake 'bower:install'
      @template.rake 'bower:resolve'
    end

    private

    def resources
      [['select2', '4.0.3'], ['lodash', '4.16.6']]
    end
  end
end
