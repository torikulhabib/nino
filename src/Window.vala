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
    private Gtk.Stack stack;
    protected Gtk.Button close_button;
    protected Gtk.HeaderBar headerbar;
    protected Gtk.Label network_down_label;
    protected Gtk.Label network_up_label;
    protected Gtk.Image icon_down;
    protected Gtk.Image icon_up;

    private Net net;

    construct {
        settings = nino.Configs.Settings.get_settings ();

        net = new Net ();

        network_up_label = new Gtk.Label (_("UPLOAD"));
        network_up_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        network_up_label.hexpand = true;

        network_down_label = new Gtk.Label (_("DOWNLOAD"));
        network_down_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        network_down_label.hexpand = true;

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

        headerbar = new Gtk.HeaderBar ();
        headerbar.has_subtitle = false;
        headerbar.pack_start (close_button_widget ());
        this.set_titlebar (headerbar);

        var header_context = headerbar.get_style_context ();
        header_context.add_class ("default-decoration");
        header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var style_context = get_style_context ();
        style_context.add_class ("nino");
        style_context.add_class ("rounded");
        style_context.add_class ("widget_background");
        style_context.add_class ("flat");

        NetworkMonitor.get_default ().network_changed.connect (update_view);

        update_view ();

        button_press_event.connect ((e) => {
            if (e.button == Gdk.BUTTON_PRIMARY) {
                begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                return true;
            }

            return false;
        });
    }

    private Gtk.Widget close_button_widget () {
        close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        close_button.tooltip_text = _("Close");
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
    }

    private void update_net_speed (int bytes_out, int bytes_in) {
        network_up_label.set_label (Utils.format_net_speed (bytes_out));
        network_down_label.set_label (Utils.format_net_speed (bytes_in));
    }

    protected void update_position (int x, int y) {
        if (x != -1 && y != -1) {
            move (x, y);
        }
    }

    private void update_view () {
        var connection_available = NetworkMonitor.get_default ().get_network_available ();

        GLib.Timeout.add_seconds (0, () => {
            if (connection_available) {
                stack.visible_child_name = "main";
            } else {
                stack.visible_child_name = "no_network";
            }

            return false;
        });
    }

    // The main grid of the app
    protected abstract Gtk.Grid content ();

    // Window shows an error message that the Internet connection is not available
    protected abstract Gtk.Grid no_network_conection ();
}
