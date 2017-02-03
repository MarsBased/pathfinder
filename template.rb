path = if File.exists? @rails_template
          File.dirname(@rails_template)
        else
          @tmp_dir = Dir.mktmpdir
          run "git clone git@github.com:MarsBased/pathfinder.git #{@tmp_dir}"
          @tmp_dir
        end

require(File.join(path, 'pathfinder'))
Pathfinder.new(@app_name, self).call
