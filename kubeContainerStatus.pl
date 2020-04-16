use strict;

use ContainerStatus;
use ContainerStatus::Debug;
use ContainerStatus::Config;

my $starttime = time();
my $conf = getConf();
my $running;

for (my $i=0; $i <= int($conf->{TIMEOUT}*2/$conf->{DELAY}); $i++) {
    sleep $conf->{DELAY};
    my $now = time();
    errx("timeout") if ($now - $starttime > $conf->{TIMEOUT});
    $res = getContainerStatus($conf);
    $running++ if $res == 0;
    $running = 0 if $res > 0;
    quit('All containers are running') if $running > 3;
}
