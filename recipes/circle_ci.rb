module Recipes
  class CircleCi < Base

    def cook
      generate_circle_ci_config
    end

    private

    def generate_circle_ci_config
      path = 'https://raw.githubusercontent.com/MarsBased/circleci/master/config/rails/'

      @template.run 'mkdir .circleci'
      @template.run "curl #{path}.circleci/config.yml > ./.circleci/config.yml"
      @template.run "curl #{path}config/database.ci.yml > ./config/database.ci.yml"
    end
  end
end
