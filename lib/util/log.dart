logError(String msg, [bool withAssert = true]) {
  print("[error] $msg");
  printStackTrace();
  if (withAssert) assert(false);
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
