use strict;
use Kube::Debug;
use Kube::Config;

sub getConf {
    my %opts = ();
    my $kubeargs = getKubeArgs();
    my $IMAGE_TAG_STATUS = $ENV{IMAGE_TAG_STATUS} || undef;
    errx('IMAGE_TAG_STATUS is not defined') unless defined $IMAGE_TAG_STATUS;
    errx('IMAGE_TAG_STATUS has incorrect value') unless ($IMAGE_TAG_STATUS eq 'ImageTagChanged' or $IMAGE_TAG_STATUS eq 'ImageTagNotChanged');

    my $conf = {
        IMAGE_TAG_STATUS => $IMAGE_TAG_STATUS,
        kubeargs => $kubeargs
    };

    return $conf;
}

sub deletePods {
    my $conf = getConf();
    quit('Nothing to do') if $conf->{IMAGE_TAG_STATUS} eq 'ImageTagChanged';
    my $cmd = "kubectl delete pods $conf->{kubeargs} 2>&1";
    my $data = qx{ $cmd };
    my $cmdres = $?;
    errx('kubectl error: ' . $data) if ( $cmdres ne 0 );
}

deletePods();
