# Project name and programming language
project('com.github.torikulhabib.nino', 'vala', 'c', version: '1.0.0')

# Adds project arguments
add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
    ],
    language: 'c',
)

# Include the translations module
gnome = import('gnome')
i18n = import('i18n')

as_resource = gnome.compile_resources(
    'as-resources', 'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# Set our translation domain
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PREFIX', get_option('prefix'))

subdir('src')

executable(
    meson.project_name(),
    sources,
    as_resource,
    dependencies: [
        dependency('gio-unix-2.0'),
        dependency('libgtop-2.0'),
        dependency('gtk+-3.0'),
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
