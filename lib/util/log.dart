logError(String msg) {
  print("[error] $msg");
  logStackTrace();
}

logWarn(String msg) {
  print("[warn] $msg");
  logStackTrace();
}

logInfo(String msg) {
  print("[info] $msg");
}

logDebug(String msg) {
  print("[debug] $msg");
}

logStackTrace() {
  print(StackTrace.current);
}