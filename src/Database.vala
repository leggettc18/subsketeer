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
                id              INTEGER     PRIMARY_KEY     NOT NULL,
                name            TEXT                        NOT NULL,
                color           TEXT CHECK( pType IN ("strawberry", "orange", "banana", "lime", "mint", "blueberry", "grape", "bubblegum", "cocoa", "silver", "slate", "black") ),
                date_created    INTEGER                     NOT NULL,
                date_modified   INTEGER
            );
            
            CREATE TABLE Subscription (
                id              INTEGER     PRIMARY_KEY     NOT NULL,
                name            TEXT                        NOT NULL,
                amount          INTEGER                     NOT NULL,
                enabled         INTEGER                     NOT NULL,
                category_id     INTEGER,
                date_created    INTEGER                     NOT NULL,
                date_modified   INTEGER,
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
    
    public bool create_subscription (Subscription sub, int category_id) {
        // id is omitted because integer primary_key fields are
        // automatically autoincremented when an explicit value
        // is not supplied.
        string query = "INSERT INTO Subscription" + 
            " (name, amount, enabled, category_id, date_created, date_modified) " + 
            " VALUES (?1, ?2, ?3, ?4, ?5, ?5);";
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
        stmt.bind_int (4, category_id);
        stmt.bind_int64 (4, sub.date_created.to_unix ());
        
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
}
