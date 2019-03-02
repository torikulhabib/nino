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
    public class MainWindow : Gtk.Window {
    private Stack stack;
    private Preferences preferences_dialog = null;
    private MiniWindow miniwindow = null;
    private Label network_down_label;
    private Label network_up_label;
    private Image icon_below;
    private Image icon_above;
    private Image icon_lock;
    private Image icon_unlock;
    private Image icon_down;
    private Image icon_up;
    private Button menu_button;
    private Button mini_button;
    private Button close_button;
    private Grid content;
    private Grid layout;
    private Grid upload;
    private Grid download;
    private Button action_button;
    private Button lock_button;
    private Button keep_button;
    private bool miniwindow_active = false;

    Net net;

    public  MainWindow (Gtk.Application application) {
            Object (application: application,
                    icon_name: "com.github.torikulhabib.nino",
                    resizable: false,
                    hexpand: true,
                    height_request: 272,
                    width_request: 525
            );
        }

    construct {
            update ();
            net = new Net ();

            var settings = nino.Configs.Settings.get_settings ();
		    settings.notify["lock-mode"].connect (() => {
            set_lock_symbol ();
		    });

            icon_lock = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            icon_unlock = new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON);

            lock_button = new Gtk.Button ();
            set_lock_symbol ();
            lock_button.tooltip_text = _ ("Desktop");
            lock_button.can_focus = false;
            lock_button.clicked.connect (() => {
                settings.lock_switch ();
            });

		    settings.notify["keep-mode"].connect (() => {
            set_keep_symbol ();
		    });

            icon_below = new Gtk.Image.from_icon_name ("go-bottom-symbolic", Gtk.IconSize.BUTTON);
            icon_above = new Gtk.Image.from_icon_name ("go-top-symbolic", Gtk.IconSize.BUTTON);

            keep_button = new Gtk.Button ();
            set_keep_symbol ();
            keep_button.tooltip_text = _ ("Window");
            keep_button.can_focus = false;
            keep_button.clicked.connect (() => {
                settings.keep_switch ();
            });

            menu_button = new Button.from_icon_name ("applications-graphics-symbolic", IconSize.SMALL_TOOLBAR);
            menu_button.tooltip_text = _("Colors");
            menu_button.clicked.connect (() => {
            if (preferences_dialog == null) {
                debug ("Prefs button pressed.");
                preferences_dialog = new Preferences (this);
                preferences_dialog.show_all ();
                preferences_dialog.color_selected.connect ( (color) => {
                    change_color (color);
                    });
                preferences_dialog.destroy.connect (() => {
                    preferences_dialog = null;
                    });
                }
                preferences_dialog.present ();
            });

            mini_button = new Button.from_icon_name ("window-new-symbolic", IconSize.SMALL_TOOLBAR);
            mini_button.tooltip_text = _("Mini Window");
            mini_button.clicked.connect (() => {
            if (miniwindow == null) {
                debug ("MiniWindow button pressed.");
                miniwindow = new MiniWindow (this);
                miniwindow.show_all ();
                hide_on_delete ();
                update_position ();
                miniwindow.destroy.connect (() => {
                    miniwindow = null;
                    miniwindow_active = false;
                    set_keep_symbol ();
                    show_all ();
                    });
                miniwindow_active = true;
                }
                miniwindow.present ();
            });

            close_button = new Button.from_icon_name ("window-close-symbolic", IconSize.SMALL_TOOLBAR);
            close_button.tooltip_text = _("Close");
            close_button.clicked.connect (() => {
                if (miniwindow_active == false) {
                    destroy ();
                } else {
                    hide_on_delete ();
                    update_position ();
                }
            });

            var headerbar = new Gtk.HeaderBar ();
            headerbar.has_subtitle = false;
            headerbar.pack_start (close_button);
            headerbar.pack_start (lock_button);
            headerbar.pack_start (mini_button);
            headerbar.pack_end (menu_button);
            headerbar.pack_end (keep_button);
            this.set_titlebar (headerbar);

            var header_context = headerbar.get_style_context ();
            header_context.add_class ("default-decoration");
            header_context.add_class (Gtk.STYLE_CLASS_FLAT);

            var style_context = get_style_context ();
            style_context.add_class ("rounded");
            style_context.add_class ("widget_background");
            style_context.add_class ("flat");

            content = new Gtk.Grid ();
            content.margin = 6;
            content.column_spacing = 14;
            content.column_homogeneous = true;
            content.row_spacing = 6;

            set_upload ();
            set_download ();

            update_position ();

            network_conection ();
            update_view ();

            var spinner = new Gtk.Spinner ();
            spinner.active = true;
            spinner.halign = Gtk.Align.CENTER;
            spinner.vexpand = true;

            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            stack.vhomogeneous = true;
            stack.add (spinner);
            stack.add_named (content, "connection");
            stack.add_named (layout, "no_network");

            var overlay = new Gtk.Overlay ();
            overlay.add (stack);
            add (overlay);
            show_all ();
            present ();
            NetworkMonitor.get_default ().network_changed.connect (update_view);
            action_button.clicked.connect (() => {
                try {
                    AppInfo.launch_default_for_uri ("settings://network", null);
                } catch (Error e) {
                    warning (e.message);
                }

            });

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

            GLib.Timeout.add_seconds (0, () => {
            if (connection_available) {
            stack.visible_child_name = "connection";
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

    private void set_lock_symbol () {
            var settings = nino.Configs.Settings.get_settings ();
            switch (settings.lock_mode) {
            case LockMode.LOCK :
                lock_button.set_image (icon_lock);
                stick ();
                type_hint = Gdk.WindowTypeHint.DESKTOP;
                update_position ();
                break;
            case LockMode.UNLOCK :
                lock_button.set_image (icon_unlock);
                type_hint = Gdk.WindowTypeHint.DIALOG;
                unstick ();
                break;
            }
            lock_button.show_all ();
        }

    private void set_keep_symbol () {
            var settings = nino.Configs.Settings.get_settings ();
            switch (settings.keep_mode) {
            case KeepMode.ABOVE :
                keep_button.set_image (icon_above);
                set_keep_above (true);
                set_keep_below (false);
                break;
            case KeepMode.BELOW :
                keep_button.set_image (icon_below);
                set_keep_above (false);
                set_keep_below (true);
                break;
            }
            keep_button.show_all ();
        }

    private void network_conection () {
            var title_label = new Gtk.Label ("Network Is Not Available");
            title_label.hexpand = true;
            title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            title_label.max_width_chars = 40;
            title_label.wrap = true;
            title_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
            title_label.xalign = 0;

            var description_label = new Gtk.Label ("Connect to the Internet to Monitoring Network.");
            description_label.hexpand = true;
            description_label.max_width_chars = 40;
            description_label.wrap = true;
            description_label.use_markup = true;
            description_label.xalign = 0;
            description_label.valign = Gtk.Align.START;

            action_button = new Gtk.Button.with_label (_ ("Network Settings…"));
            action_button.halign = Gtk.Align.END;
            action_button.get_style_context ().add_class ("AlertView");
            action_button.margin_top = 2;
            action_button.margin_bottom = 2;

            var image = new Gtk.Image.from_icon_name ("network-error", Gtk.IconSize.DIALOG);
            image.margin_top = 6;
            image.valign = Gtk.Align.START;

            layout = new Gtk.Grid ();
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
    }

    public override bool configure_event (Gdk.EventConfigure event) {
            var settings = nino.Configs.Settings.get_settings ();
            int root_x, root_y;
            get_position (out root_x, out root_y);
            settings.window_x = root_x;
            settings.window_y = root_y;
            return base.configure_event (event);
        }

    public void change_color (string color) {
            var settings = nino.Configs.Settings.get_settings ();
            var css_provider = new Gtk.CssProvider ();
            var url_css = Constants.URL_CSS_WHITE;

            if (color == Color.WHITE.to_string ()) {
                url_css =  Constants.URL_CSS_WHITE;
            } else if (color == Color.BLACK.to_string ()) {
                url_css =  Constants.URL_CSS_DARK;
            } else if (color == Color.PINK.to_string ()) {
                url_css =  Constants.URL_CSS_PINK;
            } else if (color == Color.RED.to_string ()) {
                url_css =  Constants.URL_CSS_RED;
            } else if (color == Color.ORANGE.to_string ()) {
                url_css =  Constants.URL_CSS_ORANGE;
            } else if (color == Color.YELLOW.to_string ()) {
                url_css =  Constants.URL_CSS_YELLOW;
            } else if (color == Color.GREEN.to_string ()) {
                url_css =  Constants.URL_CSS_GREEN;
            } else if (color == Color.TEAL.to_string ()) {
                url_css =  Constants.URL_CSS_TEAL;
            } else if (color == Color.BLUE.to_string ()) {
                url_css =  Constants.URL_CSS_BLUE;
            } else if (color == Color.PURPLE.to_string ()) {
                url_css =  Constants.URL_CSS_PURPLE;
            } else if (color == Color.COCO.to_string ()) {
                url_css =  Constants.URL_CSS_COCO;
            } else if (color == Color.GRADIENT_BLUE_GREEN.to_string ()) {
                url_css =  Constants.URL_CSS_GRADIENT_BLUE_GREEN;
            } else if (color == Color.GRADIENT_PURPLE_RED.to_string ()) {
                url_css =  Constants.URL_CSS_GRADIENT_PURPLE_RED;
            } else if (color == Color.GRADIENT_PRIDE.to_string ()) {
                url_css =  Constants.URL_CSS_PRIDE;
            } else if (color == Color.TRANS_WHITE.to_string ()) {
                url_css =  Constants.URL_CSS_LIGHT_TRANS;
            } else if (color == Color.TRANS_BLACK.to_string ()) {
                url_css =  Constants.URL_CSS_DARK_TRANS;
            } else if (color == Color.SEMITRANS_WHITE.to_string ()) {
                url_css =  Constants.URL_CSS_LIGHT_SEMITRANS;
            } else if (color == Color.SEMITRANS_BLACK.to_string ()) {
                url_css =  Constants.URL_CSS_DARK_SEMITRANS;
            } else {
                settings.color = Color.WHITE.to_string ();
                url_css =  Constants.URL_CSS_WHITE;
            }
                settings.color = color;

                css_provider.load_from_resource (url_css);
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default (), 
                    css_provider, 
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
        }

    private void set_upload () {
            upload = new Gtk.Grid ();
            upload.row_spacing = 6;
            upload.width_request = 6;

            icon_up = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.MENU);
            upload.attach (icon_up, 0, 0, 1, 1);

            network_up_label = new Gtk.Label ("UPLOAD");
            network_up_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            network_up_label.hexpand = true;
            upload.attach (network_up_label, 0, 1, 1, 1);

            var title = new Gtk.Label (_ ("Upload"));
            title.hexpand = true;
            upload.attach (title, 0, 2, 1, 1);

            content.attach (upload, 0, 0, 1, 1);
    }

    private void set_download () {
            download = new Gtk.Grid ();
            download.row_spacing = 6;
            download.width_request = 6;

            icon_down = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.MENU);
            download.attach (icon_down, 0, 0, 1, 1);

	        network_down_label = new Gtk.Label ("DOWNLOAD");
            network_down_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            network_down_label.hexpand = true;
            download.attach (network_down_label, 0, 1, 1, 1);

            var title = new Gtk.Label (_ ("Download"));
            title.hexpand = true;
            download.attach (title, 0, 2, 1, 1);

            content.attach (download, 1, 0, 1, 1);
    }

    private void update () {
            GLib.Timeout.add_seconds (1, () => {
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

