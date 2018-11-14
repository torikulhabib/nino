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

using Gtk;

namespace nino {
    public class MiniWindow : Gtk.Dialog {
    private Grid network_view;
    private Stack stack;
    private Label network_down_label;
    private Label network_up_label;
    Net net;
        public MiniWindow (Gtk.Window? parent) {
            Object (
                border_width: 0,
                deletable: false,
                resizable: false,
                transient_for: parent,
                destroy_with_parent: true,
                height_request: 20,
                width_request: 120
            );
        }

        construct {
            update ();
            net = new Net ();
            set_keep_above (true);
            set_keep_below (false);

            network_up_label = new Gtk.Label ("UPLOAD");
            network_up_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            network_up_label.tooltip_text = _("Upload Speed");
            network_up_label.hexpand = true;

	        network_down_label = new Gtk.Label ("DOWNLOAD");
            network_down_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            network_down_label.hexpand = true;
            network_down_label.tooltip_text = _("Download Speed");

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

            var content = get_content_area () as Gtk.Box;
            content.margin = 4;
            content.margin_top = 0;
            content.add (stack);

            main_grid.attach (network_up_label,            0, 0, 1, 1);
            main_grid.attach (network_down_label,          0, 1, 1, 1);

            var settings = nino.Configs.Settings.get_instance ();
            int x = settings.dialog_x;
            int y = settings.dialog_y;

            if (x != -1 && y != -1) {
                move (x, y);
            }

            button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_PRIMARY) {
                    begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                    return true;
                }
                return false;
            }); 
        }

    private void update_view () {
            var connection_available = NetworkMonitor.get_default ().get_network_available ();

            Timeout.add_seconds (1, () => {
            if (connection_available) {
            stack.visible_child_name = "main";
            } else {
            stack.visible_child_name = "no_network";
            }
            return false;
            });
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
    public override bool configure_event (Gdk.EventConfigure event) {
            var settings = nino.Configs.Settings.get_instance ();
            int root_x, root_y;
            get_position (out root_x, out root_y);
            settings.dialog_x = root_x;
            settings.dialog_y = root_y;
            return base.configure_event (event);
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
