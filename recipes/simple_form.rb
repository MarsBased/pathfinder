module Recipes
  class SimpleForm < Base

    def gems
      @template.gem 'simple_form'
    end

    def init_file
      run_generators
      add_sample_i18n
    end

    private

    def run_generators
      case ask_framework_for_forms
      when 'marsman'
        @template.initializer 'simple_form.rb', simple_form_template('marsman.rb')
      when 'bootstrap'
        @template.generate 'simple_form:install --bootstrap'
      else
        @template.generate 'simple_form:install'
      end
    end

    def add_sample_i18n
      @template.run 'rm config/locales/simple_form.en.yml'
      @template.append_to_file 'config/locales/en.yml', simple_form_template('en.yml')
    end

    def ask_framework_for_forms
      @template.ask('What framework do you want to use for your forms?',
                    limited_to: %w(marsman bootstrap default))
    end

    def simple_form_template(filename)
      File.read(File.join(File.dirname(__FILE__), 'simple_form', filename))
    end
  end
end
