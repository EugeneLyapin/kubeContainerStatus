package ContainerStatus::Config;

use 5.008008;
use strict;
use Exporter;
use FindBin qw($Bin);
use base qw( Exporter );
use ContainerStatus::Debug;

our @EXPORT = qw(
            getConf
        );

sub getConf {
    my %opts = ();
    my $conf = {};
    my $TIMEOUT = $ENV{TIMEOUT} || 180;
    my $NAMESPACE = $ENV{NAMESPACE} || 'default';
    my $PROJECT_NAME = $ENV{PROJECT_NAME} || undef;
    my $AWS_CLUSTER = $ENV{AWS_CLUSTER} || undef;
    my $TOKEN = $ENV{TOKEN} || undef;
    errx('PROJECT_NAME is not defined') if not defined $PROJECT_NAME;
    my $kubeargs = "--namespace $NAMESPACE -l app=$ENV{PROJECT_NAME}";
    $kubeargs .= " --token=$TOKEN" if defined $TOKEN;
    $kubeargs .= " --cluster $AWS_CLUSTER" if defined $AWS_CLUSTER;
    my $conf = {
        TIMEOUT => $TIMEOUT,
        kubeargs => $kubeargs
    };
    return $conf;
}

1;
