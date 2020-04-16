package ContainerStatus;

use 5.008008;
use strict;
use Exporter;
use base qw( Exporter );
use JSON::PP;
use ContainerStatus::Debug;

our @EXPORT = qw(
            getContainerStatus
        );

sub getContainerStatus {
    my $conf = shift;
    local $/;
    my $cmd = "kubectl get pods $conf->{kubeargs} -o json 2>&1";
    my $jsondata = qx{ $cmd };
    my $cmdres = $?;
    errx('kubectl error: ' . $jsondata) if ( $cmdres ne 0);
    my $data = decode_json($jsondata);
    my $items = $data->{items} || [];
    errx('no data') if (scalar @{$items} eq 0);

    my $ErrCodes = {
        'waiting' => {
            'ErrImagePull' => 0,
            'CrashLoopBackOff' => 0,
            'ImagePullBackOff' => 0,
            'CreateContainerConfigError' => 0,
            'InvalidImageName' => 0,
            'CreateContainerError' => 0,
        },
        'terminated' => [
            'OOMKilled' => 0,
            'Error' => 0,
            'Completed' => 0,
            'ContainerCannotRun' => 0,
            'DeadlineExceeded' => 0
        ]
    };

    my $PendingCodes = {
        'waiting' => {
            'ContainerCreating' => 0,
        }
    };

    my $RunningCodes = {
        'running' => 0
    };

    my $containers = 0;

    foreach my $item (@{$items}) {
        my $containerStatuses = $item->{status}->{containerStatuses};
        $containers += scalar @{$containerStatuses};
        foreach my $containerStatus (@{$containerStatuses}) {
            my $status = $containerStatus->{state};
            my $s = (%{$status})[0];
            debug(encode_json($status));
            if (ishash($ErrCodes->{$s})) {
                my $reason = $status->{$s}->{reason};
                errx($reason) if defined $ErrCodes->{$s}->{$reason};
            }

            if (ishash($PendingCodes->{$s})) {
                my $reason = $status->{$s}->{reason};
                return 1 if defined $PendingCodes->{$s}->{$reason};
            }

            $RunningCodes->{$s}++ if defined $RunningCodes->{$s};
        }
    }

    debug('containers='. $containers . ' running=' . $RunningCodes->{running});
    return 0 if ($RunningCodes->{running} eq $containers and $containers > 0);
    return 1;
}

# check if variable is hash
sub ishash {
  my $r = shift;
  return 1 if(ref($r) eq 'HASH');
  return 0;
}

# check if variable is array
sub isarray {
  my $r = shift;
  return 1 if(ref($r) eq 'ARRAY');
  return 0;
}

1;
