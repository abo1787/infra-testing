#This does not work, but I have to throw in the towel.  I believe I have the right format (a multi-stage build that would create the associated jar file, and then move it to the final image and run it)
#As this app runs successfully if there is a postgresql container running and accessible on local without issue, I figured I should be able to get that functional,
#and then run the gradlew flywayMigrate bootRun command to get the app running.  I have tried a number of different things (This file only contains the last attempt at this point), 
#but I am not able to get the app to run.

#If I had more time to work on this, I'm sure I could figure it out, and I'm sure one of the dozen or so iterations I've done are close haha.
FROM gradle:5.3.0-jdk-alpine AS BUILD
WORKDIR /usr/app/
COPY . . 
EXPOSE 8080
ENTRYPOINT export GRADLE_USER_HOME=`pwd`/gradle; \
    export POSTGRES_HOST="cardinaldevuseast2rdsdb0.cdffknnoh5lg.us-east-2.rds.amazonaws.com"; \
    export POSTGRES_USER="postgres"; \
    export POSTGRES_DB="postgres"; 
CMD ./gradlew flywayMigrate bootRun