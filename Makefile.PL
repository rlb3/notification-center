use inc::Module::Install;

name     'MooseX-Notification';
all_from 'lib/MooseX/Notification.pm';
author   'Robert Boone <rlb@cpan.org>';

requires 'Moose';
requires 'MooseX::Singleton';
requires 'Set::Object';

build_requires 'Test::More';

auto_install;

WriteAll;

