/*
* Copyright (c) 2018 torikulhabib https://github.com/torikulhabib/nino
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

using nino.Configs;
using Gtk;

namespace nino {
    public class MiniWindow : Gtk.Window {
    private MainWindow mainwindow;
    private Grid network_view;
    private Stack stack;
    private Label network_down_label;
    private Label network_up_label;
    private Image mini_icon_lock;
    private Image mini_icon_unlock;
    private Button close_button;
    private Button mini_lock_button;

    Net net;

    public MiniWindow (Gtk.Application application) {
            Object (application: application,
                    border_width: 0,
                    resizable: false,
                    destroy_with_parent: true,
                    height_request: 20,
                    width_request: 120
            );
        }

    construct {
            update ();

            net = new Net ();
            var settings = nino.Configs.Settings.get_settings ();
            int x = settings.dialog_x;
            int y = settings.dialog_y;

            if (x != -1 && y != -1) {
                move (x, y);
            }

            set_keep_above (true);
            set_keep_below (false);

		    settings.notify["mini-lock-mode"].connect (() => {
            set_mini_lock_symbol ();
		    });

            mini_icon_lock = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            mini_icon_unlock = new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON);

            mini_lock_button = new Gtk.Button ();
            set_mini_lock_symbol ();
            mini_lock_button.tooltip_text = _ ("Position");
            mini_lock_button.can_focus = false;
            mini_lock_button.clicked.connect (() => {
                settings.mini_lock_switch ();
                set_mini_lock_symbol ();
            });

            var main_button = new Button.from_icon_name ("window-new-symbolic", IconSize.SMALL_TOOLBAR);
            main_button.tooltip_text = _("Mini Window");
            main_button.clicked.connect (() => {
                if (mainwindow == null) {
                    debug ("MainWindow button pressed.");
                    mainwindow = new MainWindow (application);
                    mainwindow.show_all ();
                    hide_on_delete ();
                    update_position ();
                    NinoApp.settings.set_enum ("window-mode", 0);
                    mainwindow.destroy.connect (() => {
                        // If mainwindow is closed, also close miniwinidow and quit the app
                        destroy ();
                    });
                }

                mainwindow.present ();
            });

            network_up_label = new Gtk.Label ("UPLOAD");
            network_up_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            network_up_label.tooltip_text = _("Upload Speed");
            network_up_label.hexpand = true;

	        network_down_label = new Gtk.Label ("DOWNLOAD");
            network_down_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            network_down_label.hexpand = true;
            network_down_label.tooltip_text = _("Download Speed");

            close_button = new Button.from_icon_name ("window-close-symbolic", IconSize.SMALL_TOOLBAR);
            close_button.tooltip_text = _("Close");

            close_button.clicked.connect (() => {
                destroy ();
            });

            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.pack_start (close_button);
            headerbar.pack_end (main_button);
            headerbar.pack_end (mini_lock_button);
            this.set_titlebar (headerbar);

            var header_context = headerbar.get_style_context ();
            header_context.add_class ("default-decoration");
            header_context.add_class (Gtk.STYLE_CLASS_FLAT);

            var style_context = get_style_context ();
            style_context.add_class ("rounded");
            style_context.add_class ("widget_background");
            style_context.add_class ("flat");

            var main_grid = new Gtk.Grid ();
            main_grid.margin = 4;
            main_grid.row_spacing = 4;
            main_grid.column_spacing = 0;
            main_grid.margin_top = 0;
            main_grid.column_homogeneous = true;

            network_conection ();
            update_view ();
            NetworkMonitor.get_default ().network_changed.connect (update_view);
            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            stack.homogeneous = true;
            stack.add_named (main_grid, "main");
            stack.add_named (network_view, "no_network");

            var overlay = new Gtk.Overlay ();
            overlay.margin = 4;
            overlay.margin_top = 0;
            overlay.add (stack);
            add (overlay);
            show_all ();

            main_grid.attach (network_up_label,            0, 0, 1, 1);
            main_grid.attach (network_down_label,          0, 1, 1, 1);

            button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_PRIMARY) {
                    begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                    return true;
                }
                return false;
            }); 
        }

    public override bool configure_event (Gdk.EventConfigure event) {
            var settings = nino.Configs.Settings.get_settings ();
            int root_x, root_y;
            get_position (out root_x, out root_y);
            settings.dialog_x = root_x;
            settings.dialog_y = root_y;
            return base.configure_event (event);
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

    private void update_position () {
        var settings = nino.Configs.Settings.get_settings ();
        int x = settings.window_x;
        int y = settings.window_y;
        if (x != -1 && y != -1) {
            move (x, y);
        }
    }

    private void set_mini_lock_symbol () {
            var settings = nino.Configs.Settings.get_settings ();
            switch (settings.mini_lock_mode) {
            case MiniLockMode.LOCK :
                mini_lock_button.set_image (mini_icon_lock);
                stick ();
                type_hint = Gdk.WindowTypeHint.SPLASHSCREEN;
                break;
            case MiniLockMode.UNLOCK :
                mini_lock_button.set_image (mini_icon_unlock);
                unstick ();
                type_hint = Gdk.WindowTypeHint.DIALOG;
                break;
            }
            mini_lock_button.show_all ();
        }

    private void network_conection () {

            var alert = new Gtk.Image.from_icon_name ("network-error", Gtk.IconSize.DIALOG);
            alert.tooltip_text = _("Network Is Not Available");
            network_view = new Gtk.Grid ();
            network_view.margin = 0;
            network_view.column_spacing = 0;
            network_view.column_homogeneous = true;
            network_view.row_spacing = 0;
            network_view.attach (alert, 0, 0, 1, 1);

    }

    private void update () {
            Timeout.add_seconds (1, () => {
            update_data ();
                return true;
            });
    }

    private void update_data () {
            var bytes = net.get_bytes();
            update_net_speed (bytes[0], bytes[1]);
    }

    public void update_net_speed (int bytes_out, int bytes_in) {
            network_up_label.set_label (Utils.format_net_speed (bytes_out, true));
            network_down_label.set_label (Utils.format_net_speed (bytes_in, true));
    }
    }
}
