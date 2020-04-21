use strict;
use JSON::PP;
use Kube::Debug;
use Kube::Config;

sub getConf {
    my %opts = ();
    my $kubeargs = getKubeArgs();
    my $CI_REGISTRY_IMAGE = $ENV{CI_REGISTRY_IMAGE} || undef;
    my $TAG_NAME = $ENV{TAG_NAME} || undef;
    errx('CI_REGISTRY_IMAGE is not defined') if not defined $CI_REGISTRY_IMAGE;
    errx('TAG_NAME is not defined') if not defined $TAG_NAME;

    my $conf = {
        NewImageName => "$CI_REGISTRY_IMAGE:$TAG_NAME",
        kubeargs => $kubeargs
    };

    return $conf;
}

sub getContainerImageTag {
    my $conf = getConf();
    my $cmd = "kubectl get pods $conf->{kubeargs} -o json 2>&1";
    my $jsondata = qx{ $cmd };
    my $cmdres = $?;
    errx('kubectl error: ' . $jsondata) if ( $cmdres ne 0 );
    my $data = decode_json($jsondata);
    my $items = $data->{items} || [];
    errx('no data') if (scalar @{$items} eq 0);
    foreach my $item (@{$items}) {
        my $Containers = $item->{spec}->{containers};
        for my $Container (@{$Containers}) {
            my $state = ( $Container->{image} eq $conf->{NewImageName} ) ? 'ImageTagNotChanged' : 'ImageTagChanged';
            pquit($state);
        }
    }
}

getContainerImageTag();
