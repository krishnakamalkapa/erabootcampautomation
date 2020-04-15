## Era BootCamp Automation

The objective is to have an automated way of setting up Era VM, Oracle & SQL Server environments for a customer BootCamps. This reduces the time and effort to set up,configure and validate the components for the bootcamp. 

Attached are the scripts to perform this automation. The scripts use a combination of acli, ncli, Era API’s to perform the complete end-to-end automation. 

## Pre-requisites:

Have a HPOC provisioned by the Sales Engineer for the bootcamp. 
Copy the attached scripts and the imagefile to one of the CVM nodes in the cluster.
Have the execute permission on the scripts.
Update env.conf file with all the required values from HPOC cluster confirmation email.

## Instructions: 

```sh 1. clusterprep.sh  ```

Creates a IPAM Network in PRISM with half of the IP’s from the provided vlan.
Creates a Static network for Era use with the remaining half of the IP’s 
Create a Storage Container for Era use
Resets the PRISM admin login password for easy use

```sh 2.imagecreate.sh ```

Note: All the required Era, Oracle, SQL Images are uploaded to a shared repository

The script will read the imagelist file and upload the respective images to the Cluster Image Service. Validate the successful upload of images 
All the images will be uploaded in parallel during the execution 
Run the 2.imagecreate.sh 

Note: the upload of the images may take 30-40 min

```sh 3.vmprovision.sh ```

Validate the images are present in the image repository
Create the Oracle,SQL, Era VM’s containing the software and the database
Attach the required disks, create a network and power it on. 

```sh 4.eraapi.sh ```

Connects to the cluster and get the deployed Era VM IP Address
Using Era API’s it reset the password, accept the EULA, registers the Cluster into Era, configure the network for Era use.
