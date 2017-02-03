class Loader
  def load(path)
    require File.join(path, 'utils')
  end
end
