### Nightly-debian-jessie
Docker Container with supervisor which downloads the latest master and initializes only php-fpm instance based on php7

Why another one ? I don't use Ubuntu and I'm not a fan of having to many services in a container -> the idea is to have the **PHP-FPM listen to the port 8099** on the outside and the **path/to/the/project mounted on the inside** so I can choose whatever server on the outside I'd like.

## FYI about Docker 
First of all this is Docker <-> it's based on LXC which means it's a virtualisation within the linux kernel. 

This is not like Vagrant which is a Batch System to store states / versions of complete hybrid virtualisations. 

Docker is as mentioned before a linux container (lxc). Hence needs less resources but does not support Windows or Mac on a native lvl for more information please check [http://boot2docker.io/ ](http://boot2docker.io/ ) as a Mac user as a windows user I'm sorry afaik you need a VM <-> I would recommend Ubuntu since the packages for ubuntu are compiled and maintained by the zend guys.

Please do not mistake a service container with a complete virtualisation like VBOX or VM, ..

## FYI PHP7 
PHP 7 atm (**2015-05-10**) is as we all should know still in Development so a lot of external extensions are not working due to the renaming of c header files and changing of the inner structure. So the compilation is ending in fatal errors. I tried it with **redis**, **mongo** and **memcached**

During the compilation there are several errors which I ignored.

## Configurations
I compiled it manually you can have a look about the configuration settings (./configure) at the following sources [phpinternals](http://www.phpinternalsbook.com/build_system/building_php.html) or [php.net](http://php.net/manual/en/configure.about.php) and ofc the bash approach `./configure --help | less`

## Supervisor 
Since Docker is not Vagrant the processes can not simply be put in the init.d or system.d structure and triggered. Many other boxes use internal batches I followed the OPs approach and used the supervisor. 

You can have a look at the supervisord.conf and see how a rather lazy approach has been done. Which is less work than copying batch files and trigger them via bashrc or other approaches. Taste I guess.

## FPM 
The FPM config **php-fpm.conf** is only setting the pid folder and the error folder.
The **User and Group** which for the workers are in the **www.conf** as well as the **listenport 8080** on the inside. 

Since I don't expect a lot of OPs knowledge from a common Dev (the have other concerns) this is already pre-configured and listens to the 8099 port on your host machine.

I didn't want to bother with doing the socket approach which would require more detailed knowledge of the user. 
Although it's pretty easy once you understand the [docker basics](https://docs.docker.com/articles/basics/)
Please do use it I wanted to keep this accessible for people who just want to code.

There are a lot of .inis which have no use since you can't compile the extensions still i left them in there because who know's what's in 2-3 Months.

## General Knowledge

** It's important that your data is accessible in the Container **
`-v /var/www:/var/www <nameofyourchoosing>`
this is a basic mapping of the outside to the inside <-> make sure it has the proper permissions 
go with www-data this the common apache / nginx user|group and is available within debian. 

if you really don't have a clue and this is your private machine (VM) just change the mod of all files to 0777 this is the admin nightmare but the usual Dev solution.

this is a basic setup that should work with every linux version that supports docker **except the packages | apt vs yum vs rpm ...**

`docker run -p 127.0.0.1:8099:8080` maps your localhost:8099 to the internal container port 8080 if you change the fpm config please do not forget to adapt this setting you can use autoport mapping :) please consult the [docker basics](https://docs.docker.com/articles/basics/) 

I added an nginx example and an Apache2.4 example and ofc the basics to create / start / access Docker in the tl;dr section.

***

# TL;DR
Basic usage
inside the repos root dir:

`docker build -t <nameofyourchoosing> .`

then

`docker run -d -p 127.0.0.1:8099:8080  -v /var/www:/var/www <nameofyourchoosing>`

**127.0.0.1:8099:8080 -> 8099 is the port on the outside**
**-v /inside/docker:/outside/docker**
** -d deamonize **

to check if it's running
`docker ps`

to login as root into the bash
`docker exec -it <containerID> bash`

to get nginx to pipe the request to php-fpm

      `  location ~ [^/]\.php(/|$) {`
                `fastcgi_split_path_info ^(.+?\.php)(/.*)$;`
                `# NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini`
                `if (!-f $document_root$fastcgi_script_name) {`
                        `return 404;`
                `}`

                `# With php5-cgi alone:`
                `fastcgi_pass 127.0.0.1:8099;`
                `fastcgi_index index.php;`
                `include fastcgi_params;`
        `}`

to get the apache2.4
those two modules need to be loaded !
#
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
#
inside the virtualhost
ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:8099/path/to/your/documentroot/$1
DirectoryIndex /index.php



And now to the glosar of all pages consulted or used during the last 24 hours building this container 
### apache
* https://wiki.apache.org/httpd/PHP-FPM
* http://httpd.apache.org/docs/current/mod/core.html

### php
* https://github.com/php-memcached-dev/php-memcached <-> compilation error
* http://pecl.php.net/package/memcached
* http://www.sohailriaz.com/how-to-install-memcached-with-memcache-php-extension-on-centos-5x/
* https://github.com/phpredis/phpredis
* https://github.com/mongodb/mongo-php-driver.git
* http://www.phpinternalsbook.com/build_system/building_php.html 
* http://php.net/manual/en/configure.about.php
* http://gediminasm.org/post/compile-php
* http://php.net/manual/en/install.fpm.configuration.php
* http://php.net/manual/de/configuration.php
* http://superuser.com/questions/408294/how-can-i-enable-readline-for-php-5-4-on-ubuntu-11-10
* http://php.net/manual/en/install.unix.nginx.php
* https://github.com/php/php-src
* https://github.com/drj-io/php7-debian-build
* http://repos.zend.com/zend-server/early-access/php7/
* https://git.php.net/
* https://drive.google.com/file/d/0B3UKOMH_4lgBUTdjUGxIZ3l1Ukk/view
* https://wiki.php.net/phpng-int

###docker
* https://docs.docker.com/userguide/dockervolumes/
* http://nathanleclaire.com/blog/2014/07/12/10-docker-tips-and-tricks-that-will-make-you-sing-a-whale-song-of-joy/
* https://coreos.com/docs/launching-containers/building/customizing-docker/
* https://docs.docker.com/articles/using_supervisord/
* http://boot2docker.io/
* https://github.com/docker/docker/blob/master/docs/sources/articles/dockerfile_best-practices.md
* https://docs.docker.com/reference/builder/#expose
* https://github.com/likol/docker-php7-fpm
* https://docs.docker.com/userguide/dockerizing/
* https://docs.docker.com/articles/networking/
* https://docs.docker.com/reference/commandline/cli/
* http://geoffrey.io/a-php-development-environment-with-docker.html
* https://github.com/janatzend/docker-php7-nightly-build

### system.d
* https://github.com/systemd/php/blob/master/php-fpm.service


I hope I helped at least one person otherwise at least I learned something new :)


