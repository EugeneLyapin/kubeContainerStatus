package ContainerStatus::Config;

use 5.008008;
use strict;
use Exporter;
use base qw( Exporter );
use JSON::PP;
use ContainerStatus::Debug;

our @EXPORT = qw(
            getConf
        );

sub convertCodeListToHash {
    my $codes = shift;
    my $items = {};
    for my $state (keys %{$codes}) {
        $items->{$state} = {};
        my $ContainerStatuses = $codes->{$state};
        for my $ContainerStatus (@{$ContainerStatuses}) {
            $items->{$state}->{$ContainerStatus} = 0;
        }
    }
    return $items;
}

sub getConf {
    my %opts = ();
    my $TIMEOUT = $ENV{TIMEOUT} || 300;
    my $DELAY = $ENV{DELAY} || 30;
    my $CYCLES = int($TIMEOUT*2/$DELAY);
    my $RUNNING_CYCLES = $ENV{RUNNING_CYCLES} || int($TIMEOUT/($DELAY*2));
    my $NAMESPACE = $ENV{NAMESPACE} || 'default';
    my $PROJECT_NAME = $ENV{PROJECT_NAME} || undef;
    my $AWS_CLUSTER = $ENV{AWS_CLUSTER} || undef;
    my $TOKEN = $ENV{TOKEN} || undef;
    errx('PROJECT_NAME is not defined') if not defined $PROJECT_NAME;
    errx('Number of watch cycles is low. Increase TIMEOUT and/or reduce DELAY') if $CYCLES <= 1;
    errx('Number of running cycles is low. Increase TIMEOUT and/or reduce DELAY') if $RUNNING_CYCLES <= 1;
    my $kubeargs = "--namespace $NAMESPACE -l app=$ENV{PROJECT_NAME}";
    $kubeargs .= " --token=$TOKEN" if defined $TOKEN;
    $kubeargs .= " --cluster $AWS_CLUSTER" if defined $AWS_CLUSTER;
    my $ContainerStatuses = {
        'Error' => {
            'waiting' => [
                'ErrImagePull',
                'CrashLoopBackOff',
                'ImagePullBackOff',
                'CreateContainerConfigError',
                'InvalidImageName',
                'CreateContainerError',
            ],
            'terminated' => [
                'OOMKilled',
                'Error',
                'Completed',
                'ContainerCannotRun',
                'DeadlineExceeded',
            ]
        },

        'Pending' => {
            'waiting' => [
                'ContainerCreating',
                'PodInitializing',
            ]
        },

        'Running' => {
            'running' => []
        }
    };

    my $conf = {
        Options => {
            TIMEOUT => $TIMEOUT,
            DELAY => $DELAY,
            CYCLES => $CYCLES,
            RUNNING_CYCLES => $RUNNING_CYCLES
        },
        Statistics => {},
        kubeargs => $kubeargs
    };

    debug(encode_json($conf->{Options}));
    for my $state (keys %{$ContainerStatuses}) {
        $conf->{ContainerStatuses}->{$state} = convertCodeListToHash($ContainerStatuses->{$state});
    }

    return $conf;
}

1;
