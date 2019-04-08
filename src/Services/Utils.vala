/*-
 * Copyright (c) 2018 Tudor Plugaru (https://github.com/PlugaruT/wingpanel-indicator-sys-monitor)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Tudor Plugaru <plugaru.tudor@gmail.com>
 */

namespace nino {
public class Utils  : GLib.Object {
    public Utils () {
    }

    construct { }

    public static string format_net_speed (int bytes) {
        string[] sizes = { " B/s", "KB/s", "MB/s", "GB/s", "TB/s" };
        double len = (double) bytes;
        int order = 0;
        string speed = "";
        while (len >= 1024 && order < sizes.length - 1) {
            order++;
            len = len/1024;
        }
        if(bytes < 0){
            len = 0;
            order = 0;
        }
        if (order >= 2) {
            if (len > 9 && len <= 99) {
                speed = "%3.1f %s".printf(len, sizes[order]);
            } else if (len > 99) {
                speed = "%3.0f %s".printf(len, sizes[order]);
            } else  {
                speed = "%3.2f %s".printf(len, sizes[order]);
            }
        } else {
            speed = "%3.0f %s".printf(len, sizes[order]);
        }
        return speed;
    }
}
}
