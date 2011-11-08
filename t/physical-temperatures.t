#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 8;

# Test physical drive temperature parsing and calculation

BEGIN {
    use_ok( 'LSI::MegaSAS' ) || print "Bail out!
";
}

my $m = new_ok('LSI::MegaSAS');


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

can_ok($m, 'drive_temperatures');
my $temps = $m->drive_temperatures;

# Basic datatype checks.
ok($temps, 'drive_temperatures() returns sucessfully');
isa_ok($temps, 'HASH', 'drive_temperatures()');

# Verify the temperature of each drive.
is($temps->{0}->{252}->{0}, '98.6', 'Temperature of first physical drive is good');
is($temps->{0}->{252}->{1}, '100.40', 'Temperature of second physical drive is good');
is($temps->{0}->{252}->{2}, '100.40', 'Temperature of third physical drive is good');
