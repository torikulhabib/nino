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

public class nino.MainWindow : Window {
    private Gtk.Button lock_button;
    private Gtk.Button keep_button;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            resizable: false,
            hexpand: true,
            height_request: 272,
            width_request: 525
        );
    }

    construct {
        Timeout.add_seconds (1, () => {
            update_data ();
            return true;
        });
        Timeout.add (50, () => {
            set_lock_symbol ();
            set_keep_symbol ();
            return false;
        });
        headerbar.pack_start (lock_button_widget ());
        headerbar.pack_start (mini_button_widget ());
        headerbar.pack_end (menu_button_widget ());
        headerbar.pack_end (keep_button_widget ());
        close_button_revealer.set_reveal_child (true);
        update_position (settings.window_x, settings.window_y);
        show_all ();
    }

    private Gtk.Widget lock_button_widget () {
        lock_button = new Gtk.Button ();
        lock_button.tooltip_text = StringPot.Desktop;
        lock_button.can_focus = false;
        lock_button.clicked.connect (() => {
            settings.lock_switch ();
            set_lock_symbol ();
        });
        set_lock_symbol ();
        return lock_button;
    }

    private Gtk.Widget keep_button_widget () {
        keep_button = new Gtk.Button ();
        keep_button.can_focus = false;
        keep_button.clicked.connect (() => {
            settings.keep_switch ();
            set_keep_symbol ();
        });
        set_keep_symbol ();
        return keep_button;
    }

    private Gtk.Widget mini_button_widget () {
        var mini_button = new Gtk.Button.from_icon_name ("window-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        mini_button.tooltip_text = StringPot.MiniWindow;
        mini_button.clicked.connect (() => {
            var miniwindow = new MiniWindow (application);
            miniwindow.show_all ();
            hide_on_delete ();
            update_position (settings.window_x, settings.window_y);
            NinoApp.settings.set_enum ("window-mode", 1);
            miniwindow.destroy.connect (() => {
                // If miniwinidow is closed, also close mainwindow and quit the app
                destroy ();
            });

            miniwindow.present ();
        });
        return mini_button;
    }

    private void set_lock_symbol () {
        switch (settings.lock_mode) {
            case nino.Configs.LockMode.LOCK :
                lock_button.image = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
                lock_button.tooltip_text = StringPot.Lock;
                type_hint = Gdk.WindowTypeHint.DESKTOP;
                update_position (settings.window_x, settings.window_y);
                stick ();
                break;
            case nino.Configs.LockMode.UNLOCK :
                lock_button.image = new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON);
                lock_button.tooltip_text = StringPot.Unlock;
                type_hint = Gdk.WindowTypeHint.DIALOG;
                unstick ();
                break;
        }
    }

    private void set_keep_symbol () {
        switch (settings.keep_mode) {
            case nino.Configs.KeepMode.ABOVE :
                keep_button.image = new Gtk.Image.from_icon_name ("go-top-symbolic", Gtk.IconSize.BUTTON);
                keep_button.tooltip_text = StringPot.Above;
                set_keep_above (true);
                set_keep_below (false);
                break;
            case nino.Configs.KeepMode.BELOW :
                keep_button.image = new Gtk.Image.from_icon_name ("go-bottom-symbolic", Gtk.IconSize.BUTTON);
                keep_button.tooltip_text = StringPot.Below;
                set_keep_above (false);
                set_keep_below (true);
                break;
        }
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        int root_x, root_y;
        get_position (out root_x, out root_y);
        settings.window_x = root_x;
        settings.window_y = root_y;

        return base.configure_event (event);
    }

    protected override Gtk.Grid content () {
        icon_up = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.MENU);
        icon_down = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.MENU);

        var upload_title = new Gtk.Label (StringPot.Upload);
        upload_title.hexpand = true;

        var download_title = new Gtk.Label (StringPot.Download);
        download_title.hexpand = true;

        var upload = new Gtk.Grid ();
        upload.row_spacing = 6;
        upload.width_request = 6;
        upload.attach (icon_up, 0, 0, 1, 1);
        upload.attach (network_up_label, 0, 1, 1, 1);
        upload.attach (upload_title, 0, 2, 1, 1);

        var download = new Gtk.Grid ();
        download.row_spacing = 6;
        download.width_request = 6;
        download.attach (icon_down, 0, 0, 1, 1);
        download.attach (network_down_label, 0, 1, 1, 1);
        download.attach (download_title, 0, 2, 1, 1);

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 6;
        main_grid.column_spacing = 14;
        main_grid.column_homogeneous = true;
        main_grid.row_spacing = 6;
        main_grid.attach (upload, 0, 0, 1, 1);
        main_grid.attach (download, 1, 0, 1, 1);

        return main_grid;
    }

    protected override Gtk.Grid no_network_conection () {
        var title_label = new Gtk.Label (StringPot.NetworkNotAvailable);
        title_label.hexpand = true;
        title_label.get_style_context ().add_class ("h2");
        title_label.max_width_chars = 40;
        title_label.wrap = true;
        title_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
        title_label.xalign = 0;

        var description_label = new Gtk.Label (StringPot.Connectto);
        description_label.hexpand = true;
        description_label.max_width_chars = 40;
        description_label.wrap = true;
        description_label.use_markup = true;
        description_label.xalign = 0;
        description_label.valign = Gtk.Align.START;

        var action_button = new Gtk.Button.with_label (StringPot.NetworkSettings);
        action_button.halign = Gtk.Align.END;
        action_button.get_style_context ().add_class ("string_color");
        action_button.margin_top = 2;
        action_button.margin_bottom = 2;

        var image = new Gtk.Image.from_icon_name ("network-error", Gtk.IconSize.DIALOG);
        image.margin_top = 6;
        image.valign = Gtk.Align.START;

        var layout = new Gtk.Grid ();
        layout.column_spacing = 16;
        layout.row_spacing = 4;
        layout.halign = Gtk.Align.CENTER;
        layout.valign = Gtk.Align.CENTER;
        layout.vexpand = true;
        layout.margin = 4;

        layout.attach (image, 1, 1, 1, 2);
        layout.attach (title_label, 2, 1, 1, 1);
        layout.attach (description_label, 2, 2, 1, 1);
        layout.attach (action_button, 2, 3, 1, 1);

        action_button.clicked.connect (() => {
            try {
                AppInfo.launch_default_for_uri ("settings://network", null);
            } catch (Error e) {
                warning (e.message);
            }
        });

        return layout;
    }
}
