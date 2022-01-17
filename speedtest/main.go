package main

import (
	"fmt"
	"github.com/showwin/speedtest-go/speedtest"
)

func main() {
	fmt.Print("Retrieving speedtest.net configuration...\n")
	user, _ := speedtest.FetchUserInfo()

	serverList, _ := speedtest.FetchServerList(user)
	targets, _ := serverList.FindServer([]int{})

	for _, s := range targets {
		s.PingTest()
		s.DownloadTest(false)
		s.UploadTest(false)

		fmt.Printf("\nLatency: %s\nDownload: %f Mbit/s\nUpload: %f Mbit/s\n", s.Latency, s.DLSpeed, s.ULSpeed)
	}
}
