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
}
