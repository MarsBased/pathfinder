if Rails.version[0].to_i < 5
  puts ''
  puts "\e[31mPathfinder only works with Rails versions greater or equal to 5.0.\e[0m"
  exit
end

path = if File.exists? @rails_template
          File.dirname(@rails_template)
        else
          @tmp_dir = Dir.mktmpdir
          run "git clone git@github.com:MarsBased/pathfinder.git #{@tmp_dir}"
          @tmp_dir
        end

require(File.join(path, 'pathfinder'))
Pathfinder.new(@app_name, self).call
