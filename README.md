# Pathfinder [![Waffle](https://img.shields.io/badge/Waffle-pathfinder-blue.svg?colorB=78bdf2)](https://waffle.io/MarsBased/pathfinder)

![Pathfinder](https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Mars_pathfinder_panorama_large.jpg/1200px-Mars_pathfinder_panorama_large.jpg)

Rails Template for MarsBased projects.

## Usage

The recommended way to use it is referencing the template directly from the Github repository.

```
rails new new_app -m https://raw.githubusercontent.com/MarsBased/pathfinder-rails/master/template.rb --skip-turbolinks
```

**Note**: You need to have installed Yarn before starting a new project since Rails 5.1 uses it as default JavaScript package manager. You can follow [this installation instructions](https://yarnpkg.com/docs/install).

## How does it work

Usually, Rails templates are being built from a single template file. However, if you want to create more complex templates, managing everything this way is painful.

For this reason, we have organized the project in several recipes that can be applied based on the user feedback.

The template.rb file will first clone the whole Pathfinder repository into a temporary local folder and then will execute itself.

## Contributing

You just need to clone the repository

```git clone git@github.com:MarsBased/pathfinder-rails.git```

make the desired changes and test it locally by using:

```rails new new_app -m pathfinder_local_repo/template.rb --skip-turbolinks```
