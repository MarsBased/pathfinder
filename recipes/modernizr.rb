module Recipes
  class Modernizr < Base

    askable 'Do you want to use Modernizr?'

    def gems
      @template.gem 'modernizr-rails'
    end

    def cook
      add_javascript_modernizr_tag
    end

    private

    def add_javascript_modernizr_tag
      layout_file = 'app/views/layouts/application.html.erb'
      @template.insert_into_file layout_file,
        after: "<%= stylesheet_link_tag    'application', media: 'all' %>\n" do <<~CODE
        \s\s\s\s<%= javascript_include_tag 'modernizr' %>
      CODE
      end
    end

  end
end
