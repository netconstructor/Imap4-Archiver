#!/usr/bin/perl
#v1.0 20051121 GEK Email autoarchive for Maildir mailboxes.  
#v2.0 20091128 GEK Updated to access via IMAP instead of Maildir files.
use Net::IMAP::Simple;
use Date::Calc qw/Date_to_Text Add_Delta_Days/;

$imapserver = "Imap.Mail.Server";
$imapuser = 'ImapUserName';
$imappass = "ImapPassword";
$inbox = "INBOX"; #Shouldn't need to change this unless you want to be specific about a folder that's not your inbox.

$daysold = "30"; #Change if you want.

#Create variables for later
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$year += 1900;
@months = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
$monthname = $months[(localtime(time))[4]-1];
$newfolder = "Inbox.Archive.$monthname$year";

#Find $daysoldago's date
@d = Add_Delta_Days($year,$mon,$mday,'-'.$daysold);
$oldDate = substr(Date_to_Text(@d),4);

#Create new mail folder
$server = new Net::IMAP::Simple($imapserver);
$server->login($imapuser,$imappass);
$server->create_mailbox($newfolder);

$number_of_messages = $server->select("INBOX");
@readmessages = $server->search_seen;
@oldmessages = $server->search("SENTBEFORE $oldDate NOT FLAGGED");

#Copy and then delete
print "$number_of_messages message(s) currently in $inbox.  " . @readmessages . " are read.  " . @oldmessages . " unflagged messages sent before $oldDate will be moved to $newfolder.\n";

foreach $message (@oldmessages) {
	$server->copy($message,$newfolder);
	$server->delete($message);
}