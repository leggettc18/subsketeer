public class Database {
    private Sqlite.Database db;
    private string db_location = null;
    private string db_directory = null;

    public Database () {
        db_directory = GLib.Environment.get_user_data_dir () + """/subsketeer/database""";
        db_location = db_directory + """/subsketeer.db""";
    }

    public bool check_database_exists () {
        File file = File.new_for_path (db_location);
        return file.query_exists ();
    }

    private int prepare_database () {
        assert (db_location != null);

        int ec = Sqlite.Database.open (db_location, out db);
        if (ec != Sqlite.OK) {
            stderr.printf (
                "Can't open database: %d: %s\n",
                db.errcode (), db.errmsg ()
            );
            return -1;
        }
        return 0;
    }

    public bool setup () {
        prepare_database ();

        GLib.DirUtils.create_with_parents (db_directory, 0775);

        create_db_schema ();

        return true;
    }

    public void create_db_schema () {
        prepare_database ();

        string query = """
            BEGIN TRANSACTION;

            CREATE TABLE Category (
                id              INTEGER     PRIMARY KEY     AUTOINCREMENT,
                name            TEXT                        NOT NULL,
                color           TEXT CHECK( color IN ("strawberry", "orange", "banana", "lime", "mint", "blueberry", "grape", "bubblegum", "cocoa", "silver", "slate", "black") ),
                date_created    INTEGER                     NOT NULL,
                date_modified   INTEGER                     NOT NULL
            );

            CREATE TABLE Subscription (
                id              INTEGER     PRIMARY KEY     AUTOINCREMENT,
                name            TEXT                        NOT NULL,
                amount          INTEGER                     NOT NULL,
                enabled         INTEGER                     NOT NULL,
                category_id     INTEGER,
                date_created    INTEGER                     NOT NULL,
                date_modified   INTEGER                     NOT NULL,
                FOREIGN KEY(category_id) REFERENCES Category(id)
            );

            PRAGMA user_version = 1;

            END TRANSACTION;
        """;

        int ec = db.exec (query, null);
        if (ec != Sqlite.OK) {
            error (
                "unable to create database schema %d: %s",
                db.errcode (),
                db.errmsg ()
            );
        }
        return;
    }

    public bool create_subscription (Subscription sub) {
        prepare_database ();
        // id is omitted because integer primary_key fields are
        // automatically autoincremented when an explicit value
        // is not supplied.
        string query = "INSERT INTO Subscription" +
            " (id, name, amount, enabled, category_id, date_created, date_modified) " +
            " VALUES (NULL, ?1, ?2, ?3, ?4, ?5, ?5);";
        Sqlite.Statement stmt;
        int ec = db.prepare_v2 (query, query.length, out stmt);

        if (ec != Sqlite.OK) {
            warning (
                "unable to prepare create_subscription statement. %d: %s",
                db.errcode (),
                db.errmsg ()
            );
            return false;
        }

        stmt.bind_text (1, sub.name);
        stmt.bind_int (2, sub.amount);
        stmt.bind_int (3, sub.enabled ? 1 : 0);
        if (sub.category != null) {
            stmt.bind_int (4, sub.category.id);
        } else {
            stmt.bind_null(4);
        }
        stmt.bind_int64 (5, sub.date_created.to_unix ());

        ec = stmt.step ();

        if (ec != Sqlite.DONE) {
            warning (
                "unable to create subscription. %d: %s",
                db.errcode (),
                db.errmsg ()
            );
            return false;
        }
        return true;
    }

    public bool save_subscription (Subscription sub) {
        prepare_database ();
        string query = """
            UPDATE Subscription
            SET name = ?1,
                amount = ?2,
                enabled = ?3,
                category_id = ?4
                date_modified = ?5
            WHERE id = ?6;
        """;
        Sqlite.Statement stmt;
        int ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            warning (
                "unable to prepare save_subscription statement. %d: %s",
                db.errcode (),
                db.errmsg ()
            );
            return false;
        }

        stmt.bind_text (1, sub.name);
        stmt.bind_int (2, sub.amount);
        stmt.bind_int (3, sub.enabled ? 1 : 0);
        if (sub.category != null) {
            stmt.bind_int (4, sub.category.id);
        } else {
            stmt.bind_null (4);
        }
        stmt.bind_int64 (5, sub.date_modified.to_unix ());
        stmt.bind_int (6, sub.id);

        if (ec != Sqlite.DONE) {
            warning (
                "unable to save subscription. %d: %s",
                db.errcode (),
                db.errmsg ()
            );
            return false;
        }
        return true;
    }

    public Subscription? fetch_subscription (int id) {
        prepare_database ();
        string query = "SELECT * FROM Subscription WHERE id = ?1";
        Sqlite.Statement stmt;
        int ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            warning ("%d: %s", db.errcode (), db.errmsg ());
            return null;
        }

        stmt.bind_int (1, id);

        Subscription sub = null;
        while (stmt.step () == Sqlite.ROW) {
            sub = subscription_from_row (stmt);
            info (sub.name);
        }
        return sub;
    }

    private Subscription subscription_from_row (Sqlite.Statement stmt) {
        Subscription sub = new Subscription ();

        for (int i = 0; i < stmt.column_count (); i++) {
            string column_name = stmt.column_name (i) ?? "<none>";
            string val = stmt.column_text (i) ?? "<none>";

            if (column_name == "name") {
                sub.name = val;
            } else if (column_name == "amount") {
                int amount = 0;
                if (int.try_parse (val, out amount)) {
                    sub.amount = amount;
                }
            } else if (column_name == "enabled") {
                sub.enabled = val == "1";
            } else if (column_name == "date_created") {
                sub.date_created = new DateTime.from_unix_local (val.to_int ());
            } else if (column_name == "date_modified") {
                sub.date_modified  = new DateTime.from_unix_local (val.to_int ());
            }
        }
        return sub;
    }
}
