module Recipes
  class Webpacker < Base

    def gems
      @template.gem 'webpacker', '~> 3.0'
    end

    def cook
      @template.run 'rails webpacker:install'
      @template.run "yarn add #{package_command_resources}"
      add_javascript_pack_tag
      config_pack_file
      @template.remove_file 'app/assets/javascripts/application.js'
    end

    private

    def add_javascript_pack_tag
      layout_file = 'app/views/layouts/application.html.erb'
      @template.gsub_file layout_file,
        "<%= javascript_include_tag 'application' %>",
        "<%= javascript_pack_tag 'application' %>"
    end

    def config_pack_file
      require_resources = resources.map(&:first).map { |r| "require('#{r}')" }.join("\n")
      webpack_file = 'app/javascript/packs/application.js'
      @template.remove_file webpack_file
      @template.create_file webpack_file do <<~TEXT
        #{require_resources}
      TEXT
      end
    end

    def package_command_resources
      resources.map { |asset| asset.join('@') }.join(' ')
    end

    def resources
      [['jquery', '3.3.1'],
       ['select2', '4.0.3'],
       ['lodash', '4.16.6'],
       ['webpack-md5-hash','0.0.6']]
    end

  end
end
