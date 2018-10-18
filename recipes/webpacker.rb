module Recipes
  class Webpacker < Base

    is_auto_runnable

    def gems
      @template.gem 'webpacker', '~> 3.5'
    end

    def cook
      @template.run 'rails webpacker:install'
      @template.run "yarn add #{package_command_resources}"
      add_javascript_pack_tag
      config_pack_file
      config_webpack_env_files
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
      require_resources = application_js_resources.map { |r| "import '#{r}';" }.join("\n")
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

    def application_js_resources
      ['babel-polyfill', 'jquery/src/jquery', 'select2', 'lodash', 'webpack-md5-hash']
    end

    def config_webpack_env_files
      config_base_env
    end

    def config_base_env
      @template.remove_file 'config/webpack/environment.js'
      @template.create_file 'config/webpack/environment.js' do <<~TEXT
        const { environment } = require('@rails/webpacker')
        const webpack = require('webpack')

        environment.plugins.prepend(
          \s\s'Provide',
          \s\snew webpack.ProvidePlugin({
            \s\s\s\s$: 'jquery',
            \s\s\s\sjQuery: 'jquery',
            \s\s\s\sjquery: 'jquery'
          \s\s})
        )

        const config = environment.toWebpackConfig()

        config.resolve.alias = {
          \s\sjquery: "jquery/src/jquery"
        }

        module.exports = environment
      TEXT
      end
    end

  end
end
