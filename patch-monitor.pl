#!/usr/bin/perl

###############################################################################
#
# Author:	David Smiles
# Date:		12 Mar 2006
#
# Script:	monitor.pl
#
# Description:
#
#	Script to monitor MIMEsweeper appliance updates website and generate an
#	e-mail alert if it is not available. 
#
#	If download successful, now performs the following actions:
#	1. downloads patch tar and xml files
#	2. tests the MD5 signatures on all tar files
#	3. prints warning if MD5's don't match
#
###############################################################################

use LWP::Simple;
use Net::SMTP;
use XML::Simple;
use Data::Dumper;
use Dumpvalue;
use POSIX qw(strftime);
use Digest::MD5;

my $DEBUG = 0;

# Configure the mail settings
$serverName = "scorpio";
$mailFrom   = "patchmonitor\@clearswift.com";

# list of e-mails to send out message (comma separated list)
@emails = ('david.smiles@clearswift.com');

# Base URL to patch folder on target on live system
# These URLs no longer exist
my $baseUrl = "http://applianceupdate.clearswift.com/patches/";

# Appliance patch control file
my $url = $baseUrl . "patch.ctrl.xml";

# fetch webpage
my $webpage = get $url;

	# if no page then create message
	# send e-mail out to list
	if (!$webpage) 
	{
        $msg = "Failed to download appliance patch control file:\n\n$url"; 

		foreach $email (@emails) 
		{
			sendMail($email, $msg);
		}
	} 
    else 
    {
   	    # no problems

   		# create object
		$xml = new XML::Simple;

        # read XML file
		$data = $xml->XMLin($webpage);

		# output patch control details
		$now_string = strftime "%a, %d %b %Y %H:%M:%S", gmtime;

		print "Patch Monitor Script\n";
		print "--------------------\n\n";
		
		print "Title:   $data->{Title}\n";
		print "Version: $data->{release}\n";
		print "As of:   $now_string\n\n";
		
		print "Patch control contents:\n";
		print "-----------------------\n";
		
		# dereference hash ref - access <PatchFiles> array
		foreach $e (@{$data->{PatchFiles}->{patch}})
		{
			$patch = substr($e->{ctrl}, 0, -4);
			
			print "Patch: $patch\n";
			print "File:  $e->{file}\n";
			print "Ctrl:  $e->{ctrl}\n";
			print "Seq:   $e->{seq}\n";
			print "RedId: $e->{relid}\n";
			print "md5:   $e->{md5sum}\n";
			print "Grade: $e->{grade}\n\n";
		}	

		print "\nFetching patch files\n";
		print "--------------------\n";
		
		# dereference hash ref - access <PatchFiles> array
		foreach $e (@{$data->{PatchFiles}->{patch}})
		{
			# fetch patch control file 
			fetchFile("$baseUrl$e->{ctrl}", $e->{ctrl});
			
			# fetch patch file 
			fetchFile("$baseUrl$e->{file}", $e->{file});
		}

		print "\nTesting MD5 signatures on patch files\n";
		print "-------------------------------------\n";
		
		# dereference hash ref - access <PatchFiles> array
		foreach $e (@{$data->{PatchFiles}->{patch}})
		{
			print "Testing:  $e->{file}\n";
		 	
		 	open(FILE, $e->{file}) or die "Can't open '$e->{file}': $!";
			binmode(FILE);
			$md5 = Digest::MD5->new;
    		while (<FILE>) 
    		{
        		$md5->add($_);
        	}
    		close(FILE);
    		
    		$digest = $md5->hexdigest;
    		if ($e->{md5sum} eq $digest)
	   		{
    			$result = "Pass";
	    	}
    		else
    		{ 
	    		$result = "error - MD5 do not match";
	   		}

	   		print "Expected: $e->{md5sum}\n";
    		print "Actual:   $digest\n";
    		print "Result:   $result";
    		print "\n\n";
	 	}
	}

#print "\nPress enter key to quit\n";
#$dummy = <STDIN>;
exit(0);

###############################################################################
# SUB:  sendMail(email-address, message)
###############################################################################

sub sendMail
{
   	my $email   = $_[0];
	my $msg     = $_[1];
    
	$timeNow = strftime "%a, %d %b %Y %H:%M:%S", gmtime;

	# Create a new SMTP object 
	$smtp = Net::SMTP->new($serverName, Debug => $DEBUG); 
	
	# If you can't connect, don't proceed with the rest of the script 
	die "Couldn't connect to server!" unless $smtp; 

	# Sender and Recipient's email addresses	
    $smtp->mail($mailFrom);
    $smtp->to($email);

    # Start the mail 
	$smtp->data();

	# Send the message body
    $smtp->datasend("Date: $timeNow -0000\n");
    $smtp->datasend("To: $email\n");
	$smtp->datasend("From: $mailFrom\n");
    $smtp->datasend("Subject: ALERT - Appliance Patch Monitor Error\n");
    $smtp->datasend("Subject: $subject\n");
    $smtp->datasend("\n");
    $smtp->datasend("$msg\n");
    
    # Send the termination string 
	$smtp->dataend();

	# Close the connection 
    $smtp->quit;
}

###############################################################################
# SUB:  sendError(email-address, message)
###############################################################################

sub sendError
{
   	my $email = $_[0];
	my $msg   = $_[1];
    
	sendMail(email, msg);
	
	die (msg);
}

###############################################################################
# SUB:  fetchFile(url, file)
###############################################################################

sub fetchFile
{
   	my $url = $_[0];
	my $file = $_[1];

	print "$url ...";
   
	$rc = getstore($url, $file);
	if (is_error($rc))
	{
		sendError("Can't fetch file '$file'\n");
	}
	print "Done\n";
}


