FROM jenkins/jenkins:lts-jdk11

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

#skip Jenkins' setup wizard to save time
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false