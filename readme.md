##WebLogic 12.1.3 infra (JRF) with SOA plus Oracle Database 12.1.0.1 on 1 machine
with OSB & SOA with BPM, BAM, B2B & Enterprise schedular

### Details
- Oracle Linux 6.6 vagrant box
- Puppet 3.7.3
- Vagrant >= 1.65
- Oracle Virtualbox >= 4.3.18

Download & Add the all the Oracle binaries to /software

edit Vagrantfile and update the software share to your own local folder
- soa.vm.synced_folder "/Users/edwin/software", "/software"

Vagrant boxes
- vagrant up

### Database
- 12.1.0.1 with Welcome01 as password

#### Operating users
- root vagrant
- vagrant vagrant
- oracle oracle

#### Software
- linuxamd64_12c_database_1of2.zip  ( 12.1.0.1 )
- linuxamd64_12c_database_2of2.zip

### Middleware

#### Default SOA & SB domain
- soa 10.10.10.21, WebLogic 12.1.3 with Infra ( JRF, ADF, SOA, OSB ) requires RCU

http://10.10.10.21:7001/em with weblogic1 as password

#### operating users
- root vagrant
- vagrant vagrant
- oracle oracle

#### Software
- JDK 1.7u55 jdk-7u55-linux-x64.tar.gz
- JDK 7 JCE policy UnlimitedJCEPolicyJDK7.zip
- fmw_12.1.3.0.0_infrastructure.jar
- fmw_12.1.3.0.0_osb_Disk1_1of1.zip
- fmw_12.1.3.0.0_soa_Disk1_1of1.zip
- fmw_12.1.3.0.0_mft_Disk1_1of1.zip

