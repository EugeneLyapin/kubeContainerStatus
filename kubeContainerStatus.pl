use strict;

use ContainerStatus;
use ContainerStatus::Debug;
use ContainerStatus::Config;

my $starttime = time();
my $conf = getConf();

for (my $i=0; $i <= int($conf->{TIMEOUT}*2/$conf->{DELAY}); $i++) {
    sleep $conf->{DELAY};
    my $now = time();
    errx("timeout") if ($now - $starttime > $conf->{TIMEOUT});
    getContainerStatus($conf);
}
