package ContainerStatus::Config;

use 5.008008;
use strict;
use Exporter;
use FindBin qw($Bin);
use base qw( Exporter );
use ContainerStatus::Debug;
use Getopt::Long;

our @EXPORT = qw(
            getConf
        );

sub getConf {
    my %opts = ();
    my $conf = {};
    GetOptions( \%opts, 'timeout=n', 'namespace=s', 'application=s' );
    my $timeout = $opts{timeout} || 180;
    my $namespace = $opts{namespace} || 'default';
    my $application = $opts{application} || undef;
    errx('application is not defined') if not defined $application;
    $conf = {
        timeout => $timeout,
        application => $application,
        namespace => $namespace
    };
    return $conf;
}

1;
