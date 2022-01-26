/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2021 Christopher Leggett <chris@leggett.dev>
 */

public class Subscription {
    public int? id = null;
    public string name;
    public int amount;
    public bool enabled;
    public Category category = null;
    public DateTime date_created;
    public DateTime date_modified;

    public Subscription () {
        enabled = true;
    }

    public bool persist () {
        Database db = new Database ();
        if (id == null) {
            date_created = new DateTime.now ();
            date_modified = new DateTime.now ();
            return db.create_subscription (this);
        } else {
            date_modified = new DateTime.now ();
            return db.save_subscription (this);
        }
    }

    public static Subscription fetch (int id) {
        Database db = new Database ();
        return db.fetch_subscription (id);
    }
}
