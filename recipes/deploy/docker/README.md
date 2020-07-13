
## Docker

Production deploys are managed with Docker. The Dockerfile makes use of some config files that can be found in the `docker` folder.

- **fix_permissions.sh**: Makes the mountable volumes writable for the
application user.
- **rails-env.conf**: Makes env variables visible to Nginx. As the
application is running on Passenger through Nginx, every ENV variable
that needs to reach the application must be defined here.
- **nginx.conf**: Base nginx configuration. The file contains
instructions to tune the application performance.

It's recommended to use Dockerhub (or a private docker repository) to store the application images and then use docker-compose to orchestrate the deployment.

The docker-compose file is not included in the project and needs to be
configured on a project basis.
