#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 9;

# Test physical drive information parsing

BEGIN {
    use_ok( 'LSI::MegaSAS' ) || print "Bail out!
";
}

my $m; # LSI::MegaSAS object

#  new_ok() does not work in Test::More version 0.62 (CentOS 5).
if (defined(&{'new_ok'})) {
	$m = new_ok( 'LSI::MegaSAS' );
} else {
	#  use the older new() + isa_ok().
	$m = LSI::MegaSAS->new();
	isa_ok($m, 'LSI::MegaSAS');
}


$ENV{'TEST_MEGACLI'} = 1;
# Sample output from -LDInfo -Lall -aALL
$ENV{'TEST_MEGACLI_OUTPUT'} = <<__EOF;
Adapter #0

Enclosure Device ID: 252
Slot Number: 0
Enclosure position: 0
Device Id: 9
Sequence Number: 2
Media Error Count: 0
Other Error Count: 2
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SATA
Raw Size: 46.584 GB [0x5d2ba70 Sectors]
Non Coerced Size: 46.084 GB [0x5c2ba70 Sectors]
Coerced Size: 45.634 GB [0x5b45000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x4433221103000000
Connected Port Number: 1(path0) 
Inquiry Data:         STM00012F8ADSTEC    MACH8 IOPS   43W7701 42C0340IBM 2582    
IBM FRU/CRU:  43W7701    
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None 
Device Speed: 1.5Gb/s 
Link Speed: 1.5Gb/s 
Media Type: Solid State Device
Drive:  Not Certified
Drive Temperature :37 Celsius



Enclosure Device ID: 252
Slot Number: 1
Enclosure position: 0
Device Id: 10
Sequence Number: 2
Media Error Count: 0
Other Error Count: 588
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SAS
Raw Size: 68.365 GB [0x88bb6b0 Sectors]
Non Coerced Size: 67.865 GB [0x87bb6b0 Sectors]
Coerced Size: 67.054 GB [0x861c000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x5000c500323cfa79
SAS Address(1): 0x0
Connected Port Number: 2(path0) 
Inquiry Data: IBM-ESXSST973452SS      B6296TA0AV990825B629    
IBM FRU/CRU: 42D0673     
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None 
Device Speed: 6.0Gb/s 
Link Speed: 6.0Gb/s 
Media Type: Hard Disk Device
Drive:  Not Certified
Drive Temperature :38C (100.40 F)



Enclosure Device ID: 252
Slot Number: 2
Enclosure position: 0
Device Id: 8
Sequence Number: 2
Media Error Count: 0
Other Error Count: 589
Predictive Failure Count: 0
Last Predictive Failure Event Seq Number: 0
PD Type: SAS
Raw Size: 68.365 GB [0x88bb6b0 Sectors]
Non Coerced Size: 67.865 GB [0x87bb6b0 Sectors]
Coerced Size: 67.054 GB [0x861c000 Sectors]
Firmware state: Online, Spun Up
SAS Address(0): 0x5000c50032358309
SAS Address(1): 0x0
Connected Port Number: 0(path0) 
Inquiry Data: IBM-ESXSST973452SS      B6296TA0A6Z30825B629    
IBM FRU/CRU: 42D0673     
FDE Capable: Not Capable
FDE Enable: Disable
Secured: Unsecured
Locked: Unlocked
Needs EKM Attention: No
Foreign State: None 
Device Speed: 6.0Gb/s 
Link Speed: 6.0Gb/s 
Media Type: Hard Disk Device
Drive:  Not Certified
Drive Temperature :38C (100.40 F)




Exit Code: 0x00
__EOF

can_ok($m, 'physical_drive_info');
my $pdinfo = $m->physical_drive_info;

# Basic datatype checks.
ok($pdinfo, 'physical_drive_info() returns sucessfully');
isa_ok($pdinfo, 'HASH', 'physical_drive_info()');

# Verify the first adapter was found.
isa_ok($pdinfo->{0}, 'HASH', 'Adapter 0');

# Verify enclosure ID #252 was found.
isa_ok($pdinfo->{0}->{252}, 'HASH', 'Enclosure 252');

# Verify enclosure ID #252 has three drives.
is(keys %{$pdinfo->{0}->{252}}, 3, 'Enclosure 252 has three physical drives');

# Verify the temperature of the third physical drive.
is($pdinfo->{0}->{252}->{2}->{'Drive Temperature'}, '38C (100.40 F)', 'Temperature of third physical drive is good');
