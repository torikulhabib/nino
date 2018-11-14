/*
* Copyright (C) 2018  Torikul habib <torik.habib@gmail.com>
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

namespace nino.Configs {
    public class Settings : Granite.Services.Settings {
        private static Settings? instance;
        public int dialog_x { get; set; }
        public int dialog_y { get; set; }
        public int window_x { get; set; }
        public int window_y { get; set; }
        public string color { get; set; }
        private Settings () {
            base ("com.github.torikulhabib.nino");
        }
        public static unowned Settings get_instance () {
            if (instance == null) {
                instance = new Settings ();
            }
            return instance;
        }
    }
}
