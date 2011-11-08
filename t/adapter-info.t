#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 6;

# Test adapter information parsing

BEGIN {
    use_ok( 'LSI::MegaSAS' ) || print "Bail out!
";
}

my $m = new_ok('LSI::MegaSAS');


$ENV{'TEST_MEGACLI'} = 1;
# Sample output from -AdpAllInfo -aALL
$ENV{'TEST_MEGACLI_OUTPUT'} = <<__EOF;
Adapter #0

==============================================================================
                    Versions
                ================
Product Name    : ServeRAID M5015 SAS/SATA Controller
Serial No       : SV10603084
FW Package Build: 12.12.0-0037

                    Mfg. Data
                ================
Mfg. Date       : 01/31/11
Rework Date     : 00/00/00
Revision No     : 56A
Battery FRU     : N/A

                Image Versions in Flash:
                ================
FW Version         : 2.120.03-1108
BIOS Version       : 3.19.00_4.11.05.00_0x0417A000
Preboot CLI Version: 04.04-017:#%00008
WebBIOS Version    : 6.0-32-e_27-Rel
NVDATA Version     : 2.09.03-0009
Boot Block Version : 2.02.00.00-0000
BOOT Version       : 01.250.04.219

                Pending Images in Flash
                ================
None

                PCI Info
                ================
Vendor Id       : 1000
Device Id       : 0079
SubVendorId     : 1014
SubDeviceId     : 03b2

Host Interface  : PCIE

Number of Frontend Port: 0 
Device Interface  : PCIE

Number of Backend Port: 8 
Port  :  Address
0        5000c50032358309 
1        4433221103000000 
2        5000c500323cfa79 
3        0000000000000000 
4        0000000000000000 
5        0000000000000000 
6        0000000000000000 
7        0000000000000000 

                HW Configuration
                ================
SAS Address      : 500605b00308ac30
BBU              : Absent
Alarm            : Present
NVRAM            : Present
Serial Debugger  : Present
Memory           : Present
Flash            : Present
Memory Size      : 512MB
TPM              : Absent
On board Expander: Absent
Upgrade Key      : Absent
Temperature sensor for ROC    : Absent
Temperature sensor for controller    : Absent


                Settings
                ================
Current Time                     : 16:47:16 11/3, 2011
Predictive Fail Poll Interval    : 300sec
Interrupt Throttle Active Count  : 16
Interrupt Throttle Completion    : 50us
Rebuild Rate                     : 30%
PR Rate                          : 30%
BGI Rate                         : 30%
Check Consistency Rate           : 30%
Reconstruction Rate              : 30%
Cache Flush Interval             : 4s
Max Drives to Spinup at One Time : 4
Delay Among Spinup Groups        : 2s
Physical Drive Coercion Mode     : 1GB
Cluster Mode                     : Disabled
Alarm                            : Disabled
Auto Rebuild                     : Enabled
Battery Warning                  : Enabled
Ecc Bucket Size                  : 15
Ecc Bucket Leak Rate             : 1440 Minutes
Restore HotSpare on Insertion    : Disabled
Expose Enclosure Devices         : Enabled
Maintain PD Fail History         : Enabled
Host Request Reordering          : Enabled
Auto Detect BackPlane Enabled    : SGPIO/i2c SEP
Load Balance Mode                : Auto
Use FDE Only                     : Yes
Security Key Assigned            : No
Security Key Failed              : No
Security Key Not Backedup        : No
Default LD PowerSave Policy      : Automatic
Maximum number of direct attached drives to spin up in 1 min : 120 
Any Offline VD Cache Preserved   : No
Allow Boot with Preserved Cache  : No
Disable Online Controller Reset  : No
PFK in NVRAM                     : No
Use disk activity for locate     : No

                Capabilities
                ================
RAID Level Supported             : RAID0, RAID1, RAID5, RAID00, RAID10, RAID50, PRL 11, PRL 11 with spanning, SRL 3 supported, PRL11-RLQ0 DDF layout with no span, PRL11-RLQ0 DDF layout with span
Supported Drives                 : SAS, SATA

Allowed Mixing:

Mix in Enclosure Allowed

                Status
                ================
ECC Bucket Count                 : 0

                Limitations
                ================
Max Arms Per VD          : 32 
Max Spans Per VD         : 8 
Max Arrays               : 128 
Max Number of VDs        : 64 
Max Parallel Commands    : 1008 
Max SGE Count            : 80 
Max Data Transfer Size   : 8192 sectors 
Max Strips PerIO         : 42 
Min Strip Size           : 8 KB
Max Strip Size           : 1.0 MB
Max Configurable CacheCade Size: 0 GB
Current Size of CacheCade      : 0 GB
Current Size of FW Cache       : 397 MB

                Device Present
                ================
Virtual Drives    : 2 
  Degraded        : 0 
  Offline         : 0 
Physical Devices  : 4 
  Disks           : 3 
  Critical Disks  : 0 
  Failed Disks    : 0 

                Supported Adapter Operations
                ================
Rebuild Rate                    : Yes
CC Rate                         : Yes
BGI Rate                        : Yes
Reconstruct Rate                : Yes
Patrol Read Rate                : Yes
Alarm Control                   : Yes
Cluster Support                 : No
BBU                             : No
Spanning                        : Yes
Dedicated Hot Spare             : Yes
Revertible Hot Spares           : Yes
Foreign Config Import           : Yes
Self Diagnostic                 : Yes
Allow Mixed Redundancy on Array : No
Global Hot Spares               : Yes
Deny SCSI Passthrough           : No
Deny SMP Passthrough            : No
Deny STP Passthrough            : No
Support Security                : No
Snapshot Enabled                : No
Support the OCE without adding drives : Yes
Support PFK                     : No

                Supported VD Operations
                ================
Read Policy          : Yes
Write Policy         : Yes
IO Policy            : Yes
Access Policy        : Yes
Disk Cache Policy    : Yes
Reconstruction       : Yes
Deny Locate          : No
Deny CC              : No
Allow Ctrl Encryption: No
Enable LDBBM         : No
Support Breakmirror  : No
Power Savings        : Yes

                Supported PD Operations
                ================
Force Online                            : Yes
Force Offline                           : Yes
Force Rebuild                           : Yes
Deny Force Failed                       : No
Deny Force Good/Bad                     : No
Deny Missing Replace                    : No
Deny Clear                              : No
Deny Locate                             : No
Support Temperature                     : Yes
Disable Copyback                        : No
Enable JBOD                             : No
Enable Copyback on SMART                : No
Enable Copyback to SSD on SMART Error   : Yes
Enable SSD Patrol Read                  : No
PR Correct Unconfigured Areas           : Yes
Enable Spin Down of UnConfigured Drives : Yes
Disable Spin Down of hot spares         : No
Spin Down time                          : 30 
T10 Power State                         : Yes
                Error Counters
                ================
Memory Correctable Errors   : 0 
Memory Uncorrectable Errors : 0 

                Cluster Information
                ================
Cluster Permitted     : No
Cluster Active        : No

                Default Settings
                ================
Phy Polarity                     : 0 
Phy PolaritySplit                : 0 
Background Rate                  : 30 
Strip Size                       : 128kB
Flush Time                       : 4 seconds
Write Policy                     : WB
Read Policy                      : None
Cache When BBU Bad               : Disabled
Cached IO                        : No
SMART Mode                       : Mode 6
Alarm Disable                    : No
Coercion Mode                    : 1GB
ZCR Config                       : Unknown
Dirty LED Shows Drive Activity   : No
BIOS Continue on Error           : No
Spin Down Mode                   : None
Allowed Device Type              : SAS/SATA Mix
Allow Mix in Enclosure           : Yes
Allow HDD SAS/SATA Mix in VD     : No
Allow SSD SAS/SATA Mix in VD     : No
Allow HDD/SSD Mix in VD          : No
Allow SATA in Cluster            : No
Max Chained Enclosures           : 16 
Disable Ctrl-R                   : Yes
Enable Web BIOS                  : Yes
Direct PD Mapping                : No
BIOS Enumerate VDs               : Yes
Restore Hot Spare on Insertion   : No
Expose Enclosure Devices         : Yes
Maintain PD Fail History         : Yes
Disable Puncturing               : Yes
Zero Based Enclosure Enumeration : No
PreBoot CLI Enabled              : Yes
LED Show Drive Activity          : No
Cluster Disable                  : Yes
SAS Disable                      : No
Auto Detect BackPlane Enable     : SGPIO/i2c SEP
Use FDE Only                     : Yes
Enable Led Header                : No
Delay during POST                : 4 
EnableCrashDump                  : No
Disable Online Controller Reset  : No
EnableLDBBM                      : No
Un-Certified Hard Disk Drives    : Allow
Treat Single span R1E as R10     : No
Max LD per array                 : 16
Power Saving option              : All power saving options are enabled
Default spin down time in minutes: 30 
Enable JBOD                      : No
TTY Log In Flash                 : No
Auto Enhanced Import             : No
BreakMirror RAID Support         : No
Disable Join Mirror              : No
Time taken to detect CME         : 60s

Exit Code: 0x00
__EOF

TODO: {
	local $TODO = 'adapter_info() not yet implemented';
	can_ok($m, 'adapter_info');
} # TODO

SKIP: {
	skip 'adapter_info() not yet implemented', 3 if (!LSI::MegaSAS->can('adapter_info'));
	my $adpinfo = $m->adapter_info;

	# Basic datatype checks
	ok($adpinfo, 'adapter_info() returns sucessfully');
	isa_ok($adpinfo, 'HASH', 'adapter_info()');

	# Verify the first adapter was found
	isa_ok($adpinfo->{0}, 'HASH', 'Adapter 0');
} # SKIP
