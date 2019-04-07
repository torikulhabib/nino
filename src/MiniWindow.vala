/*
* Copyright (c) 2019 torikulhabib https://github.com/torikulhabib/nino
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: torikulhabib <torik.habib@gmail.com>
*/

public class nino.MiniWindow : Window {
    private Gtk.Button mini_lock_button;

    public MiniWindow (Gtk.Application application) {
        Object (
            application: application,
            border_width: 0,
            resizable: false,
            height_request: 20,
            width_request: 120
        );
    }

    construct {
        Timeout.add_seconds (1, () => {
            update_data ();
            return true;
        });

        set_keep_above (true);
        set_keep_below (false);

        mini_lock_button = new Gtk.Button ();
        mini_lock_button.tooltip_text = _("Position");
        mini_lock_button.can_focus = false;
        mini_lock_button.clicked.connect (() => {
            settings.mini_lock_switch ();
            set_mini_lock_symbol ();
        });

        set_mini_lock_symbol ();

        var main_button = new Gtk.Button.from_icon_name ("window-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        main_button.tooltip_text = _("Mini Window");
        main_button.clicked.connect (() => {
            debug ("MainWindow button pressed.");
            var mainwindow = new MainWindow (application);
            mainwindow.show_all ();
            hide_on_delete ();
            update_position (settings.dialog_x, settings.dialog_y);
            NinoApp.settings.set_enum ("window-mode", 0);
            mainwindow.destroy.connect (() => {
                // If mainwindow is closed, also close miniwinidow and quit the app
                destroy ();
            });

            mainwindow.present ();
        });

        headerbar.pack_end (main_button);
        headerbar.pack_end (mini_lock_button);

        update_position (settings.dialog_x, settings.dialog_y);
        show_all ();
    }

    private void set_mini_lock_symbol () {
        switch (settings.mini_lock_mode) {
            case nino.Configs.MiniLockMode.LOCK :
                mini_lock_button.image = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
                stick ();
                type_hint = Gdk.WindowTypeHint.SPLASHSCREEN;
                break;
            case nino.Configs.MiniLockMode.UNLOCK :
                mini_lock_button.image = new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON);
                unstick ();
                type_hint = Gdk.WindowTypeHint.DIALOG;
                break;
        }
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        int root_x, root_y;
        get_position (out root_x, out root_y);
        settings.dialog_x = root_x;
        settings.dialog_y = root_y;

        return base.configure_event (event);
    }

    protected override Gtk.Grid content () {
        network_up_label.tooltip_text = _("Upload Speed");
        network_down_label.tooltip_text = _("Download Speed");

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 4;
        main_grid.row_spacing = 4;
        main_grid.column_spacing = 0;
        main_grid.margin_top = 0;
        main_grid.column_homogeneous = true;
        main_grid.attach (network_up_label, 0, 0, 1, 1);
        main_grid.attach (network_down_label, 0, 1, 1, 1);

        return main_grid;
    }

    protected override Gtk.Grid no_network_conection () {
        var alert = new Gtk.Image.from_icon_name ("network-error", Gtk.IconSize.DIALOG);
        alert.tooltip_text = _("Network is not available");

        var network_view = new Gtk.Grid ();
        network_view.margin = 0;
        network_view.column_spacing = 0;
        network_view.column_homogeneous = true;
        network_view.row_spacing = 0;
        network_view.attach (alert, 0, 0, 1, 1);

        return network_view;
    }
}
