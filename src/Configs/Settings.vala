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
    public enum LockMode {
        LOCK = 0,
        UNLOCK = 1
    }
    public enum KeepMode {
        ABOVE = 0,
        BELOW = 1
    }
    public enum MiniLockMode {
        LOCK = 0,
        UNLOCK = 1
    }
    public enum NetView {
        DUAL = 0,
        TOTAL = 1
    }

    public class Settings : Granite.Services.Settings {
        private static Settings? settings;
        public int dialog_x { get; set; }
        public int dialog_y { get; set; }
        public int window_x { get; set; }
        public int window_y { get; set; }
        public LockMode lock_mode { get; set; }
        public KeepMode keep_mode { get; set; }
        public MiniLockMode mini_lock_mode { get; set; }
        public NetView net_view { get; set; }
        public string color { get; set; }

        private Settings () {
            base ("com.github.torikulhabib.nino");
        }

        public void lock_switch () {
            switch (settings.lock_mode) {
                case LockMode.LOCK:
                    settings.lock_mode = LockMode.UNLOCK;
                    break;
                default:
                    settings.lock_mode = LockMode.LOCK;
                    break;
            }
        }

        public void keep_switch () {
            switch (settings.keep_mode) {
                case KeepMode.ABOVE:
                    settings.keep_mode = KeepMode.BELOW;
                    break;
                default:
                    settings.keep_mode = KeepMode.ABOVE;
                    break;
            }
        }

        public void mini_lock_switch () {
            switch (settings.mini_lock_mode) {
                case MiniLockMode.LOCK:
                    settings.mini_lock_mode = MiniLockMode.UNLOCK;
                    break;
                default:
                    settings.mini_lock_mode = MiniLockMode.LOCK;
                    break;
            }
        }

        public void net_switch () {
            switch (settings.net_view) {
                case NetView.DUAL:
                    settings.net_view = NetView.TOTAL;
                    break;
                default:
                    settings.net_view = NetView.DUAL;
                    break;
            }
        }

        public static unowned Settings get_settings () {
            if (settings == null) {
                settings = new Settings ();
            }
            return settings;
        }


    }
}
