logError(String msg) {
  print("[error] $msg");
  printStackTrace();
}

logWarn(String msg) {
  print("[warn] $msg");
}

logInfo(String msg) {
  print("[info] $msg");
}

logDebug(String msg) {
  assert((() {
    print("[debug] $msg");
    return true;
  })());
}

printStackTrace() {
  print(StackTrace.current);
}