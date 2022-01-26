/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2021 Christopher Leggett <chris@leggett.dev>
 */

public class SubsketeerApp : Gtk.Application {
    public string[] args;
    public SubsketeerApp () {
        Object  (
            application_id: "com.github.leggettc18.subsketeer",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        Granite.Services.Logger.initialize ("Subsketeer");
        Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.INFO;
        Database db = new Database ();
        if (db.check_database_exists()) {
            // not first run
        } else {
            // first run
            db.setup ();
            Subscription sub = new Subscription () {
                name = "Test",
                amount = 300
            };
            sub.persist ();
        }
        //Hdy.init ();
        info ("creating main window");
        var main_window = new MainWindow () {
            default_height = 300,
            default_width = 300,
            title = _("Hello World")
        };
        info ("showing main window");
        main_window.set_application (this);
        main_window.show_all ();
        info ("showed main window");
    }

    public static void main (string[] args) {
        Gtk.init (ref args);
        SubsketeerApp app = new SubsketeerApp ();
        //  app.startup.connect (() => {
        //      Hdy.init ();
        //  });
        app.args = args;
        info ("running app");
        var result = app.run (args);
        info ("app finished running: %d", result);
    }
}

