# BOSA

Free Open-Source participatory democracy, citizen participation and open government for cities and organizations

This is the repository for the main application for BOSA, based on [Decidim](https://github.com/decidim/decidim).

It includes specificities for Belgian Federal Government, Regions and Citizen. 

# Tech

## System dependencies

Dependencies required to run the program and the version
- Ruby 2.6.6
- PostgreSQL 12
- Redis 6
- ImageMagick 6+
- NodeJS

## Setup the Development environment

### Setup without docker 

You will need to do some steps before having the app working properly once you've pulled it from git and installed the dependencies:

* make local copy for `.env` based on `.env.example`
* Install the correct version of rails and bundler and install the rails dependencies by running `bundle install`.
* Make sure the postgress user and password are the same as in the .env file `DATABASE_USERNAME` and `DATABASE_PASSWORD`. To do so, you can follow the instruction from [this section](#setup-users-password-of-the-postgres-database)
* create the database by running `bin/rails db:setup`

### Setup user's password of the postgres Database
You will not be able to find the postgres password used in the creation of the database but you can change the password of the existing super user to comply with the password set in `.env` file.
* Get the list of postgres user: `sudo -u postgres psql -c "\du"`
* To change the password of the existing postgres user: 
  1. Retrieve the username in the `Role Name` column from the command above
  2. Edit and run this command by changing "yourusername" with the postgres username (default: postgres) and "yournewpass" with the new password you want to apply:
  ```
  sudo -u postgres psql -c "ALTER USER yourusername WITH PASSWORD 'yournewpass'"
  ```
* You can also access the postgres console by running `sudo -u postgres psql -c` and run any database command line from this new console.

### Setup via docker [Not working anymore]

You will find the instructions to setup the docker environement in this [readme file](./ops/README.md).

#### Structure

There are following files related to docker setup for this project:

* `Dockerfile` - image definition for web app

* `docker-compose.yml` - services definition

* `.ops/.gitconfig` - you can setup here your GITHUB_TOKEN to fetch private repos

* `.ops/Aptfile` - list of project related packages required during build process

#### Build process

* make a proper `.env` to connect to specific service:
```
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_HOST=postgres
DATABASE_PORT=5432
RUBY_VERSION=2.6.6
REDIS_URL=redis://redis:6379/1
```
*  Make local copy for `.ops/.gitconfig` based on the `.ops/gitconfig.example`

* create image for the app: `docker-compose build rails`

* make setup for the db: `docker-compose run rails bin/rails db:setup`

#### Utilities

* run the rails container: `docker-compose up rails`

* run the sidekiq container: `docker-compose up sidekiq`

* run the tests: `docker-compose run -e RAILS_ENV=test rails bin/rspec spec`

* open container: `docker-compose run rails /bin/bash`

## Run the app

### Commands

* start Rails server: `rails s`
* make sure you have Redis service running, otherwise you can start it manually by: `redis-server`
* start sidekiq: `sidekiq`

### Info

Pages available in the browser:
- `localhost:3000` - app
- `localhost:3000/system` - system panel
- `localhost:3000/admin` - admin panel
- `localhost:3000/sidekiq` - sidekiq dashboard
- `localhost:3000/letter_opener` - letter_opener is used to catch the emails on dev env

(!) Note that you need to be logged in as admin to access `/sidekiq` and `/letter_opener` pages.

There are 2 kinds of users in app:
- `system` (`Decidim::System::Admin`) - users used to login only to the system panel
- `admin` or regular user (`Decidim::User` with `admin` attribute set to `true`/`false`) - users used to login to the app

For the first organization `system`, `admin` and regular users are created at `db:setup` phase.
To create more users refer to the next section below.


## Production environment 

### Setup

* Open a Rails console in the server: `bundle exec rails console`
* Create a System Admin user:
```ruby
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```
*. Visit `<your app url>/system` and login with your system admin credentials
*. Create a new organization. Check the locales you want to use for that organization, and select a default locale.
*. Set the correct default host for the organization, otherwise the app will not work properly. Note that you need to include any subdomain you might be using.
*. Fill the rest of the form and submit it.

### [optional] Create an admin user for a brand new organization
It is already done by decidim seeds for default organization,
but when you create a new organization there would be no admin users in it.

```
o = Decidim::Organization.find(_YOUR_ORG_ID_)
user = Decidim::User.new(email: "admin@belighted.com")
password = "decidim123456"
user.update!(
    name: "Admin",
    nickname: 'admin',
    password: password,
    password_confirmation: password,
    organization: o,
    confirmed_at: Time.current,
    locale: I18n.default_locale,
    admin: true,
    tos_agreement: true,
    personal_url: '',
    about: '',
    accepted_tos_version: o.tos_version,
    admin_terms_accepted_at: Time.current
)
user.confirm
```

You're good to go!

## [Old] Staging environment

### Capistrano deployment

You can deploy app via capistrano utils. Currently we support following stages: `staging`.

We have included support for:

* puma management
* sidekiq management via systemd

Commands:

* `bundle exec cap -T` - list of available capistrano tasks
* `DEPLOY_PATH=/home/webuser/bosa USER=webuser WEB_SERVER='xx.xxx.xx.xxx' cap staging deploy` - deploy app to staging
* add `BRANCH=master ... cap staging deploy` - deploy specific branch to staging(default: master)
* to restart sidekiq:
 ```
  ssh webuser@xx.xxx.xx.xxx
  systemctl --user restart sidekiq_bosa.service
```

### Notes about for first deployment

If you intend to seed the database in production, it won't run in the production environment. It relies on Decidim::Faker that is available only on
development.
The procedure will be:
* set the environment as development
* run `bundle exec rake db:setup`
* set the environment back to production

Create a systemd service at user level to control sidekiq
In `/home/[YOUR_USER]/.config/systemd/user`, create a file called for example `sidekiq.service`
Setup the service
Then:
* Enable the service `systemctl --user enable sidekiq.service`
* Reload the daemon `systemctl --user daemon-reload`

Now you are able to start the service with `systemctl --user start sidekiq.service`.

## Deployment

### Requirements for the First Deployment

#### Setup Pritunl
* Install pritunl client on your computer following [this link](https://client.pritunl.com/#install)
* Ask the tech leader of the project to create your profile to connect on the Pritunl VPN
* Link a two step authentification to your profile (you can use google authenticator)
* Import your Pritunl profile to your pritunl client on your computer

### Deployment
* Create a tag on the commit you want to deploy in the master branch. The tag name should follow these conventions:
  - ***Staging***: rc-version_number (ex: rc-0.0.25)
  - ***Production***: version_number (ex: 0.0.25)
* Connect to Bosa Pritunl VPN using your profile.
* Click the `Scan Multibranch Pipeline Now` to check all the new tag created on the github branch.
* Click on the new tag you created.
* Click the `Build Now` button on the left tab.
* Check if the build has correctly been released in production or in staging depending on the tag name starting with `rc` or not.