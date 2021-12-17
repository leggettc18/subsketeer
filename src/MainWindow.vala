/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2021 Christopher Leggett <chris@leggett.dev>
 */
namespace Subsketeer {

public class MainWindow : Hdy.ApplicationWindow {
    Hdy.HeaderBar header_bar;
    Hdy.WindowHandle window_handle;
    Gtk.Grid main_layout;
    Gtk.Label label;

    public MainWindow () {
        info ("initializing libhandy");
        Hdy.init ();
        expand = true;
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        // Check if user prefers dark theme or not
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        // Listen for changes to user's dark theme preference
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme ==
                Granite.Settings.ColorScheme.DARK;
        });
        info ("creating label");
        label = new Gtk.Label (_("Hello World!"));
        info ("creating main layout");
        main_layout = new Gtk.Grid () {
            expand = true
        };
        info ("creating header bar");
        header_bar = new Hdy.HeaderBar () {
            show_close_button = true
        };
        info ("creating window handle");
        window_handle = new Hdy.WindowHandle ();
        info ("attaching headerbar to main layout");
        main_layout.attach (header_bar, 0, 0);
        info ("creating main box");
        Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            vexpand = true,
            //width_request = 500,
            //height_request = 500
        };
        info ("adding label to main box");
        main_box.add (label);
        info ("adding main box to main layout");
        main_layout.attach (main_box, 0, 1);
        info ("adding main layout to window handle");
        window_handle.add (main_layout);
        info ("adding window handle to main window");
        add (window_handle);
        info ("showing all from inside main window class");
        show_all ();
        info ("returning main window");
    }
}

}