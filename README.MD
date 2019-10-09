![alt text](https://www.drupal.org/files/styles/grid-3-2x/public/project-images/thunder-logo.png)  
This repository contains components for running and deploying your Drupal 8 (Thunder) application in OpenShift cluster.

Thunder is a Drupal 8 distribution for professional publishing. It consists of the current Drupal 8 functionality, lots of handpicked publisher-centric modules with custom enhancements, and an environment which makes it easy to install, deploy and add new functionality.

For deploying Thunder and Jenkins in OpenShift cluster check SSH key in the mshift.sh and run script mshift.sh

```bash
./mshift.sh <app namespace> <jenkins namespace>
```
or

```bash
./mshift.sh 
```
Default namespaces for Thunder app "thunder", for Jenkins "jenkins-ci"

If namespaces exist script asks you overwrite or no.

**"[Deploy monitoring in Openshift](https://github.com/Arnio/docker_thunder/tree/master/monitoring)"**

 
 
![alt text](https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/OpenShift-LogoType.svg/200px-OpenShift-LogoType.svg.png)



