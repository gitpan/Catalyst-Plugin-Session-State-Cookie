use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'         => 'Catalyst::Plugin::Session::State::Cookie',
    'VERSION_FROM' => 'lib/Catalyst/Plugin/Session/State/Cookie.pm',
    'PREREQ_PM'    => {
        'Catalyst::Plugin::Session' => '0.06',
        'Test::MockObject'          => '1.01'
    },
    'INSTALLDIRS' => 'site',
    'EXE_FILES'   => [],
    'SIGN'        => 1,
    'PL_FILES'    => {},
);
