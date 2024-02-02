## Docker Instructions
### First time setup
* When setting up the App for the first time, just bring the database service up by running `docker compose up database`. This will init the database and setup the data directory
* In another terminal bring the app service up by running `docker compose run -it auth-service /bin/sh` and run the migrations `bundle exec rake db:migrate`
* After that bring up the web service by running `docker compose up auth-service`
* To bring the REPL run `docker compose run -it auth-service /bin/sh` and inside the container run `bin/console`
* To run background jobs bring redis up by running `docker compose up redis`

#### Database debugging
* To run psql inside the docker container run `docker compose run -it database /bin/bash` and enter the command `psql -U arival --dbname arival_development --host database --port 5432`
* When prompted for the password enter the password specified in the `POSTGRES_PASSWORD` environment variable in the compose file.

#### Database management
* To create a database. This assumes that the default `postgres` database is present which can be accessed using the username and password specified in the database.yaml file.
  * To create development database run `bundle exec rake db:create`.
  * To create test database run `APP_ENV=test bundle exec rake db:create`
* To create a migration file `bundle exec rake db:generate_migration['create_users_table']`
  * Open the migration file and write your migration code

### Image building
#### For development environment
Building the image suitable for development environment (with build tools like compilers and make)
`docker buildx build .`
**Note:** In old versions of docker you may have to run `DOCKER_BUILDKIT=1 docker build .`

### Development
* Build a new image using `docker compose up --build` after adding a new gem

#### Migrations
##### Note
When starting the App for the first time
* Use `bundle exec rake db:migrate`

### Testing
* Create test database using `APP_ENV=test bundle exec rake db:create`
* Migrate the test database using `APP_ENV=test bundle exec rake db:migrate`

## Running background jobs
* Run `bundle exec sidekiq -r ./config/sidekiq_config.rb` in one of the docker containers
