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
    private Gtk.Button net_view_button;
    private Gtk.Revealer main_revealer;
    private Gtk.Revealer lock_revealer;
    private Gtk.Revealer network_view;
    private Gtk.Revealer updown_revealer;
    private Gtk.Stack stack;

    public MiniWindow (Gtk.Application application) {
        Object (
            application: application,
            border_width: 0,
            resizable: false,
            height_request: 10,
            width_request: 120
        );
    }

    construct {
        Timeout.add_seconds (1, () => {
            update_data ();
            return true;
        });
        Timeout.add (50, () => {
            net_view_widget_symbol ();
            set_mini_lock_symbol ();
            return false;
        });

        set_keep_above (true);
        set_keep_below (false);
        main_revealer = new Gtk.Revealer ();
        main_revealer.add (main_button_wodget ());
        main_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

        lock_revealer = new Gtk.Revealer ();
        lock_revealer.add (mini_lock_button_widget ());
        lock_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;

        network_view = new Gtk.Revealer ();
        network_view.add (net_view_widget ());
        network_view.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

        headerbar.pack_start (main_revealer);
        headerbar.pack_end (network_view);
        headerbar.pack_end (lock_revealer);

        update_position (settings.dialog_x, settings.dialog_y);
        show_all ();
        NinoApp.settings.changed["window-out-of-focus-translucid"].connect (configure_window_opacity_on_focus_loss);
        configure_window_opacity_on_focus_loss ();
        event.connect (listen_to_window_events);
    }

    private bool listen_to_window_events (Gdk.Event event) {
            if (is_active) {
                close_button_revealer.set_reveal_child (true);
                network_view.set_reveal_child (true);
                lock_revealer.set_reveal_child (true);
                main_revealer.set_reveal_child (true);
            } else {
                close_button_revealer.set_reveal_child (false);
                network_view.set_reveal_child (false);
                main_revealer.set_reveal_child (false);
                lock_revealer.set_reveal_child (false);
            }
            mask_input ();
        return false;
    }

    private void mask_input () {
        input_shape_combine_region (!is_active ? create_mask () : null);
    }

    private Cairo.Region create_mask () {
        Cairo.RectangleInt rect_int;
        rect_int = {0, 0, 0, 0};

        var region = new Cairo.Region.rectangle (rect_int);
        return region;
    }

    private Gtk.Widget mini_lock_button_widget () {
        mini_lock_button = new Gtk.Button ();
        mini_lock_button.can_focus = false;
        mini_lock_button.clicked.connect (() => {
            settings.mini_lock_switch ();
            set_mini_lock_symbol ();
        });
        set_mini_lock_symbol ();
        return mini_lock_button;
    }

    private Gtk.Widget net_view_widget () {
        net_view_button = new Gtk.Button ();
        net_view_button.can_focus = false;
        net_view_button.clicked.connect (() => {
            settings.net_switch ();
            net_view_widget_symbol ();
        });
        net_view_widget_symbol ();
        return net_view_button;
    }

    private void configure_window_opacity_on_focus_loss () {
        if (NinoApp.settings.get_boolean ("window-out-of-focus-translucid")) {
            get_style_context ().add_class ("translucid-backdrop");
        } else {
            get_style_context ().remove_class ("translucid-backdrop");
        }
    }

    private Gtk.Widget main_button_wodget () {
        var main_button = new Gtk.Button.from_icon_name ("window-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        main_button.tooltip_text = StringPot.MainWindow;
        main_button.clicked.connect (() => {
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
        return main_button;
    }

    private void set_mini_lock_symbol () {
        switch (settings.mini_lock_mode) {
            case nino.Configs.MiniLockMode.LOCK :
                mini_lock_button.image = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
                mini_lock_button.tooltip_text = StringPot.Lock;
                stick ();
                type_hint = Gdk.WindowTypeHint.SPLASHSCREEN;
                break;
            case nino.Configs.MiniLockMode.UNLOCK :
                mini_lock_button.image = new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.BUTTON);
                mini_lock_button.tooltip_text = StringPot.Unlock;
                unstick ();
                type_hint = Gdk.WindowTypeHint.DIALOG;
                break;
        }
    }

    private void net_view_widget_symbol () {
        switch (settings.net_view) {
            case nino.Configs.NetView.DUAL :
                net_view_button.image = new Gtk.Image.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.BUTTON);
                net_view_button.tooltip_text = ("Dual");
                stack.visible_child_name = "updown";
                updown_revealer.set_reveal_child (true);
                break;
            case nino.Configs.NetView.TOTAL :
                net_view_button.image = new Gtk.Image.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.BUTTON);
                net_view_button.tooltip_text = ("Total");
                stack.visible_child_name = "total";
                updown_revealer.set_reveal_child (false);
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
        network_up_label.tooltip_text = StringPot.UploadSpeed;
        network_down_label.tooltip_text = StringPot.DownloadSpeed;

        icon_down = new Gtk.Image.from_icon_name ("go-down-symbolic", Gtk.IconSize.MENU);
        icon_down.xalign = 0;
        icon_up = new Gtk.Image.from_icon_name ("go-up-symbolic", Gtk.IconSize.MENU);
        icon_up.xalign = 0;

        var down_grid = new Gtk.Grid ();
        down_grid.orientation = Gtk.Orientation.HORIZONTAL;
        down_grid.get_style_context ().add_class ("net_color");
        down_grid.margin = 0;
        down_grid.row_spacing = 0;
        down_grid.column_spacing = 0;
        down_grid.margin_top = 0;
        down_grid.add (icon_down);
        down_grid.add (network_down_label);

        var up_grid = new Gtk.Grid ();
        up_grid.orientation = Gtk.Orientation.HORIZONTAL;
        up_grid.get_style_context ().add_class ("net_color");
        up_grid.margin = 0;
        up_grid.row_spacing = 0;
        up_grid.column_spacing = 0;
        up_grid.margin_top = 0;
        up_grid.add (icon_up);
        up_grid.add (network_up_label);

        var up_down_grid = new Gtk.Grid ();
        up_down_grid.orientation = Gtk.Orientation.VERTICAL;
        up_down_grid.margin = 4;
        up_down_grid.row_spacing = 4;
        up_down_grid.column_spacing = 0;
        up_down_grid.margin_top = 0;
        up_down_grid.column_homogeneous = true;
        up_down_grid.valign = Gtk.Align.CENTER;
        up_down_grid.add (up_grid);
        up_down_grid.add (down_grid);
        updown_revealer = new Gtk.Revealer ();
        updown_revealer.add (up_down_grid);
        updown_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;

        var total_grid = new Gtk.Grid ();
        total_grid.orientation = Gtk.Orientation.HORIZONTAL;
        total_grid.get_style_context ().add_class ("net_color");
        total_grid.margin = 0;
        total_grid.row_spacing = 0;
        total_grid.column_spacing = 0;
        total_grid.margin_top = 0;
        total_grid.valign = Gtk.Align.CENTER;
        total_grid.add (icon_up_total);
        total_grid.add (icon_down_total);
        total_grid.add (network_total_label);

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_DOWN;
        stack.vhomogeneous = true;
        stack.add_named (updown_revealer, "updown");
        stack.add_named (total_grid, "total");

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 0;
        main_grid.row_spacing = 0;
        main_grid.column_spacing = 0;
        main_grid.margin_top = 0;
        main_grid.valign = Gtk.Align.CENTER;
        main_grid.column_homogeneous = true;
        main_grid.add (stack);

        return main_grid;
    }

    protected override Gtk.Grid no_network_conection () {
        var alert = new Gtk.Image.from_icon_name ("network-error", Gtk.IconSize.DIALOG);
        alert.tooltip_text = StringPot.NetworkNotAvailable;
        var network_view = new Gtk.Grid ();
        network_view.margin = 0;
        network_view.column_spacing = 0;
        network_view.column_homogeneous = true;
        network_view.row_spacing = 0;
        network_view.attach (alert, 0, 0, 1, 1);

        return network_view;
    }
}
