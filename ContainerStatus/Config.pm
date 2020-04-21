package ContainerStatus::Config;

use 5.008008;
use strict;
use Exporter;
use base qw( Exporter );
use JSON::PP;
use Kube::Debug;
use Kube::Config;

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
    my $kubeargs = getKubeArgs();
    my $TIMEOUT = $ENV{TIMEOUT} || 300;
    my $DELAY = $ENV{DELAY} || 30;
    my $CYCLES = int($TIMEOUT*2/$DELAY);
    my $RUNNING_CYCLES = $ENV{RUNNING_CYCLES} || 7;
    errx('Number of watch cycles is low. Increase TIMEOUT and/or reduce DELAY') if $CYCLES <= 1;
    errx('Number of running cycles is low. Increase TIMEOUT and/or reduce DELAY') if $RUNNING_CYCLES <= 1;
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
