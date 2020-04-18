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

            $running++ if ishash($RunningCodes->{$s});
        }
    }

    debug('containers='. $containers . ' running=' . $running);
    return 0 if ($running eq $containers and $containers > 0);
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
