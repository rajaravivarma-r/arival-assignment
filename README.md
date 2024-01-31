## Docker Instructions
### Image building
#### For development environment
Building the image suitable for development environment (with build tools like compilers and make)
`docker buildx build .`

#### For production environment
`docker buildx build --build-arg BUILD_ENVIRONMENT=production . -t auth-service:latest`

**Note:** In old versions of docker you may have to run `DOCKER_BUILDKIT=1 docker build .`

### Development
#### REPL
* Use `bundle exec irb` to load the console
* Build a new image using `docker compose up --build` after adding a new gem