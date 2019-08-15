# keycloak-docker
Docker image containing Keycloak. Suited for running Keycloak as an ECS task.

## Run
The image is by default configured to run in ECS. If running locally or in any
other environment, set the following environment variable: `IS_LOCAL=true`

Supply Postgres URL, Username and Password parameters as Environement Variables:
- `DB_USERNAME`
- `DB_CONNECTIONURL`
- `DB_PASSWORD`

If you need to set any extra parameters to the Keycloak run script
(standalone.sh), these can be provided by setting the variable
`KEYCLOAK_ARGUMENTS`.

#### Creating initial admin user
There is a script made by Keycloak that must be run to add the initial admin
user. This script produces a json file inside the container that is loaded and
executed on the next restart of the server. 

As such, the easiest way to create the admin user is to :
1. Start a container locally pointing it to the environment database
2. Log into the container
3. Run the script `/home/keycloak/keycloak/bin/add-user-keycloak.sh`
4. Restart the container

After these steps the user will have been created in the database

### Parameter Store Support
The parameters above may also be fetched from SSM Parameter Store if the task
runs on AWS ECS.

The task must have an IAM policy like so:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": [
                "arn:aws:ssm:<REGION>:<ACCOUNT_ID>:parameter/<path>/<to>/<param>/db.username",
                "arn:aws:ssm:<REGION>:<ACCOUNT_ID>:parameter/<path>/<to>/<param>/db.password",
                "arn:aws:ssm:<REGION>:<ACCOUNT_ID>:parameter/<path>/<to>/<param>/db.url"
            ],
            "Effect": "Allow"
        }
    ]
}
```

### Replication
The following environment variable should be set to control replication and
failover behaviour. See
[Replication and Failover](https://www.keycloak.org/docs/3.0/server_installation/topics/cache/replication.html)
- `DISTRIBUTED_CACHE_OWNERS`


## Deployment
This image is intended to be deployed as an ECS Task on AWS. The task should run
with the
[awsvpc](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html)
network mode. This provides the following features:
- Keycloak gets it own ENI (Network Interface).
- May have its own security group separated from other tasks running on the
  Container Instances.

In addition the runapp.sh extracts the containers private IP from the 
[Task Metadata Endpoint](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-metadata-endpoint.html),
this is used to bind the private Keycloak interface, used by clustering/jgroups.

- The Keycloak SG should allow traffic from self on port 7600.
- The Keycloak SG should allow traffic from the Load Balancer SG on port 8080.

# Upgrade guide
Upgrades might require some changes to the `standalone-ha.xml` file. DB
migrations are handled by the application
1. Try upping the version number in the Dockerfile to the new version and start
   the application by running `docker-compose up --scale local=2`.
   This will create two keycloak nodes connecting to the same database.
2. If the application starts without errors, everything is likely fine and the
   new version can be pushed and deployed to a test environment and tested
   further there. _If it is a new major version, you might want to test with a
   clone of the real database if you're afraid or it is inconvenient to break
   the test environment. The simplest way is to create a new RDS instance from a
   snapshot of the database in the test environment and connect to that
   locally._
3. If the application starts with errors, try running the migration scripts
   provided by Keycloak first. It will update the `standalone-ha.xml` file. Run
   the script in `Docker/run-migration-script.sh`. If the script runs
   successfully, the migrated `standalone-ha.xml` will be copied to
   `Docker/standalone-ha-migrated.xml` folder. If the migration script
   gives an error like the following - uncomment the commented https blocks in
   `Docker/toRoot/standalone-ha.xml` and run the script again:
```
Adding https-listener
{
    "outcome" => "failed",
    "failure-description" => "WFLYCTL0369: Required capabilities are not available:
    org.wildfly.network.socket-binding.https; Possible registration points for this capability:
		/socket-binding-group=*/socket-binding=*",
    "rolled-back" => true
}
```

# Custom themes
See the `example` folder for an example of how to extend this image and package
custom themes and other files into a child image.