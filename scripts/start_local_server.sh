sleep 10 &&
    stack build && stack exec site -- clean &&
    stack exec site -- watch --port 8001
