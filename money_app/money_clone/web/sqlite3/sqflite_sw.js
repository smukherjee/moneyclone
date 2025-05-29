// sqflite_sw.js - SQLite web worker
self.importScripts('sqlite3.wasm.js');

// Wait for sqlite3 initialization to complete
self.sqlite3InitModule().then((sqlite3) => {
  // Handle messages from the main thread
  self.onmessage = (event) => {
    const { id, action, params } = event.data;
    let result;
    let error;

    try {
      if (action === 'open') {
        // Open database
        const db = new sqlite3.oo1.DB(params.name, params.flags);
        result = { id: db.pointer };
      } else if (action === 'exec') {
        // Execute SQL statement
        const db = new sqlite3.oo1.DB.fromPointer(params.dbId);
        if (params.sql) {
          result = db.exec(params.sql, params.params);
        }
      } else if (action === 'close') {
        // Close database
        const db = new sqlite3.oo1.DB.fromPointer(params.dbId);
        db.close();
        result = true;
      } else if (action === 'batch') {
        // Execute batch operations
        const db = new sqlite3.oo1.DB.fromPointer(params.dbId);
        result = [];
        for (const op of params.operations) {
          if (op.sql) {
            result.push(db.exec(op.sql, op.params));
          }
        }
      }
    } catch (e) {
      error = { message: e.message, code: e.code };
    }

    // Send result back to main thread
    self.postMessage({ id, result, error });
  };

  // Signal that the worker is ready
  self.postMessage({ ready: true });
}).catch((e) => {
  self.postMessage({ error: { message: e.message } });
});