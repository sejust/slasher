package main

import (
	"fmt"
	"runtime/debug"
	"time"

	"github.com/sejust/slasher/code/unique"
)

func main() {
	defer func() {
		if p := recover(); p != nil {
			fmt.Println(p)
			fmt.Println(string(debug.Stack()))
			time.Sleep(time.Hour)
		}
	}()
	unique.Run()
}
