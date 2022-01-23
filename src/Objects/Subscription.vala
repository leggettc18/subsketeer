/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2021 Christopher Leggett <chris@leggett.dev>
 */

public class Subscription {
    private int id = null;
    public string name;
    public int amount;
    public bool enabled;
    public Subsketeer.Category category = null;
    public DateTime date_created;
    public DateTime date_modified;

    public Subscription () {

    }

    public bool persist () {
        Subsketeer.Database db = new Subsketeer.Database ();
        if (id == null) {
            return db.create_subscription (self);
        } else {
            return db.save_subscription (self);
        }
    }
}
