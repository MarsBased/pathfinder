module Recipes
  class GitIgnore < Base

    def init_file
      @template.remove_file '.gitignore'
      @template.create_file '.gitignore' do <<-EOF
        !/log/.keep
        *.rdb
        .bundle
        config/application.yml
        config/database.yml
        config/secrets.yml
        config/secrets.*.yml
        log/*
        public/assets
        public/uploads
        tmp
        .DS_Store
        *.sublime-*
        .rvmrc
        stellar.yml
        .rubocop.yml

        # Ignore generated coverage
        /coverage

        # Bower stuff
        vendor/assets/.bowerrc
        vendor/assets/bower.json
        vendor/assets/bower_components
      EOF
      end
    end
  end
end
