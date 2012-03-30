#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 9;

# Test logical drive information parsing

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
Adapter 1 -- Virtual Drive Information:
Virtual Drive: 0 (Target Id: 0)
Name                :
RAID Level          : Primary-0, Secondary-0, RAID Level Qualifier-0
Size                : 45.634 GB
State               : Optimal
Strip Size          : 128 KB
Number Of Drives    : 1
Span Depth          : 1
Default Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disabled
Encryption Type     : None
Default Power Savings Policy: Controller Defined
Current Power Savings Policy: Automatic
Can spin up in 1 minute: No
LD has drives that support T10 power conditions: No
LD's IO profile supports MAX power savings with cached writes: No


Virtual Drive: 1 (Target Id: 1)
Name                :
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 67.054 GB
State               : Optimal
Strip Size          : 128 KB
Number Of Drives    : 2
Span Depth          : 1
Default Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Access Policy       : Read/Write
Disk Cache Policy   : Disabled
Encryption Type     : None
Default Power Savings Policy: Automatic
Current Power Savings Policy: Maximum without caching
Can spin up in 1 minute: Yes
LD has drives that support T10 power conditions: Yes
LD's IO profile supports MAX power savings with cached writes: No
__EOF

can_ok($m, 'logical_drive_info');
my $ldinfo = $m->logical_drive_info;

# Basic datatype checks
ok($ldinfo, 'logical_drive_info() returns sucessfully');
isa_ok($ldinfo, 'HASH', 'logical_drive_info()');

# Verify the first adapter was found
isa_ok($ldinfo->{1}, 'HASH', 'Adapter 1');

# Verify the first logical drive was found
isa_ok($ldinfo->{1}->{0}, 'HASH', 'Logical Drive 0');

# Verify the status of the first logical drive
is($ldinfo->{1}->{0}->{'State'}, 'Optimal', '"State" of logical drive 0 is "Optimal"');
is($ldinfo->{1}->{1}->{'State'}, 'Optimal', '"State" of logical drive 1 is "Optimal"');
