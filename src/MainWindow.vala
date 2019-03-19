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

        lock_button = new Gtk.Button ();
        lock_button.tooltip_text = _("Desktop");
        lock_button.can_focus = false;
        lock_button.clicked.connect (() => {
            settings.lock_switch ();
            set_lock_symbol ();
        });

        keep_button = new Gtk.Button ();
        keep_button.tooltip_text = _("Window");
        keep_button.can_focus = false;
        keep_button.clicked.connect (() => {
            settings.keep_switch ();
            set_keep_symbol ();
        });

        set_lock_symbol ();
        set_keep_symbol ();

        var menu_button = new Gtk.Button.from_icon_name ("applications-graphics-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        menu_button.tooltip_text = _("Colors");
        menu_button.clicked.connect (() => {
            debug ("Prefs button pressed.");
            var preferences_dialog = new Preferences (this);
            preferences_dialog.show_all ();
            preferences_dialog.color_selected.connect ((color) => {
                change_color (color);
            });

            preferences_dialog.present ();
        });

        var mini_button = new Gtk.Button.from_icon_name ("window-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        mini_button.tooltip_text = _("Mini Window");
        mini_button.clicked.connect (() => {
            debug ("MiniWindow button pressed.");
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

        headerbar.pack_start (lock_button);
        headerbar.pack_start (mini_button);
        headerbar.pack_end (menu_button);
        headerbar.pack_end (keep_button);

        update_position (settings.window_x, settings.window_y);
        show_all ();
    }

    private void set_lock_symbol () {
        switch (settings.lock_mode) {
            case nino.Configs.LockMode.LOCK :
                lock_button.image = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
                stick ();
                type_hint = Gdk.WindowTypeHint.DESKTOP;
                update_position (settings.window_x, settings.window_y);
                break;
            case nino.Configs.LockMode.UNLOCK :
                lock_button.image = new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON);
                type_hint = Gdk.WindowTypeHint.DIALOG;
                unstick ();
                break;
        }
    }

    private void set_keep_symbol () {
        switch (settings.keep_mode) {
            case nino.Configs.KeepMode.ABOVE :
                keep_button.image = new Gtk.Image.from_icon_name ("go-top-symbolic", Gtk.IconSize.BUTTON);
                set_keep_above (true);
                set_keep_below (false);
                break;
            case nino.Configs.KeepMode.BELOW :
                keep_button.image = new Gtk.Image.from_icon_name ("go-bottom-symbolic", Gtk.IconSize.BUTTON);
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

    private void change_color (string color) {
        var css_provider = new Gtk.CssProvider ();
        var url_css = Constants.URL_CSS_WHITE;

        if (color == Color.WHITE.to_string ()) {
            url_css = Constants.URL_CSS_WHITE;
        } else if (color == Color.BLACK.to_string ()) {
            url_css = Constants.URL_CSS_DARK;
        } else if (color == Color.PINK.to_string ()) {
            url_css = Constants.URL_CSS_PINK;
        } else if (color == Color.RED.to_string ()) {
            url_css = Constants.URL_CSS_RED;
        } else if (color == Color.ORANGE.to_string ()) {
            url_css = Constants.URL_CSS_ORANGE;
        } else if (color == Color.YELLOW.to_string ()) {
            url_css = Constants.URL_CSS_YELLOW;
        } else if (color == Color.GREEN.to_string ()) {
            url_css = Constants.URL_CSS_GREEN;
        } else if (color == Color.TEAL.to_string ()) {
            url_css = Constants.URL_CSS_TEAL;
        } else if (color == Color.BLUE.to_string ()) {
            url_css = Constants.URL_CSS_BLUE;
        } else if (color == Color.PURPLE.to_string ()) {
            url_css = Constants.URL_CSS_PURPLE;
        } else if (color == Color.COCO.to_string ()) {
            url_css = Constants.URL_CSS_COCO;
        } else if (color == Color.GRADIENT_BLUE_GREEN.to_string ()) {
            url_css = Constants.URL_CSS_GRADIENT_BLUE_GREEN;
        } else if (color == Color.GRADIENT_PURPLE_RED.to_string ()) {
            url_css = Constants.URL_CSS_GRADIENT_PURPLE_RED;
        } else if (color == Color.GRADIENT_PRIDE.to_string ()) {
            url_css = Constants.URL_CSS_PRIDE;
        } else if (color == Color.TRANS_WHITE.to_string ()) {
            url_css = Constants.URL_CSS_LIGHT_TRANS;
        } else if (color == Color.TRANS_BLACK.to_string ()) {
            url_css = Constants.URL_CSS_DARK_TRANS;
        } else if (color == Color.SEMITRANS_WHITE.to_string ()) {
            url_css = Constants.URL_CSS_LIGHT_SEMITRANS;
        } else if (color == Color.SEMITRANS_BLACK.to_string ()) {
            url_css = Constants.URL_CSS_DARK_SEMITRANS;
        } else {
            settings.color = Color.WHITE.to_string ();
            url_css = Constants.URL_CSS_WHITE;
        }

        settings.color = color;

        css_provider.load_from_resource (url_css);
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    protected override Gtk.Grid content () {
        var icon_up = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.MENU);

        var upload_title = new Gtk.Label (_("Upload"));
        upload_title.hexpand = true;

        var upload = new Gtk.Grid ();
        upload.row_spacing = 6;
        upload.width_request = 6;
        upload.attach (icon_up, 0, 0, 1, 1);
        upload.attach (network_up_label, 0, 1, 1, 1);
        upload.attach (upload_title, 0, 2, 1, 1);

        var icon_down = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.MENU);

        var download_title = new Gtk.Label (_("Download"));
        download_title.hexpand = true;

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
        var title_label = new Gtk.Label (_("Network is Not Available"));
        title_label.hexpand = true;
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        title_label.max_width_chars = 40;
        title_label.wrap = true;
        title_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
        title_label.xalign = 0;

        var description_label = new Gtk.Label (_("Connect to the Internet to monitor network."));
        description_label.hexpand = true;
        description_label.max_width_chars = 40;
        description_label.wrap = true;
        description_label.use_markup = true;
        description_label.xalign = 0;
        description_label.valign = Gtk.Align.START;

        var action_button = new Gtk.Button.with_label (_("Network Settings…"));
        action_button.halign = Gtk.Align.END;
        action_button.get_style_context ().add_class ("AlertView");
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
