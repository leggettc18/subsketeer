/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2021 Christopher Leggett <chris@leggett.dev>
 */

public class SubsketeerApp : Gtk.Application {
    public SubsketeerApp () {
        Object  (
            application_id: "com.github.leggettc18.subsketeer",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this) {
            default_height = 300,
            default_width = 300,
            title = "Hello World"
        };
        var label = new Gtk.Label ("Hello World!");
        main_window.add (label);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        return new SubsketeerApp ().run (args);
    }
}
