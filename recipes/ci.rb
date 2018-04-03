module Recipes
  class Ci < Base
    def cook
      run_generators
    end

    private

    def run_generators
      case @template.ask('Do you want to use a CI?',
                         limited_to: %w[circleci none])
      when 'circleci'
        generate_circle_ci_config
      when 'none'
        puts '* Skip CI configuration'
      else
        run_generators
      end
    end

    def generate_circle_ci_config
      @template.run 'mkdir .circleci'
      @template.run 'curl https://raw.githubusercontent.com/MarsBased/circleci/master/config/rails/.circleci/config.yml > ./.circleci/config.yml'
      @template.run 'curl https://raw.githubusercontent.com/MarsBased/circleci/master/config/rails/config/database.ci.yml > ./config/database.ci.yml'
    end
  end
end
