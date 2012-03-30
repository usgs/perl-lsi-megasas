#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 8;

# Test enclosure information parsing

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
# Sample output from -EncInfo -aALL
$ENV{'TEST_MEGACLI_OUTPUT'} = <<__EOF;
    Number of enclosures on adapter 0 -- 1

    Enclosure 0:
    Device ID                     : 252
    Number of Slots               : 8
    Number of Power Supplies      : 0
    Number of Fans                : 0
    Number of Temperature Sensors : 0
    Number of Alarms              : 0
    Number of SIM Modules         : 1
    Number of Physical Drives     : 3
    Status                        : Normal
    Position                      : 1
    Connector Name                : Unavailable
    Partner Device Id             : 65535

    Inquiry data                  :
        Vendor Identification     : LSI     
        Product Identification    : SGPIO           
        Product Revision Level    : N/A 
        Vendor Specific           :                     
__EOF


can_ok($m, 'enclosure_info');
my $encinfo = $m->enclosure_info;

# Basic datatype checks
ok($encinfo, 'enclosure_info() returns sucessfully');
isa_ok($encinfo, 'HASH', 'enclosure_info()');

# Verify the first adapter was found
isa_ok($encinfo->{0}, 'HASH', 'Adapter 0');

# Verify the first enclosure was found on the first adapter
isa_ok($encinfo->{0}->{0}, 'HASH', 'Enclosure 0');

# Verify the status of the first enclosure
is($encinfo->{0}->{0}->{'Status'}, 'Normal', '"Status" of the array is "Normal"');
