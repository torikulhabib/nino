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

namespace nino {
    public class NinoApp : Granite.Application {
        public static GLib.Settings settings;
        private MainWindow mainwindow = null;
        public NinoApp () {
            Object(
                application_id: "com.github.torikulhabib.nino", 
                flags: ApplicationFlags.FLAGS_NONE
            );
            var quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (() => {
                if (mainwindow != null) {
                mainwindow.destroy ();
            }
            });
            add_action (quit_action);
            set_accels_for_action ("app.quit", {"<Ctrl>Q"});
        }

        static construct {
            settings = new Settings ("com.github.torikulhabib.nino");
        }

        protected override void activate () {
        if (get_windows ().length () > 0) {
            get_windows ().data.present ();
            return;
        }
            mainwindow = new MainWindow (this);
            mainwindow.set_application(this);
            mainwindow.show_all ();

            var color = settings.get_string ("color");
            string css = color;
            var css_provider = new Gtk.CssProvider ();
            var css_path = Color.string_to_css_path (css);
            css_provider.load_from_resource (css_path);
            Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default (), 
                    css_provider, 
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }

        public static int main (string[] args) {
            var app = new NinoApp ();
            return app.run (args);
        }
    }
}
