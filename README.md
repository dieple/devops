# devops -  The below is instructions on how to create a jhipster development image with the cassandra database

to build:
========
$ docker build -t dieple/devops .

to run:
=======
Create a "/apps/sandboxes" folder in your host machine 

mkdir /apps/sandboxes

Run The docker image, with the following options:

The Docker "/apps/sandboxes" folder is shared to the local host machine "/apps/sandboxes" folder
Forward all ports exposed by docker (8080 for Tomcat, 3000 for BrowserSync from the "grunt serve" task, 3001 for the BrowserSync UI, and 22 for SSHD). In the following example we forward the container 22 port to the host 4022 port, to prevent some port conflicts:
sudo docker run -v /apps/sandboxes:/apps/sandboxes -p 8080:8080 -p 3000:3000 -p 3001:3001 -p 4022:22 -t dieple/devops

SSH configuration:
===================
You can now connect to your docker container with SSH. You can connect as "root/devops" or as "devops/devops", and we recommand you use the "devops" user as some of the tool used are not meant to be run by the root user.

Start by adding your SSH public key to the Docker container:

cat ~/.ssh/id_rsa.pub | ssh -p 4022 devops@localhost 'mkdir ~/.ssh && cat >> ~/.ssh/authorized_keys'

You can now connect to the Docker container:

ssh -p 4022 devops@localhost

Creating the project code:
=========================
You can then go to the /apps/sandboxes directory in your container, and start building your app inside Docker:

cd /apps/sandboxes
yo jhipster
 
Follow instructions to create your env with Cassandra DB.


If the following exception occurs, you need to change the owner of the /apps/sandboxes directory. See next step.

...
? (15/15) Would you like to enable translation support with Angular Translate? (Y/n)

/usr/lib/node_modules/generator-jhipster/node_modules/yeoman-generator/node_modules/mkdirp/index.js:89
throw err0;
^
Error: EACCES, permission denied '/jhipster/src'
at Object.fs.mkdirSync (fs.js:653:18)
at sync (/usr/lib/node_modules/generator-jhipster/node_modules/yeoman-generator/node_modules/mkdirp/index.js:70:13)
at sync (/usr/lib/node_modules/generator-jhipster/node_modules/yeoman-generator/node_modules/mkdirp/index.js:76:24)
at Function.sync (/usr/lib/node_modules/generator-jhipster/node_modules/yeoman-generator/node_modules/mkdirp/index.js:76:24)
at JhipsterGenerator.app (/usr/lib/node_modules/generator-jhipster/app/index.js:419:10)
at /usr/lib/node_modules/generator-jhipster/node_modules/yeoman-generator/lib/base.js:387:14
at processImmediate [as _immediateCallback] (timers.js:345:15)

You need to fix the /apps/sandboxes folder to give the "devops" user ownership of the directory:

ssh -p 4022 jhipster@localhost
sudo chown devops /apps/sandboxes

Once your application is created, you can run all the normal grunt/bower/maven commands, for example:

mvn spring-boot:run

Congratulations! You've launched your development env inside Docker!

On your host machine, you should be able to :

Access the running application at http://localhost:8080
Get all the generated files inside your shared folder
As the generated files are in your shared folder, they will not be deleted if you stop your Docker container. However, if you don't want Docker to keep downloading all the Maven and NPM dependencies every time you start the container, you should commit its state.



====================================
Run the cassandra DB image
====================================
docker run --detach --name cassandra dieple/apidocker-cassandra

