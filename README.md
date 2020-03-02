# ft_linux
* My own linux distribution
* Linux-4.12.7
* Using GRUB to Set Up the Boot Process

## Getting Started
```
These instructions will get you a copy of the project up and running on your local machine
for development and testing purposes..... And of course some cool educational hackerISH
stuff if you must 😝
```

### Prerequisites

What things are needed to install the software 😞

* [Download Virtualbox](https://www.virtualbox.org/wiki/Downloads)
```
Download and install virtualbox
```


### Download and Run (To rather build everything instead of downloading 12G, see 'Build and Run')

A step by step series of examples that tell you how to download run the project 🤓

```
1.  Start the virtualbox
```
```
2.  Create a new virtual-machine (new button)
  2.1  Type     : Linux
  2.2  Version  : Linux 4.x (64-bit)
  2.3  FileType : VDI
```
```
3.  Once you've gone through the process of creating a virtual-machine, click on the virtual box and then,
    click on settings.
```
```
4.  You'll now come to realize that a lot of what you just did was unnecessary😂, that's ouwkkyY😏.
```
```
5.  Click on storage and then delete whatever vdi you see there. (This will be the one you just created :(  )
```
* [ft_linux-phjacobs.vdi](https://drive.google.com/file/d/0B-dDfTOAtmmTMHdwZG15QS1Fbkk/view?usp=sharing)
```
6.  Download the ft_linux-phjacobs.vdi
  6.1  This is 12G. I know lol. Sorry :(
  6.2  You can scroll down to `build and run` if you can't download it🙂
  6.3  Don't worry. There is no viruses. We @WeThinkCode_ don't roll like that!🖖🏾
  6.4  You'll see "No preview". Just click on download. And then on download anyway :) #HonorAmongDevelopers🖥
```
```
7.  Now click on "Controller : SATA" and add the ft_linux-phjacobs.vdi  that you just downloaded.
```
```
8.  Once added, click on ok and run 👻
```
```
9.  The login : root
```
```
10.  The Password : 12345
    10.1 😂 😂hahahahah I know. What a super secret password lol.
```

### Build and Run (To rather download everything instead of building it, see 'Download and Run')

A step by step series of examples that tell you how to build and run the project 🤓

```
1.  Start the virtualbox
```
```
2.  Create a new virtual-machine (new button)
  2.1  Type     : Linux
  2.2  Version  : Linux 4.x (64-bit)
  2.3    
  2.4  Give it a good 50G (Dynamic Allocated) space. This is if you want some cool GUI else,
       30G would be just fine
  2.5  FileType : VDI
```
```
3.  Once you've gone through the process of creating a virtual-machine, create another one but
    this time, make the version :: ubuntu (64-bit) and give it a good 15G (Dynamic Allocated) of space.
```
* [Download ubuntu](https://www.ubuntu.com/download/desktop/thank-you?country=ZA&version=17.10&architecture=amd64)
```
4.  After downloaded ubuntu, click on settings -> storage -> Controller : IDE ... then add an optical drive and pick
    the ubuntu image that you just downloaded.
```
```
5.  Before starting the ubuntu virtual machine, click it then one settings.
    Now click on storage -> "Controller : SATA" and add the vdi you created before the ubuntu one.
```
```
6.  You're ready to start ubuntu now.
```
```
7.  once it prompts you to either install or run live. Choose install.
```
```
8.  After ubuntu installed open a terminal.
```
```
9.  run `sudo su -`
```
```
10.  run `apt upgrade && apt update && apt-get install -y vim git gcc gparted`
```
```
11. use gparted to partition the drive you mounted before running ubuntu.
```
```
12. partition it as follows. (this drive will most probably be on sdb)
  BIOS BOOT :: 1mb
  ROOT      :: 15G
  BOOT      :: 30G
  SWAP      :: 4.9G
  
  Try and do it in that oder to avoid later problems. Also, go on youtube and watch some tutorials on
  gparted 🤓
```
```
13. After you partitioned the drive, clone [this repo](https://github.com/phjacobs7AG/ft_linux)
```
```
14. In your terminal, go to the cloned folder then setup/packages_required/
    Run the version_check.sh and make sure all packages are found.
    Just a little hint. To install makeinfo, run `apt-get install texinfo`
```
```
15. After step 14, change directories to setup/steps/
```
```
16. Now run these scripts in the order that they're numbered
```

## PLEEEEAAASE....
* Try and read through the scripts before running them. It's really cool stuff.
* Be smart and follow this book. Only from after you done with step 2. [LFS](http://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html)
* Be cool and email me if you really stuck `phillip@softwarebureau.org || phillip@softwarebureau.org || phillip@hearxgroup.com` 
* Be even cooler and google a lot! Learn! Knowledge is the best drugs ever.
* 

## Authors

* **Phillip Ronald Jacobs** - [phillipjacobs](https://github.com/phillipjacobs)

## License

This project is licensed under the GoWildAndShare License...hahaha!

## Acknowledgments

* Thank You LFS
* Thank You BLFS
* Thank You Google
* Thank You Youtube
* Thank You StackOverflow
* Thank You WeThinkCode_
* Thank You Peers
* Thank You Me
* Thank You Granny, Thank You Grandpa... OuwkkyY this is getting emotional. Good luck lol.
* And I really don't mind helping when you have a problem but try and google first.

* phjacobs@student.42.fr || phjacobs@student.wethinkcode.co.za || phillip@softwarebureau.org || phillip@hearxgroup.com

* Thank You 
