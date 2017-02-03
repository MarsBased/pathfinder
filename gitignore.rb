class Gitignore

  def initialize(template)
    @template = template
  end

  def call
    @template.remove_file '.gitignore'
    @template.create_file '.gitignore', File.open(gitignore_path).read
  end

  private

  def gitignore_path
    File.join(File.dirname(__FILE__), '.gitignore')
  end

end
