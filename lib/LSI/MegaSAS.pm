package LSI::MegaSAS;

use warnings;
use strict;
use Carp;

our $VERSION = '1.00';


sub new {
	my $class = shift;
	my $self = {};
	# Set the MegaCli binary path manually, if one was provided.
	my $megacli = shift;
	my @possible_paths = (
		# user-specified.
		$megacli,
		# 64-bit RHEL.
		'/opt/MegaRAID/MegaCli/MegaCli64',
		# 32-bit RHEL.
		'/opt/MegaRAID/MegaCli/MegaCli',
	);
	# Verify that we have a valid MegaCli binary path.
	for (@possible_paths) {
		if ($_ && -x $_) {
			$self->{'megacli'} = $_;
			last;
		}
	}
	# Note that $self->{'megacli'} could still be undef here, if we didn't
	# find anything useful in the above loop. I've chosen to make this a
	# non-fatal error, until _run_megacli() is called, in order to support
	# running the test suite on computers where MegaCli is not installed.
	bless($self, $class);
	return $self;
}

# Developers:
# The code for most of these functions is very similar, since they are
# doing similar things. There was enough differences that I didn't bother
# optimizing, and opted for the quicker copy & paste.

# List all logical drives in a simple format.
# Argument: boolean - when true, only return drives with a non-normal status.
# Returns: list, or undef if none found
sub logical_drive_list {
	my $self = shift;
	my $return_failures = shift;
	my @list; # list of all drives
	my @failures; # list of failed drives
	my $data = $self->logical_drive_info;
	# Iterate through each adapter
	for my $adp (sort(keys(%$data))) {
		my $adp_data = $data->{$adp};
		# Iterate through each logical drive
		for my $ld (sort(keys(%$adp_data))) {
			my $ld_data = $adp_data->{$ld};
			my $text = "Adapter $adp, Logical Drive $ld, $ld_data->{'Size'}: $ld_data->{'State'}";
			push(@list, $text);
			if ($ld_data->{'State'} ne 'Optimal') {
				push(@failures, $text);
			}
		}
	}
	if ($return_failures) {
		return @failures;
	}
	return @list;
}

# Return a list of logical drives with a non-normal status.
# Returns: list, or undef if none found
sub logical_drive_failures {
	my $self = shift;
	return $self->logical_drive_list(1);
}

# List all enclosures in a simple format.
# Argument: boolean - when true, only return enclosures with a non-normal status.
# Returns: list, or undef if none found
sub enclosure_list {
	my $self = shift;
	my $return_failures = shift;
	my @list; # list of all enclosures
	my @failures; # list of failed enclosures
	my $data = $self->enclosure_info;
	# Iterate through each adapter
	for my $adp (sort(keys(%$data))) {
		my $adp_data = $data->{$adp};
		for my $enc (sort(keys(%$adp_data))) {
			my $enc_data = $adp_data->{$enc};
			my $text = "Adapter $adp, Enclosure $enc: $enc_data->{'State'}";
			push(@list, $text);
			if ($enc_data->{'Status'} ne 'Normal') {
				push(@failures, $text);
			}
		}
	}
	if ($return_failures) {
		return @failures;
	}
	return @list;
}

# Return a list of logical drives with a non-normal status.
# Returns: list, or undef if none found
sub enclosure_failures {
	my $self = shift;
	return $self->enclosure_list(1);
}

# Return all drives' temperatures, in Fahrenheit degrees
# Returns: hashref
sub drive_temperatures {
	my $self = shift;
	my $data = $self->physical_drive_info;
	my $temps;
	# Iterate through each adapter
	for my $adp (keys(%$data)) {
		my $adp_data = $data->{$adp};
		# Iterate through each enclosure
		for my $enc (keys(%$adp_data)) {
			my $enc_data = $data->{$adp}->{$enc};
			# Iterate through each drive
			for my $drive (keys(%$enc_data)) {
				# Get the raw string from megacli.
				my $t = $enc_data->{$drive}->{'Drive Temperature'};
				# Try to parse the temperature string.
				if ($t =~ /([\d\.]+)\s*F/) {
					# We already have a Fahrenheit value, great.
					$t = $1;
				} elsif ($t =~ /([\d\.]+)\s*C/) {
					# Convert from a Celsius value.
					$t = ($1*9/5)+32;
				} else {
					# We couldn't find anything intelligible.
					$t = undef;
				}
				# Store this value.
				$temps->{$adp}->{$enc}->{$drive} = $t;
			}
		}
	}
	return $temps;
}

# Check enclosure status.
# Returns: hashref
sub enclosure_info {
	my $self = shift;
	return $self->_parse_enclosure_info( $self->_run_megacli('-EncInfo -aALL') );
}

# Parse the output of -EncInfo -aALL
# Argument: MegaCli output
# Returns: hashref
sub _parse_enclosure_info {
	my $self = shift;
	my $encinfo = shift || croak("missing megacli output");
	# Hashref for the enclosure data.
	my $enc_data;
	# Adapter integer ID.
	my $adapter;
	# Enclosure integer ID.
	my $enc;
	
	# Read the output, line by line.
	# Examine each enclosure and store its data in the hashref above.
	for (split(/^/, $encinfo)) {
		if (/Number of enclosures on adapter (\d+)/) {
			# Adapter identification line.
			# This should always come before any key/value pairs.
			$adapter = $1;
		} elsif (/Enclosure (\d+):/) {
			# Enclosure identification line.
			# This should always come before any key/value pairs.
			$enc = $1;
		} elsif ($self->_read_key_value($_)) {
			my ($key, $value) = $self->_read_key_value($_);
			# Store this data.
			$enc_data->{$adapter}->{$enc}->{$key} = $value;
		}
	}
	return $enc_data;
}


# Check logical drive status.
sub logical_drive_info {
	my $self = shift;
	return $self->_parse_logical_drive_info( $self->_run_megacli('-LDInfo -Lall -aALL') );
}

# Parse the output of -LDInfo -Lall -aALL.
# Argument: MegaCli output
sub _parse_logical_drive_info {
	my $self = shift;
	my $ldinfo = shift || croak("missing megacli output");
	# Hashref for the logical drive data.
	my $ld_data;
	# Adapter integer ID.
	my $adapter;
	# Logical Drive integer ID.
	my $ld;
	
	# Read the output, line by line.
	# Examine each virtual drive and store its data in the hashref above.
	for (split(/^/, $ldinfo)) {
		if (/Adapter (\d+) -- Virtual Drive Information:/) {
			# Adapter identification line.
			# This should always come before any key/value pairs.
			$adapter = $1;
		} elsif (/Virtual Drive: (\d+) \(Target Id: \d+\)/) {
			# Virtual Drive identification line.
			# This should always come before any key/value pairs.
			$ld = $1;
		} elsif ($self->_read_key_value($_)) {
			my ($key, $value) = $self->_read_key_value($_);
			# Store this data.
			$ld_data->{$adapter}->{$ld}->{$key} = $value;
		}
	}
	return $ld_data;
}

# Check physical drive status.
sub physical_drive_info {
	my $self = shift;
	return $self->_parse_physical_drive_info( $self->_run_megacli('-PdList -aALL') );
}

# Parse the output of -PdList -aALL.
# Argument: MegaCli output
sub _parse_physical_drive_info {
	my $self = shift;
	my $pdinfo = shift || croak("missing megacli output");
	# Hashref for the logical drive data.
	my $pd_data;
	# Adapter integer ID.
	my $adapter;
	# Enclosure integer ID.
	my $enc;
	# Physical Drive integer ID.
	my $pd;
	
	# Read the output, line by line.
	# Examine each virtual drive and store its data in the hashref above.
	for (split(/^/, $pdinfo)) {
		if (/Adapter #(\d+)/) {
			# Adapter identification line.
			# This should always come before any key/value pairs.
			$adapter = $1;
		} elsif (/Enclosure Device ID: (\d+)/) {
			# Enclosure identification line.
			# This should always come before any key/value pairs.
			$enc = $1;
		} elsif (/Slot Number: (\d+)/) {
			# Physical Drive identification line.
			# This should always come before any key/value pairs.
			$pd = $1;
		} elsif ($self->_read_key_value($_)) {
			my ($key, $value) = $self->_read_key_value($_);
			# Store this data.
			$pd_data->{$adapter}->{$enc}->{$pd}->{$key} = $value;
		}
	}
	return $pd_data;
}

# Read a key/value pair from a single line of MegaCli output.
# Argument: scalar
# Returns: list, or undef if no key/value pair was found.
sub _read_key_value {
	my $self = shift;
	shift;
	if (/([^:]+):(.+)/) {
		# Store the key / values for this virtual drive.
		# Trim whitespace
		my ($key, $value) = ($1, $2);
		$key =~ s/^\s+//;
		$key =~ s/\s+$//;
		$value =~ s/^\s+//;
		$value =~ s/\s+$//;
		# No need to keep the Exit Code output.
		if ($key ne 'Exit Code') {
			return($key, $value);
		}
	}
}

# The MegaCli binary must be run with the -NoLog option, or else it drops a
# MegaSAS.log file in the current working diretory whenever it is run.
# Returns: scalar
sub _run_megacli {
	my $self = shift;
	my $args = shift || croak("missing args to megacli binary");
	# For the test suite.
	# (This facilitates testing various array error conditions,
	# or even testing without MegaCli installed.)
	if ($ENV{'TEST_MEGACLI'}) {
		return $ENV{'TEST_MEGACLI_OUTPUT'};
	}
	if (!$self->{'megacli'} || !-x $self->{'megacli'}) {
		die("No MegaCli binary was found on the system. Please point to the binary when instantiating this module.\n");
	}
	my $output = `$self->{'megacli'} $args -NoLog`;
	return $output;
}

1;

__END__

=head1 NAME

LSI::MegaSAS - Monitor LSI MegaRAID controllers

=head1 SYNOPSIS

Use this module to determine the status of your LSI MegaRAID arrays on Linux.

    use LSI::MegaSAS;

    my $m = LSI::MegaSAS->new();

    # Find the status of enclosure 0 on the first adapter.
    my $enclosures = $m->enclosure_info();
    print $enclosures->{0}->{0}->{'Status'}
    # prints "Normal" or ... something else.

    # Find the status of enclosure 0 on the first adapter.
    my $enclosures = $m->enclosure_info();
    print $enclosures->{0}->{0}->{'Status'}
    # prints "Normal" or ... something else.

    # Find the status of logical drive 0 on the first adapter.
    my $enclosures = $m->enclosure_info();
    print $enclosures->{1}->{0}->{'State'}
    # prints "Optimal" or "Degraded".

    ...


=head1 DESCRIPTION

LSI has published a Linux tool called "MegaCli". This tool reports the status of MegaRAID arrays.

This module is a Perl wrapper around that tool. Specifically, this module gives information on the physical enclosures, the physical drives, and the logical drives. 

There are several data types:

=over

=item *

Enclosure

=item *

Adapter

=item *

Physical drive

=item *

Logical drive (also called "Virtual Drive" in some places in the LSI interface)

=back

And here's how to understand the data:

=over

=item *

An enclosure can have zero or more adapters.

=item *

An adapter can have zero or more physical drives.

=item *

A physical drive can belong to zero or more logical drives.

=back


=head1 CONSTRUCTOR METHOD

=head2 new

Returns a new LSI::MegaSAS object. The new() function takes one scalar argument: the full path to the MegaCli or MegaCli64 binary. If you do not specify any path, new() tries a few default paths to figure this out on its own.

=head1 CONVENIENCE METHODS

These methods are useful for monitoring programs.

=head2 logical_drive_list

Returns a textual list of all logical drives. (This function takes arguments, but please do not rely on this behavior.)

=head2 enclosure_list

Returns a textual list of all enclosures. (This function takes arguments, but please do not rely on this behavior.)

=head2 logical_drive_failures

Returns a textual list of failed logical drives. The function returns undef if there are no degraded or failed logical drives.

The returned text will start numbering adapters at #1. See the L</"ADAPTER NUMBERING"> section below.

=head2 enclosure_failures

Returns a textual list of failed enclosures. The function returns undef if there are no failed enclosures. I've never seen this happen so I don't even know if it's possible for these to fail.

=head2 drive_temperatures

Returns the temperature of each drive, in Fahrenheit degrees. The function returns undef if there are no degraded or failed logical drives.

 $megasas->drive_temperatures()

You can find enclosure IDs with the physical_drive_info() function. For example, the following code would give you a list of all enclosure IDs on the first adapter. 

 @enclosure_ids = keys($megasas->physical_drive_info()->{0})

=head1 DATA METHODS

These methods allow you to access the raw data from MegaCli. This module does no post-processing with these functions; it merely assembles the data into hashrefs.

=head2 enclosure_info

Returns a hashref of information about each RAID enclosure, organized by adapters.

=begin comment
	This function is not yet implemented.

	=head2 adapter_info

	Returns a hashref of information about each RAID adapter.

	LSI's tool refers to the first adapter as "#0" when examining adapters with this function. This is different than examining logical drives with logical_drive_info(), which starts counting at #1.

=end comment

=head2 logical_drive_info

Returns a hashref of information about each logical drive, organized by adapters.

The returned hashref starts numbering adapters at #1. See the L</"ADAPTER NUMBERING"> section below.

=head2 physical_drive_info

Returns a hashref of information about each physical drive, organized by adapters and enclosure IDs.

=head1 ADAPTER NUMBERING

LSI's tool refers to the first adapter as "#1" when examining logical drives. All other operations start counting adapters at "#0".

The author of this Perl module chose to preserve this distinction. So the logical_drive_* functions which starts counting adapters at #1. All other functions start counting adapters at #0.

=head1 VERSION

Version 1.00

This module was developed using a MegaCli binary that "-help" proclaims to be "MegaCLI SAS RAID Management Tool  Ver 8.00.40 Oct 12, 2010"

=head1 AUTHOR

Ken Dreyer, C<< <kdreyer at usgs.gov> >>

=head1 ACKNOWLEDGEMENTS

Inspiration provided by Jonathan Delgado's check_megaraid_sas script.
L<http://exchange.nagios.org/directory/Plugins/Hardware/Storage-Systems/RAID-Controllers/check_megaraid_sas/details>

=head1 LICENSE AND COPYRIGHT

This software is in the public domain because it contains materials that originally came from the United States Geological Survey, an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at http://www.usgs.gov/visual-id/credit_usgs.html#copyright

