## Docker Instructions
### First time setup
* When setting up the App for the first time, just bring the database service up by running `docker compose up database`. This will init the database and setup the data directory
* In another terminal bring the app service up by running `docker compose run -it auth-service /bin/sh` and run the migrations `bundle exec rake db:migrate`
* After that bring up the web service by running `docker compose up auth-service`
* To bring the REPL run `docker compose run -it auth-service /bin/sh` and inside the container run `bin/console`
* To run background jobs bring redis up by running `docker compose up redis`

## Running background jobs
* Run `bundle exec sidekiq -r ./config/sidekiq_config.rb` in one of the docker containers

## Security
* User passwords are encrypted using `bcrypt` and stored
* TOTP secrets are encrypted using a symmetric key and stored
* Backup codes are encrypted using a symmetric key and stored
* The key used to encrypte the data is 32 bytes long
* The encrypted data is also signed and the salt is stored as a part of the encrypted data. So even if there is a miniscule chance of two users having same TOTP secret or backup codes will not be revealed in case of database leak.

### Secret management
* All local environment container specific configurations are stored in `.env.development` and `.env.test` file, to ease development and testing.
* Secrets like API key to external services are *NOT* added in the .env files. It has to shared via a secured communication channel and stored in `.env.development.local` or `.env.test.local` for local testing purposes. These local .env files are not tracked in git and should never be committed.
* In *production* the environment variables should be injected using `kubernetes vault` or other mechanism during deployment.

## Production
To deploy the app in production environment:
    * Set `APP_ENV` and `RACK_ENV` to `production`
    * Use `docker compose -f compose.yml -f compose-production.yml up` to run in production environment
    * Set proper mount points for the volumes. Ideally the database will be running in a managed instance.
    * Inject all secrets as environment variables using `kubernetes vault` or other mechanism.

## Debugging
### Database debugging
* To run psql inside the docker container run `docker compose run -it database /bin/bash` and enter the command `psql -U arival --dbname arival_development --host database --port 5432`
* When prompted for the password enter the password specified in the `POSTGRES_PASSWORD` environment variable in the compose file.

### Redis debugging
* To inspect redis data, find the container name of the redis instance using `docker ps` and enter the shell environment of that container by running `docker container exec -it <CONTAINER_ID> /bin/sh`.

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
* Run `bundle exec rspec` in one of the docker containers

## Mailing
* Mailing functionality uses mailjet API. The API_KEY and SECRET_KEY pertaining to mailjet are not committed to the repo.
* If you have your own personal mailjet credentials then store them in `.env.development.local` and start the service for development purposes
* Make sure a valid `EMAIL_SENDER` email is set
* The mailjet credentials can be sourced into the container environment directly
**NOTE**: I couldn't test it as my mailjet account was suspended.

## Linting
* Run `bundle exec rubocop` or `bundle exec rubocop -A`(!!will autocorrect the files!!) in one of the docker containers

## Testing
### Register an user
- Send body in this format `{"email":"youremail@domain.com","password":"samplePassword","password_verification":"samplePassword"}`
- Login by posting the JSON `{"email":"youremail@domain.com","password":"samplePassword"}`
- Store the token from the last response
- Enable 2FA
- Look for QR code url in the response and open it
- Add the OTP to any authenticator like Authy
- Login again using `otp` or one of the backup codes
- Now login will not work without `otp`
- Disable 2FA and the login will now work without `otp`
- Enable 2FA again, you will get a new QR code and backup codes
