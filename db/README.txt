We are not using migrate, because the point of this system is that it's a database thing, not a ruby thing.

Requirements:
* postgress running on localhost, port 5432
* a user role named 'tree-admin', no password
* a user role named 'tree-appuser', no passwored
* a database named 'tree', owned by 'tree-admin'

Artifacts are put in the 'public' schema of database 'tree'

