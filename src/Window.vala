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

public abstract class nino.Window : Gtk.Window {
    protected nino.Configs.Settings settings;
    private Preferences? preferences_dialog = null;
    private Gtk.Stack stack;
    protected Gtk.Button close_button;
    protected Gtk.HeaderBar headerbar;
    protected Gtk.Label network_down_label;
    protected Gtk.Label network_up_label;
    protected Gtk.Label network_total_label;
    protected Gtk.Image icon_down_total;
    protected Gtk.Image icon_up_total;
    protected Gtk.Image icon_down;
    protected Gtk.Image icon_up;
    protected Gtk.Revealer close_button_revealer;
    private Net net;

    construct {
        settings = nino.Configs.Settings.get_settings ();
        net = new Net ();
        network_total_label = new Gtk.Label (StringPot.UpDown);
        network_total_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        network_total_label.hexpand = true;

        network_up_label = new Gtk.Label (StringPot.Upload);
        network_up_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        network_up_label.hexpand = true;

        network_down_label = new Gtk.Label (StringPot.Download);
        network_down_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        network_down_label.hexpand = true;

        icon_down_total = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.MENU);
        icon_up_total = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.MENU);
        icon_down = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.MENU);
        icon_up = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.MENU);

        var spinner = new Gtk.Spinner ();
        spinner.active = true;
        spinner.halign = Gtk.Align.CENTER;
        spinner.vexpand = true;

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        stack.vhomogeneous = true;
        stack.add (spinner);
        stack.add_named (content (), "main");
        stack.add_named (no_network_conection (), "no_network");

        add (stack);

        close_button_revealer = new Gtk.Revealer ();
        close_button_revealer.add (close_button_widget ());
        close_button_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;

        headerbar = new Gtk.HeaderBar ();
        headerbar.has_subtitle = false;
        headerbar.pack_start (close_button_revealer);
        this.set_titlebar (headerbar);

        var header_context = headerbar.get_style_context ();
        header_context.add_class ("default-decoration");
        header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        get_style_context ().add_class ("nino");
        get_style_context ().add_class ("rounded");
        get_style_context ().add_class ("widget_background");
        get_style_context ().add_class ("title");
        get_style_context ().add_class ("flat");

        NetworkMonitor.get_default ().network_changed.connect (update_view);

        update_view ();
        bool mouse_primary_down = false;
        motion_notify_event.connect ((event) => {
            if (mouse_primary_down) {
                mouse_primary_down = false;
                begin_move_drag (Gdk.BUTTON_PRIMARY, (int)event.x_root, (int)event.y_root, event.time);
            }
            return false;
        });
        button_press_event.connect ((event) => {
            if (event.button == Gdk.BUTTON_PRIMARY) {
                mouse_primary_down = true;
            }
            return Gdk.EVENT_PROPAGATE;
        });
        button_release_event.connect ((event) => {
            if (event.button == Gdk.BUTTON_PRIMARY) {
                mouse_primary_down = false;
            }
            return false;
        });
    }

    private Gtk.Widget close_button_widget () {
        close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        close_button.tooltip_text = StringPot.Close;
        close_button.clicked.connect (() => {
            destroy ();
        });
        return close_button;
    }

    protected void update_data () {
        var bytes = net.get_bytes ();
        update_net_speed (bytes[0], bytes[1]);
        icon_up.sensitive = bytes [0].to_little_endian () == 0 ? false : true;
        icon_down.sensitive = bytes [1].to_little_endian () == 0 ? false : true;
        icon_up_total.sensitive = bytes [0].to_little_endian () == 0 ? false : true;
        icon_down_total.sensitive = bytes [1].to_little_endian () == 0 ? false : true;
    }

    private void update_net_speed (int bytes_out, int bytes_in) {
        network_up_label.set_label (Utils.format_net_speed (bytes_out));
        network_down_label.set_label (Utils.format_net_speed (bytes_in));
        network_total_label.set_label (Utils.format_net_speed (bytes_in + bytes_out)); 
    }

    protected void update_position (int x, int y) {
        if (x != -1 && y != -1) {
            move (x, y);
        }
    }

    private void update_view () {
        var connection_available = NetworkMonitor.get_default ().get_network_available ();

        GLib.Timeout.add (50, () => {
            if (connection_available) {
                stack.visible_child_name = "main";
            } else {
                stack.visible_child_name = "no_network";
            }
            return false;
        });
    }
    protected Gtk.Widget menu_button_widget () {
        var menu_button = new Gtk.Button.from_icon_name ("applications-graphics-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        menu_button.tooltip_text = StringPot.Color;
        menu_button.clicked.connect (() => {
            if (preferences_dialog == null) {
                preferences_dialog = new Preferences (this);
                preferences_dialog.show_all ();
                preferences_dialog.color_selected.connect ((color) => {
                    change_color (color);
                });
                preferences_dialog.destroy.connect (() => {
                preferences_dialog = null;
                });
            }
            preferences_dialog.present ();
        });
        return menu_button;
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
        } else if (color == Color.GRADIENT_RAINBOW.to_string ()) {
            url_css = Constants.URL_CSS_RAINBOW;
        } else if (color == Color.GRADIENT_RED_PINK.to_string ()) {
            url_css = Constants.URL_CSS_GRADIENT_RED_PINK;
        } else if (color == Color.GRADIENT_ORANGE_YELLOW.to_string ()) {
            url_css = Constants.URL_CSS_GRADIENT_ORANGE_YELLOW;
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
    // The main grid of the app
    protected abstract Gtk.Grid content ();

    // Window shows an error message that the Internet connection is not available
    protected abstract Gtk.Grid no_network_conection ();
}
