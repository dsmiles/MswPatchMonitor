# MIMEsweeper Appliance Patch Server Monitor Script

This repository contains a simple Perl script that I used for monitoring the MIMEsweeper Email Applicance Patch Server. I wrote the 
script way-back in 2006 when I was in charge of testing the Clearswift MIMEsweeper Applicance - a rack mounted Dell server running SELinux. 

The engineering team regularly posted updates to the patch server, which the applicance would then automatically download and apply.

Before deploying updates to production, patches were first uploaded to a staging server. At that point, I employed this script to validate the patch — a necessary step at the time, as the process wasn't automated.

The script would perform the following:

1. Wait for a new update
2. Download the patch tar and XML files
3. Verifying the MD5 signatures on all tar files
4. Printing the result and sending a warning email if MD5 signatures don't match

Note: At the time most scripting on the applicance was performed using Bash or Perl. Nowadays, I would use Python.


For details on Clearswift products [Official Website: Fortra/Clearswift](https://www.clearswift.com)


# LEGAL NOTES
## Disclaimer
All named product and company names are trademarks (™) or registered (®) trademarks of their respective holders. Use of them does not imply any affiliation with or endorsement by them.
