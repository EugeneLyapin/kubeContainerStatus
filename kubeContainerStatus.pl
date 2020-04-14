use strict;

use ContainerStatus;
use ContainerStatus::Debug;
use ContainerStatus::Config;

my $starttime = time();
my $conf = getConf();

for (my $i=0; $i <= int($conf->{timeout}*1.5); $i++) {
    sleep 12;
    my $now = time();
    errx("timeout") if ($now - $starttime > $conf->{timeout});
    getContainerStatus($conf);
}
