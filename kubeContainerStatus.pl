use strict;

use ContainerStatus;
use ContainerStatus::Debug;
use ContainerStatus::Config;

my $starttime = time();
my $conf = getConf();
my $running = 0;
my $options = $conf->{Options};

for (my $i=0; $i <= $options->{CYCLES}; $i++) {
    sleep $options->{DELAY};
    my $now = time();
    my $difftime = $now - $starttime;
    my $res = getContainerStatus($conf);
    $running++ if $res == 0;
    $running = 0 if $res > 0;

    if ($difftime > $options->{TIMEOUT}) {
        quit('All containers are running after timeout') if $running > 0;
        errx("timeout");
    }
    quit('All containers are running') if $running >= $options->{RUNNING_CYCLES};
}
