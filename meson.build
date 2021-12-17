project('com.github.leggettc18.subsketeer', 'vala', 'c')

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

executable (
    meson.project_name(),
    'src' / 'Application.vala',
    'src' / 'MainWindow.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('libhandy-1'),
        dependency('granite'),
        dependency('gee-0.8'),
        dependency('gdk-3.0')
    ],
    install: true
)

i18n.merge_file(
    input: 'data' / 'subsketeer.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'data' / 'subsketeer.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: meson.source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

meson.add_install_script('meson/post_install.py')

subdir('po')
subdir('data')
