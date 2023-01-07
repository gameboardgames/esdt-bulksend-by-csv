# esdt-bulksend-by-csv
This BASH script reads a CSV file to send corresponding ESDT tokens, using erdpy.  Customized for steak4all's fine STEAKS token.  

Version 1.0 released to Elrond community Feb 16th 2022 by steak4all, feel free to use in any way useful.  
GNU bash 5.0.17(1) used (default of ubuntu 20.04) 

Have many Elrond Digital Standard Tokens to send, but have no way to send to many wallets easily?  This script will read a CSV file (listing the senders and the amount of tokens they will get) and then send the corresponding amounts to the users. 

How to use this script? 

Prerequisite: Linux/BASH.  And then install and configure erdpy https://docs.elrond.com/sdk-and-tools/erdpy/installing-erdpy/#docsNav

The script sends tokens via erdpy. You'll need to setup your wallet for sending and use, as described in the link above. 

Next edit the esdt-csv-send.sh file. You'll need to add your wallet and your PEM file to the necessary fields. This script was written for STEAK token in mind, so has some STEAK
nomenclature, which can be changed if you like. Also note to change the chain your are using in script, it defaults to main net. 

Finally, prepare your CSV file, using the sample as a guide. Once you have your CSV file created, be sure to name it the same or change the corresponding file name in the script.

One really super-duper important thing we found out after a lot of hair-pulling was that for your CSV file, unless you made it in a 100% Linux environment, you'll need to use the program DOS2UNIX to
first process the CSV file. Even if you d/led from a cloud source like Google Drive, or if you have any hex calculations errors, try using DOS2UNIX on your CSV like this: 
dos2unix mysample.csv 
Many bothans died for this information. 

More info dos2unix: https://linux.die.net/man/1/dos2unix

Note: 
You'll need to 
chmod a+x esdt-csv-send.sh
before it'll run.

Change log:  
Jan 6th 2023 v1.1 big clean up and update of the code. Found the dreaded HEX bug and killed it, see note on DOS2UNIX above. Updated example csv. 
June 3rd 2022  v1.01 update, fixed some small things, and added more description.  NOTE that a bug was found and still exists.  The script only seems to work up to 99 entries in the CSV file.  After that, an error in the hex field conversion seems to happen. 
Until this is fixed,break your send lists down to file increments of up to a max of 99 TXs per CSV.