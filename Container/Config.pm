package Container::Config;

use 5.008008;
use strict;
use Exporter;
use base qw( Exporter );
use Container::Debug;

our @EXPORT = qw(
            getKubeArgs
        );

sub getKubeArgs() {
    my $NAMESPACE = $ENV{NAMESPACE} || 'default';
    my $PROJECT_NAME = $ENV{PROJECT_NAME} || undef;
    my $AWS_CLUSTER = $ENV{AWS_CLUSTER} || undef;
    my $TOKEN = $ENV{TOKEN} || undef;
    errx('PROJECT_NAME is not defined') if not defined $PROJECT_NAME;
    my $kubeargs = "--namespace $NAMESPACE -l app=$PROJECT_NAME";
    $kubeargs .= " --token=$TOKEN" if defined $TOKEN;
    $kubeargs .= " --cluster $AWS_CLUSTER" if defined $AWS_CLUSTER;
    return $kubeargs;
}

1;
