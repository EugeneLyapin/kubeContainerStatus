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
    my $containers = 0;
    my $running = 0;
    my $ContainerStatuses = $conf->{ContainerStatuses};
    my $ErrCodes = $ContainerStatuses->{Error};
    my $PendingCodes = $ContainerStatuses->{Pending};
    my $RunningCodes = $ContainerStatuses->{Running};

    foreach my $item (@{$items}) {
        my $ContainerStatuses = $item->{status}->{containerStatuses};
        $containers += scalar @{$ContainerStatuses};
        foreach my $ContainerStatus (@{$ContainerStatuses}) {
            my $Id = $ContainerStatus->{containerID};
            my $restartCount = $ContainerStatus->{restartCount};
            my $status = $ContainerStatus->{state};
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

            if (ishash($RunningCodes->{$s})) {
                $running++;
                if (getStatistics($conf, $Id, 'restartCount') < $restartCount) {
                    updateStatistics($conf, $Id, 'restartCount', $restartCount);
                    debug('State=UNSTABLE ContainerID='.$Id.' restartCount='.$restartCount);
                    $running--;
                }
            }
        }
    }

    debug('containers='. $containers . ' running=' . $running);
    return 0 if ($running eq $containers and $containers > 0);
    return 1;
}

sub getStatistics {
    my $conf = shift;
    my $Id = shift;
    my $key = shift;
    return 0 unless ishash($conf->{Statistics}->{$Id});
    return 0 unless defined $conf->{Statistics}->{$Id}->{$key};
    return $conf->{Statistics}->{$Id}->{$key};
}

sub updateStatistics {
    my $conf = shift;
    my $Id = shift;
    my $key = shift;;
    my $value = shift;
    $conf->{Statistics}->{$Id}->{$key} = $value;
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
