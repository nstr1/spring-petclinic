FROM adoptopenjdk/openjdk11:jre-11.0.6_10-alpine
COPY src/target/*.jar /opt/petclinic/petclinic.jar

ENTRYPOINT [ "/opt/java/openjdk/bin/java", "-jar", "/opt/petclinic/petclinic.jar"]
