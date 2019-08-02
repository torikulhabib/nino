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
    public class Preferences : Gtk.Dialog {
        private Button btn_white;
        private Button btn_black;
        private Button btn_pink;
        private Button btn_red;
        private Button btn_orange;
        private Button btn_yellow;
        private Button btn_green;
        private Button btn_teal;
        private Button btn_blue;
        private Button btn_purple;
        private Button btn_coco;
        private Button btn_blue_green;
        private Button btn_purple_red;
        private Button btn_rainbow;
        private Button btn_red_pink;
        private Button btn_orange_yellow;

        private const int BTN_SIZE = 25;
        public signal void color_selected (string color);

        public Preferences (Gtk.Window? parent) {
            Object (
                border_width: 0,
                deletable: false,
                resizable: false,
                transient_for: parent,
                destroy_with_parent: true,
                type_hint: Gdk.WindowTypeHint.DIALOG,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT);
        }

        construct {
            set_keep_above (true);
            var style_context = get_style_context ();
            style_context.add_class ("preferences");
            var img = new Image.from_icon_name ("preferences-color" , IconSize.DIALOG);
            var label = new Gtk.Label (StringPot.SelectColor);
            label.get_style_context ().add_class ("string_color");

            btn_white = new Button();
            btn_white.name = Color.WHITE.to_string ();
            btn_black = new Button();
            btn_black.name = Color.BLACK.to_string ();
            btn_pink  = new Button();
            btn_pink.name = Color.PINK.to_string ();
            btn_red = new Button();
            btn_red.name = Color.RED.to_string ();
            btn_orange = new Button();
            btn_orange.name = Color.ORANGE.to_string ();
            btn_yellow = new Button();
            btn_yellow.name = Color.YELLOW.to_string ();
            btn_green = new Button();
            btn_green.name = Color.GREEN.to_string ();
            btn_teal = new Button();
            btn_teal.name = Color.TEAL.to_string ();
            btn_blue = new Button();
            btn_blue.name = Color.BLUE.to_string ();
            btn_purple  = new Button();
            btn_purple.name = Color.PURPLE.to_string ();
            btn_coco  = new Button();
            btn_coco.name = Color.COCO.to_string ();
            btn_blue_green = new Button();
            btn_blue_green.name = Color.GRADIENT_BLUE_GREEN.to_string ();
            btn_purple_red = new Button();
            btn_purple_red.name = Color.GRADIENT_PURPLE_RED.to_string ();
            btn_rainbow = new Button();
            btn_rainbow.name = Color.GRADIENT_RAINBOW.to_string ();
            btn_red_pink  = new Button();
            btn_red_pink.name = Color.GRADIENT_RED_PINK.to_string ();
            btn_orange_yellow  = new Button();
            btn_orange_yellow.name = Color.GRADIENT_ORANGE_YELLOW.to_string ();

            List<Button> buttons = new List<Button> ();
            buttons.append(btn_white);
            buttons.append(btn_black);
            buttons.append(btn_pink);
            buttons.append(btn_red);
            buttons.append(btn_orange);
            buttons.append(btn_yellow);
            buttons.append(btn_green);
            buttons.append(btn_teal);
            buttons.append(btn_blue);
            buttons.append(btn_purple);
            buttons.append(btn_coco);
            buttons.append(btn_blue_green);
            buttons.append(btn_purple_red);
            buttons.append(btn_rainbow);
            buttons.append(btn_red_pink);
            buttons.append(btn_orange_yellow);

            foreach (var btn in buttons) {
                btn.get_style_context ().add_class ("button_colors");
                btn.width_request = BTN_SIZE;
                btn.height_request = BTN_SIZE;
                btn.button_press_event.connect ( () => {
                    color_selected (btn.name);
                    return true;
                });
            }

            btn_white.get_style_context ().add_class ("btn_white");
            btn_black.get_style_context ().add_class ("btn_black");
            btn_pink.get_style_context ().add_class ("btn_pink");
            btn_red.get_style_context ().add_class ("btn_red");
            btn_orange.get_style_context ().add_class ("btn_orange");
            btn_green.get_style_context ().add_class ("btn_green");
            btn_teal.get_style_context ().add_class ("btn_teal");
            btn_blue.get_style_context ().add_class ("btn_blue");
            btn_yellow.get_style_context ().add_class ("btn_yellow");
            btn_purple.get_style_context ().add_class ("btn_purple");
            btn_coco.get_style_context ().add_class ("btn_coco");
            btn_blue_green.get_style_context ().add_class ("btn_gradient_blue_green");
            btn_purple_red.get_style_context ().add_class ("btn_gradient_purple_red");
            btn_rainbow.get_style_context ().add_class ("btn_gradient_pride");
            btn_orange_yellow.get_style_context ().add_class ("btn_orange_yellow");
            btn_red_pink.get_style_context ().add_class ("btn_red_pink");

            btn_white.set_tooltip_text (StringPot.White);
            btn_black.set_tooltip_text (StringPot.Black);
            btn_pink.set_tooltip_text (StringPot.Pink);
            btn_red.set_tooltip_text (StringPot.Red);
            btn_orange.set_tooltip_text (StringPot.Orange);
            btn_green.set_tooltip_text (StringPot.Green);
            btn_teal.set_tooltip_text (StringPot.Teal);
            btn_yellow.set_tooltip_text (StringPot.Yellow);
            btn_blue.set_tooltip_text (StringPot.Blue);
            btn_purple.set_tooltip_text (StringPot.Purple);
            btn_coco.set_tooltip_text (StringPot.Coco);
            btn_blue_green.set_tooltip_text (StringPot.BlueToGreen);
            btn_purple_red.set_tooltip_text (StringPot.PurpleToRed);
            btn_rainbow.set_tooltip_text (StringPot.Rainbow);
            btn_orange_yellow.set_tooltip_text (StringPot.OrangeToYellow);
            btn_red_pink.set_tooltip_text (StringPot.RedToPink);

            var main_grid = new Gtk.Grid ();
            main_grid.margin = 8;
            main_grid.row_spacing = 8;
            main_grid.column_spacing = 8;
            main_grid.margin_top = 0;
            main_grid.column_homogeneous = true;

            main_grid.attach (img,                0, 0, 6, 1);
            main_grid.attach (label,              0, 1, 6, 1);
            main_grid.attach (btn_white,          0, 3, 1, 1);
            main_grid.attach (btn_black,          1, 3, 1, 1);
            main_grid.attach (btn_pink,           2, 3, 1, 1);
            main_grid.attach (btn_red,            3, 3, 1, 1);
            main_grid.attach (btn_orange,         4, 3, 1, 1);
            main_grid.attach (btn_yellow,         5, 3, 1, 1);
            main_grid.attach (btn_green,          0, 4, 1, 1);
            main_grid.attach (btn_teal,           1, 4, 1, 1);
            main_grid.attach (btn_blue,           2, 4, 1, 1);
            main_grid.attach (btn_purple,         3, 4, 1, 1);
            main_grid.attach (btn_coco,           4, 4, 1, 1);
            main_grid.attach (btn_blue_green,     5, 4, 1, 1);
            main_grid.attach (btn_purple_red,     0, 5, 1, 1);
            main_grid.attach (btn_orange_yellow,  1, 5, 1, 1);
            main_grid.attach (btn_red_pink,       2, 5, 1, 1);
            main_grid.attach (btn_rainbow,        3, 5, 1, 1);

            var content = get_content_area () as Gtk.Box;
            content.margin = 6;
            content.margin_top = 0;
            content.add (main_grid);

            var close_button = add_button (StringPot.Close, Gtk.ResponseType.CLOSE);
            close_button.get_style_context ().add_class ("string_color");
            ((Gtk.Button) close_button).clicked.connect (() => destroy ());

            button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_PRIMARY) {
                    begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                    return true;
                }
                return false;
            }); 
        }
    }
}
