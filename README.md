## List of files

### Dockerfile

`Dockerfile` extends from jenkins/jenkins:lts

Read more about [jenkins/jenkins](https://hub.docker.com/r/jenkins/jenkins).

### plugins.txt

`plugins.txt` contains a list of all the Jenkins plugins that we need. 3 main plugins are:

- `job-dsl:1.74` allows us to dynamically create jobs using a specific scripting language.
- `workflow-aggregator:2.6` is essentially the Jenkins pipeline plugin which allows you to create pipelines for 
separating your jobs into distinct stages
- `git:3.10.1` in case your repository is located in GitHub
- `authorize-project:1.3.0` is required so that we can trigger jobs as a specific user in order to overcome a security 
constraint within Jenkins.

### build.gradle
#### Plugins
- `base`: overcomes some warnings we get in intellij. Don't worry about it.
- `com.palantir.docker` & `com.palantir.docker-run`
- `pl.allegro.tech.build.axion-release` does proper releasing of your application using `git tags`.

We just need to tell Gradle that the version it uses is derived from axion release plugin:
`project.version = scmVersion.version`

#### Configure `docker` plugin
```groovy
docker {
    name "${project.name}:${project.version}"
    files "plugins.txt"
}
```

#### To be able to run docker image as a container
```groovy
dockerRun {
    name "${project.name}"
    image "${project.name}:${project.version}"
    port '8080:8080'
    clean true
    daemonize false
}
```
`name` is the name of the container
`image` refers to the image we've just created
`port` maps container's port & accessible port in host machine
`clean` means when the container shutdowns, it'll auto remove itself
`daemonize` tells docker to output directly to the console

## Initial Setup

Execute:
```shell
./gradlew docker
./gradlew dockerRun
#or
./gradlew docker dockerrun
```

To check gradle version:
```shell
./gradlew --version
```

To update Gradle version, you can check the latest Gradle version [here](https://gradle.org/releases/)
then either change manually in `gradle/wrapper/gradle-wrapper.properties > distributionUrl` or run
```shell
./gradlew wrapper --gradle-version 7.2 # where 7.2 is the new version
```

### Create (only 1) seed job then manually copy its configuration 

Open jenkins at `localhost:8080`, select `New Item`, enter `seed` as item name, select `Freestyle project`.
In **Source Code Management**, select **Git**, paste in the repository URL, change branch specifier to `*/main`
if need to.

In **Build**, select **Add build step**, then **Process Job DSLs**, select **Look on Filesystem**, in
**DSL Scripts** put `createJobs.groovy`, click **Save**.

While docker is running, grab the job config from the inside of the docker:
```shell
docker cp [CONTAINER ID, first 3 or 4 letter]:/var/jenkins_home/jobs/seed/config.xml seedJob.xml
```

## Issues & solutions

### Control characters in git bash console

If you build in windows git bash and see gradlew printing lots of control characters then set env variable

```shell
TERM=cygwin
```

or you can put the above script in `File > Settings... > Tools > Terminal > Project Settings > Environment Variables`

### No signature of method ... dockerRun()

```shell
A problem occurred evaluating root project 'jenkins-demo'.
> No signature of method: build_bp16sktriuuj44ie1bhy43yz.dockerRun() is applicable for argument types: (build_bp16sktriuuj44ie1bhy43yz$_run_closure2) values: [build_bp16sktriuuj44ie1bhy43yz$_run_closure2@5592814a]
```

If you encounter the above error after running `./gradlew docker`, make sure no typo in `dockerRun` or
its parameters. Previously, I encounter this issue because I miss an **s** in **ports**.