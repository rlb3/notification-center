use inc::Module::Install;

name     'MooseX-Notification';
all_from 'lib/MooseX/Notification.pm';
author   'Robert Boone <rlb@cpan.org>';
license  'Perl';

requires 'Moose';
requires 'Set::Object';

build_requires 'Test::More';
build_requires 'Bread::Board';

auto_install;

WriteAll;

