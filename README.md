# devops -  Devops and web developer docker container image

to pull:
========
$ sudo docker pull dieple/devops

to run:
=======
Create a "/apps/sandboxes" folder in your host machine 

mkdir /apps/sandboxes

Run The docker image, with the following options:

The Docker "/apps/sandboxes" folder is shared to the local host machine "/apps/sandboxes" folder
Forward all ports exposed by docker (8080 for Tomcat, 3000 for BrowserSync from the "grunt serve" task, 3001 for the BrowserSync UI, and 22 for SSHD). In the following example we forward the container 22 port to the host 2222 port, to prevent some port conflicts:

sudo docker run --detach -v /apps/sandboxes:/apps/sandboxes -p 8080:8080 -p 3000:3000 -p 3001:3001 -p 2222:22 -t dieple/devops

You need to fix the /apps/sandboxes folder to give the "devops" user ownership of the directory:
sudo chown devops /apps/sandboxes

SSH configuration:
===================
You can now connect to your docker container with SSH. You can connect as "root/devops" or as "devops/devops", and we recommand you use the "devops" user as some of the tool used are not meant to be run by the root user.

Start by adding your SSH public key to the Docker container:

cat ~/.ssh/id_rsa.pub | ssh -p 2222 devops@localhost 'mkdir ~/.ssh && cat >> ~/.ssh/authorized_keys'

You can now connect to the Docker container:

ssh -p 2222 devops@localhost

Creating the project code:
=========================
You can then go to the /apps/sandboxes directory in your container, and start building your app inside Docker:

cd /apps/sandboxes
checkout the your source code from github/bitbucket into this directory
 
Congratulations! You've launched your development env inside Docker!
