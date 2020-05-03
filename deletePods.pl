use strict;

use JSON::PP;
use Container::Debug;
use Container::Config;

sub getConf {
    my %opts = ();
    my $kubeargs = getKubeArgs();
    my $CI_REGISTRY_IMAGE = $ENV{CI_REGISTRY_IMAGE} || undef;
    my $TAG_NAME = $ENV{TAG_NAME} || undef;
    errx('CI_REGISTRY_IMAGE is not defined') if not defined $CI_REGISTRY_IMAGE;
    errx('TAG_NAME is not defined') if not defined $TAG_NAME;

    my $conf = {
        image => "$CI_REGISTRY_IMAGE:$TAG_NAME",
        kubeargs => $kubeargs
    };

    return $conf;
}

sub isImageTagChanged {
    my $conf = shift;
    my $cmd = "kubectl get pods $conf->{kubeargs} -o json 2>&1";
    my $jsondata = qx{ $cmd };
    my $cmdres = $?;
    errx('kubectl error: ' . $jsondata) if ( $cmdres ne 0 );
    my $data = decode_json($jsondata);
    my $items = $data->{items} || [];
    errx('no data') if (scalar @{$items} eq 0);
    my $images = {};
    foreach my $item (@{$items}) {
        my $Containers = $item->{spec}->{containers};
        for my $Container (@{$Containers}) {
            updateImages($images, $Container);
        }
    }

    foreach my $item (keys %{$images}) {
        return 0 if $images->{$item} eq $conf->{image};
    }

    return 1;
}

sub updateImages {
    my $data = shift;
    my $Container = shift;

    my $key = $Container->{name};
    my $value = $Container->{image};
    unless (defined $data->{$key}) {
        $data->{$key} = $value;
        return 0;
    }

    return 0 if ($data->{$key} eq $value);
    debug(encode_json({
        ContainerName => $key,
        image1 => $data->{$key},
        image2 => $value
    }));

    quit('SKIP deleting pods, existing images are different');
}

sub main {
    my $conf = getConf();
    quit('SKIP deleting pods, image changes') if isImageTagChanged($conf);
    my $cmd = "kubectl delete pods $conf->{kubeargs} 2>&1";
    my $data = qx{ $cmd };
    my $cmdres = $?;
    errx('kubectl error: ' . $data) if ( $cmdres ne 0 );
    quit('All pods are deleted')
}

main();
