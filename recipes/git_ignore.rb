module Recipes
  class GitIgnore < Base

    def init_file
      @template.remove_file '.gitignore'
      @template.create_file '.gitignore', File.open(gitignore_path).read
    end

    private

    def gitignore_path
      File.join(File.dirname(__FILE__), '..', '.gitignore')
    end

  end
end
