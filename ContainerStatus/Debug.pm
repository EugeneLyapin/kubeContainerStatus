package ContainerStatus::Debug;

use 5.008008;
use strict;
use Exporter;
use base qw( Exporter );
use POSIX qw(strftime);
use POSIX qw(getpid);

our @EXPORT = qw(
            debug
            errx
            quit
        );

sub errx {
    my $msg = shift;
    logger(level => 'CRITICAL', message => $msg);
    exit(1);
}

sub debug {
    my $msg = shift;
    logger(level => 'INFO', message => $msg);
}

sub quit {
    my $msg = shift;
    logger(level => 'OK', message => $msg);
    exit(0);
}

sub logger {
    my (%args) = @_;
    my $level = $args{level} || 'INFO';
    my $msg = $args{message};
    return 0 if not defined $msg;
    my $curtime = strftime "%Y-%m-%d %H:%M:%S", localtime;
    my $pid = getpid();
    print STDOUT "$curtime ContainerStatus[$pid] [$level] $msg\n";
    return 0;
}

1;
