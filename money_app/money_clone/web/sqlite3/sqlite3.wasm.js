// sqlite3.wasm.js - SQLite WebAssembly loader
var sqlite3InitModule = (function() {
  // Store the Module object
  var Module = typeof Module !== 'undefined' ? Module : {};

  // Set up the promise that will be resolved when the WASM is loaded
  return new Promise(function(resolve, reject) {
    // Wait for the main module to be ready
    if (Module.calledRun) {
      resolve(Module);
      return;
    }
    
    // Set up functions to handle module loading
    Module.onRuntimeInitialized = function() {
      resolve(Module);
    };
    
    Module.onAbort = function(what) {
      reject(new Error('SQLite3 WASM initialization aborted: ' + what));
    };
    
    // Load the actual WASM file
    var script = document.createElement('script');
    script.src = 'sqlite3.wasm';
    script.onerror = function() {
      reject(new Error('Failed to load SQLite3 WASM'));
    };
    document.body.appendChild(script);
  });
})();
