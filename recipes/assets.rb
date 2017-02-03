require_relative 'base'

module Recipes
  class Assets < Base

    def gems
      # Assets
      @template.gem 'bootstrap-sass', '~> 3.3.3'
      @template.gem 'bootstrap-datepicker-rails', '~> 1.6.0' if @template.yes?("Do you want to use Bootstrap datepicker?")
      @template.gem 'font-awesome-sass', '~> 4.3.0'
      @template.gem 'sass-rails', '~> 5.0'
      @template.gem 'modernizr-rails'
      @template.gem 'autoprefixer-rails'
      @template.gem 'compass-rails', '~> 3.0.1'
      @template.gem 'magnific-popup-rails'
      @template.gem 'jquery-rails'
      @template.gem 'uglifier', '>= 1.3.0'
      @template.gem 'sdoc', '~> 0.4.0', group: :doc
    end
  end
end
