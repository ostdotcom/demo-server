# OST Demo Mappy Server

OST Demo Application Server is a sample implementation of a backend-server of a mobile application that uses the OST Wallet SDK. 

## Setup

### 1. Prerequisites 

- RVM : install using [rvm](https://rvm.io/rvm/install)
- Ruby : using rvm above install Ruby with version >= 2.5.3
- Mysql : run local instance or use [AWS RDS](https://aws.amazon.com/rds/)
- Memcache : run local instance using [Memcached](https://memcached.org/) or use [AWS ElastiCache for Memcached](https://aws.amazon.com/elasticache/memcached/)
- Key Management Services : use [AWS KMS](https://aws.amazon.com/kms/) 

### 2. Create configuration file 

Refer to [env.sh.example](env.sh.example) to create a new configuration file (env.sh).

### 3. Populate ENV Variables

From the configuration file created above, populate ENV variables for the processes below to access.

```bash
source env.sh
```

### 4. Run Database Migrations

#### a. Drop existing tables and databases if any. CAUTION.

```bash
rake db:drop:all RAILS_ENV=$RAILS_ENV
```

#### b. Create all the databases.

```bash
rake db:create:all RAILS_ENV=$RAILS_ENV
```

#### c. Run all the migrations.

```bash
rake db:migrate RAILS_ENV=$RAILS_ENV
```

### 5. Start Rails Server

```bash
bin/rails server -e $RAILS_ENV -p 4000
```

NOTE: For Staging / Production environments we would recommend using [Nginx + Passenger](https://www.phusionpassenger.com/library/config/nginx/intro.html)