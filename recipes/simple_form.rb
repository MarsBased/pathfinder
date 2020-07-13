module Recipes
  class SimpleForm < Base

    is_auto_runnable

    def gems
      @template.gem 'simple_form'
    end

    def cook
      add_sample_i18n
    end

    private

    def run_generators
      case ask_framework_for_forms
      when 'marsman'
        @template.initializer 'simple_form.rb',
                              relative_file_content('simple_form/marsman.rb')
      when 'bootstrap'
        @template.generate 'simple_form:install --bootstrap'
      else
        @template.generate 'simple_form:install'
      end
    end

    def add_sample_i18n
      @template.run 'rm config/locales/simple_form.en.yml'
      @template.append_to_file 'config/locales/en.yml',
                               relative_file_content('simple_form/en.yml')
    end

    def simple_form_locale(filename)
      base_path = File.dirname(__FILE__).split('/')
      base_path.pop
      File.read(File.join(base_path, 'recipes', 'simple_form', filename))
    end

  end
end
