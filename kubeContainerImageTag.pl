use strict;
use JSON::PP;
use ContainerStatus::Debug;

sub getConf {
    my %opts = ();
    my $NAMESPACE = $ENV{NAMESPACE} || 'default';
    my $PROJECT_NAME = $ENV{PROJECT_NAME} || undef;
    my $AWS_CLUSTER = $ENV{AWS_CLUSTER} || undef;
    my $TOKEN = $ENV{TOKEN} || undef;
    my $CI_REGISTRY_IMAGE = $ENV{CI_REGISTRY_IMAGE} || undef;
    my $TAG_NAME = $ENV{TAG_NAME} || undef;
    errx('PROJECT_NAME is not defined') if not defined $PROJECT_NAME;
    errx('CI_REGISTRY_IMAGE is not defined') if not defined $CI_REGISTRY_IMAGE;
    errx('TAG_NAME is not defined') if not defined $TAG_NAME;
    my $kubeargs = "--namespace $NAMESPACE -l app=$ENV{PROJECT_NAME}";
    $kubeargs .= " --token=$TOKEN" if defined $TOKEN;
    $kubeargs .= " --cluster $AWS_CLUSTER" if defined $AWS_CLUSTER;

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
    errx('kubectl error: ' . $jsondata) if ( $cmdres ne 0);
    my $data = decode_json($jsondata);
    my $items = $data->{items} || [];
    errx('no data') if (scalar @{$items} eq 0);
    foreach my $item (@{$items}) {
        my $Containers = $item->{spec}->{containers};
        for my $Container (@{$Containers}) {
            my $state = ( $Container->{image} eq $conf->{NewImageName} ) ? 'ImageTagNotChanged' : 'ImageTagChanged';
            quit($state);
        }
    }
}

getContainerImageTag();
