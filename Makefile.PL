use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'LSI::MegaSAS',
    AUTHOR              => q{Ken Dreyer <kdreyer@usgs.gov>},
    VERSION_FROM        => 'lib/LSI/MegaSAS.pm',
    ABSTRACT_FROM       => 'lib/LSI/MegaSAS.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'public domain')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'LSI-MegaSAS-*' },
);
